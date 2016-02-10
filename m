From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 10 Feb 2016 15:18:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCDD01B@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CCDCC8D@AcuExch.aculab.com>
 <20160210144334.23242.qmail@ns.horizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "mingo@kernel.org" <mingo@kernel.org>
To: 'George Spelvin' <linux@horizon.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tom@herbertland.com" <tom@herbertland.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160210144334.23242.qmail@ns.horizon.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: George Spelvin
> Sent: 10 February 2016 14:44
...
> > I think the fastest loop is:
> > 10:	adcq	0(%rdi,%rcx,8),%rax
> > 	inc	%rcx
> > 	jnz	10b
> > That loop looks like it will have no overhead on recent cpu.
> 
> Well, it should execute at 1 instruction/cycle.

I presume you do mean 1 adc/cycle.
If it doesn't unrolling once might help.

> (No, a scaled offset doesn't take extra time.)
Maybe I'm remembering the 386 book.

> To break that requires ADCX/ADOX:
> 
> 10:	adcxq	0(%rdi,%rcx),%rax
> 	adoxq	8(%rdi,%rcx),%rdx
>  	leaq	16(%rcx),%rcx
> 	jrcxz	11f
>  	j	10b
> 11:

Getting 2 adc/cycle probably does require a little unrolling.
With luck the adcxq, adoxq and leaq will execute together.
The jrcxz is two clocks - so definitely needs a second adcoxq/adcxq pair.

Experiments would be needed to confirm guesses though.

	David
