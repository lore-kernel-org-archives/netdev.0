From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc91x: propagate irq return code
Date: Mon, 01 Feb 2016 21:41:15 +0100
Message-ID: <87twls5fkk.fsf@belgarion.home>
References: <1454280377-25697-1-git-send-email-robert.jarzmik@free.fr>
	<56AF514D.6010608@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56AF514D.6010608@cogentembedded.com> (Sergei Shtylyov's message
	of "Mon, 1 Feb 2016 15:36:29 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

> Hello.
>
> On 2/1/2016 1:46 AM, Robert Jarzmik wrote:
>
>> The smc91x driver doesn't honor the probe deferral mechanism when the
>> interrupt source is not yet available, such as one provided by a gpio
>> controller not probed.
>    What if 'ndev->irq' does equal 0?
That's not possible AFAIR.

There was a discussion where Linus had stated that the irq is a cookie, and a 0
value is "no interrupt", expcepting for the single case of a PC and its timer
interrupt.

As we're not in that case, and up to my understanding, platform_get_irq() cannot
return a 0 value, only a strictly negative or positive one.

And yet, that test now looks weird to me. I think I'll respin the patch with a
"if (ndev->irq < 0) {" instead of the "if (ndev->irq <= 0) {".

Cheers.

-- 
Robert
