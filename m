From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: Re: [PATCH] net: smc91x: propagate irq return code
Date: Mon, 01 Feb 2016 22:02:34 +0100
Message-ID: <87powg5el1.fsf@belgarion.home>
References: <1454280377-25697-1-git-send-email-robert.jarzmik@free.fr>
	<56AF514D.6010608@cogentembedded.com> <87twls5fkk.fsf@belgarion.home>
	<56AFC632.8070507@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56AFC632.8070507@cogentembedded.com> (Sergei Shtylyov's message
	of "Mon, 1 Feb 2016 23:55:14 +0300")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> writes:

> On 02/01/2016 11:41 PM, Robert Jarzmik wrote:
>
>>>> The smc91x driver doesn't honor the probe deferral mechanism when the
>>>> interrupt source is not yet available, such as one provided by a gpio
>>>> controller not probed.
>
>>>     What if 'ndev->irq' does equal 0?
>
>> That's not possible AFAIR.
>
>    Possible if of_irq_get() returns 0 (and it will on failure!).
Ah good catch, didn't know that one.

>> And yet, that test now looks weird to me. I think I'll respin the patch with a
>> "if (ndev->irq < 0) {" instead of the "if (ndev->irq <= 0) {".
>
>    Defeating Linus' PoV as a result... ;-)
Well, I'd rather face the wrath of others if I'm convinced the code is more
correct. And in this case you convinced me :)

-- 
Robert
