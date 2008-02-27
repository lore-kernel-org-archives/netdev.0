From: "Miroslav Kratochvil" <exa.exa@gmail.com>
Subject: Re: r8169 driver compatibility with rtl8168 [need confirm]
Date: Wed, 27 Feb 2008 13:50:24 +0100
Message-ID: <a37929f0802270450x7318a276o1789533e7224b123@mail.gmail.com>
References: <a37929f0802251403q36ef6306wa30298dbded0d8ed@mail.gmail.com>
	 <20080226201441.GA15796@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.188]:2674 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816AbYB0Mu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 07:50:29 -0500
Received: by ti-out-0910.google.com with SMTP id 28so1994130tif.23
        for <netdev@vger.kernel.org>; Wed, 27 Feb 2008 04:50:27 -0800 (PST)
In-Reply-To: <20080226201441.GA15796@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 9:14 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Miroslav Kratochvil <exa.exa@gmail.com> :
>  [...]
>
> > Many users who have onboard Realtek 8168 network controllers in
>  > combination with nVidia hardware (mostly nVidia graphic card and/or
>  > nForce motherboard (MCP5x) ) experience still-not-very-explained
>  > hangup triggered by heavy network usage which fills a tx buffer, and
>  > (speculation) causes race condition on irq sharing, resulting in
>  > absolute freeze (not oops/panic). On all affected machines I've seen
>  > this fix solved the problem:
>
>  Where can the reports of these users be found ?
>
>  --
>  Ueimor
>

Well I would be happy if I had "reports", it basically looks like that
someone complains on IRC and this fixes his problem. No kernel dumps
and/or logs can be obtained (because of hard freeze). If you wanted
some information about the machines, please specify what exactly do
you want to see ("classic" logs like dmesg tell nothing. :( ) All of
the users have device 10ec:8168 (rev 01), and all have the NIC's
interrupt shared with something, mostly with nvidia. This is from my
laptop:

exa@exabook ~ $ grep eth0 /proc/interrupts
 11:       1242     291965   IO-APIC-fasteoi   yenta, ohci_hcd:usb2,
nvidia, eth0
exa@exabook ~ $ dmesg |grep RTL8
[   11.043631] eth0: RTL8168b/8111b at 0xffffc2000002a000,
4c:00:10:3b:83:ad, XID 38000000 IRQ 11


...also, notice that #defined buffer sizes are the only major
difference between kernel and Realtek's r8168 driver.

I will try to gather some more information about the problem. If some
access to a box with 8168 could help you, tell me.

thanks in advance,
[exa]
