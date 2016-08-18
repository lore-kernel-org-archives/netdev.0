From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: Re: [PATCH] mwifiex: propagate error if IRQ request fails in
 mwifiex_sdio_of()
Date: Thu, 18 Aug 2016 15:29:01 -0400
Message-ID: <70b6a0d1-8cc4-280e-3e53-8c42cb43b721@osg.samsung.com>
References: <1471529868-13669-1-git-send-email-javier@osg.samsung.com>
 <10fb1110-4c0b-00a2-522c-7011ca397b8c@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <akarwar@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>, netdev@vger.kernel.org,
        linux-wireless@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>
To: Arend van Spriel <arend.vanspriel@broadcom.com>,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <10fb1110-4c0b-00a2-522c-7011ca397b8c@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Arend,

Thanks a lot for your feedback.

On 08/18/2016 03:14 PM, Arend van Spriel wrote:
> On 18-08-16 16:17, Javier Martinez Canillas wrote:
>> If request_irq() fails in mwifiex_sdio_probe_of(), only an error message
>> is printed but the actual error is not propagated to the caller function.
> 
> Hmm. The caller function, ie. mwifiex_sdio_probe(), does not seem to care.
>

Hmm, I'm not so sure about that. It's checking the wifiex_sdio_probe_of()
return value.

If the IRQ request failing is not an error, then at the very least the call
to disable_irq() should be avoided if request_irq() fails, and the message
should be changed from dev_err() to dev_dgb() or dev_info().
 
> The device may still function without this wake interrupt.
>

That's correct, the binding says that the "interrupts" property in the child
node is optional since is just a wakeup IRQ. Now the question is if should
be an error if the IRQ is defined but fails to be requested.

> Regards,
> Arend
> 

Best regards,
-- 
Javier Martinez Canillas
Open Source Group
Samsung Research America
