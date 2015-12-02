From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: ipsec impact on performance
Date: Wed, 2 Dec 2015 15:50:28 -0500
Message-ID: <20151202205028.GB15262@oracle.com>
References: <20151201175953.GC21252@oracle.com>
 <CALx6S35uLqbuJTAFLMeT-BcyZw_fksz+7BkS=Nt7_3-nYMHF2A@mail.gmail.com>
 <20151201183720.GE21252@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0ED7@AcuExch.aculab.com>
 <20151202121156.GK23178@oracle.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
	rick.jones2@hpe.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CBE0F39@AcuExch.aculab.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (12/02/15 12:41), David Laight wrote:
> You are getting 0.7 Gbps with ass-ccm-a-128, scale the esp-null back to
> that and it would use 7/18*71 = 27% of the cpu.
> So 69% of the cpu in the a-128 case is probably caused by the
> encryption itself.
> Even if the rest of the code cost nothing you'd not increase
> above 1Gbps.

Fortunately, the situation is not quite hopeless yet.

Thanks to Rick Jones for supplying the hints for this, but with
some careful manual pinning of irqs and iperf processes to cpus,
I can get to 4.5 Gbps for the esp-null case.

Given that the [clear traffic + GSO without GRO] gets me about 5-7 Gbps,
the 4.5 Gbps is not that far off (and at that point, the nickel-and-dime
tweaks may help even more).

For AES-GCM, I'm able to go from 1.8 Gbps (no GSO) to 2.8 Gbps.
Still not great, but proves that we haven't yet hit any upper bounds
yet.

I think a lot of the manual tweaking of irq/process placement
is needed because the existing rps/rfs flow steering is looking
for TCP/UDP flow numbers to do the steering. It can just as easily
use the IPsec SPI numbers to do this, and that's another place where
we can make this more ipsec-friendly.

--Sowmini
