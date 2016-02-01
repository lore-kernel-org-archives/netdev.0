From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smc91x: propagate irq return code
Date: Mon, 1 Feb 2016 23:55:14 +0300
Message-ID: <56AFC632.8070507@cogentembedded.com>
References: <1454280377-25697-1-git-send-email-robert.jarzmik@free.fr>
 <56AF514D.6010608@cogentembedded.com> <87twls5fkk.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Pitre <nico@fluxnic.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87twls5fkk.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/01/2016 11:41 PM, Robert Jarzmik wrote:

>>> The smc91x driver doesn't honor the probe deferral mechanism when the
>>> interrupt source is not yet available, such as one provided by a gpio
>>> controller not probed.

>>     What if 'ndev->irq' does equal 0?

> That's not possible AFAIR.

    Possible if of_irq_get() returns 0 (and it will on failure!).

> There was a discussion where Linus had stated that the irq is a cookie, and a 0
> value is "no interrupt", expcepting for the single case of a PC and its timer
> interrupt.

    I know, I know... and even on x86 it was never passed to request_irq(), 
only to setup_irq()...

> As we're not in that case, and up to my understanding, platform_get_irq() cannot
> return a 0 value, only a strictly negative or positive one.

    Wishful thinking...

> And yet, that test now looks weird to me. I think I'll respin the patch with a
> "if (ndev->irq < 0) {" instead of the "if (ndev->irq <= 0) {".

    Defeating Linus' PoV as a result... ;-)

> Cheers.

MBR, Sergei
