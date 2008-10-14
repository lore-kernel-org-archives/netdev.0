From: "Andy Fleming" <afleming@gmail.com>
Subject: Re: [PATCH] Change S390 anti-dependency to CONFIG_GENERIC_HARDIRQS dependency
Date: Tue, 14 Oct 2008 18:21:44 -0500
Message-ID: <2acbd3e40810141621p31ba3ccdic909fc4634b5ef26@mail.gmail.com>
References: <1224023293-8592-1-git-send-email-afleming@freescale.com>
	 <20081014.154422.192817982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:5153 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043AbYJNXVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 19:21:45 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2402143wfd.4
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 16:21:44 -0700 (PDT)
In-Reply-To: <20081014.154422.192817982.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 5:44 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Fleming <afleming@freescale.com>
> Date: Tue, 14 Oct 2008 17:28:13 -0500
>
>> PHY Lib and DSA expect request_irq and other such functions to exist.
>> S390 doesn't support those functions, however we should mark the actual
>> dependency, which is generic hardirq support, rather than explicitly
>> depend on !S390.
>>
>> Signed-off-by: Andy Fleming <afleming@freescale.com>
>> ---
>> This makes more sense to me, but I could be missing something?
>
> GENERIC_HARDIRQS is not the correct dependency.
>
> Not all architectures use the generic IRQ layer, yet have
> support for interrupts (request_irq(), free_irq(), etc.)
>
> Two such platforms are 32-bit sparc and m68k.


Argh.  From what I could see, we have request_irq, free_irq,
disable_irq, enable_irq, and disable_irq_nosync.  For the PHYLIB, it
shouldn't be difficult to modify things so that it doesn't compile in
interrupt support if the system doesn't support them.  Shouldn't, that
is, if there's some config option that tells me whether those
functions exist.

Would it be acceptable to create a config option which *did* convey
this meaning?  Off the top of my head I can imagine either having
s390's Kconfig declare NO_HARDIRQ_SUPPORT.  Alternatively, it would be
less trivial, but fairly easy to create a config option,
HARDIRQ_SUPPORT, which is either selected by arches which define their
own request_irq, etc functions, or automatically selected when
GENERIC_HARDIRQS is selected.

Andy
