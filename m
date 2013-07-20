From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: r8169: is the work queue is initialized at wrong place?
Date: Sun, 21 Jul 2013 01:22:29 +0200
Message-ID: <1603372.dtUZthYKQE@al>
References: <5838023.rAHnY47tlv@al> <20130718215343.GA25075@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:50336 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938Ab3GTXWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 19:22:34 -0400
Received: by mail-ee0-f48.google.com with SMTP id b47so3058848eek.35
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 16:22:33 -0700 (PDT)
In-Reply-To: <20130718215343.GA25075@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 18 July 2013 23:53:43 Francois Romieu wrote:
> Peter Wu <lekensteyn@gmail.com> :
> [...]
> 
> > However, this queue is only initialized in rtl_open:
> > 
> > 6673         INIT_WORK(&tp->wk.work, rtl_task);
> > 6674
> > 6675         smp_mb();
> > 
> > Shouldn't this INIT_WORK be done in rtl_init_one ?
> 
> (or cancel_work_sync in rtl8169_close to reduce the scope)
> 
> I do not see how the current code could hurt but it's really ugly.
> 
> > I do not know what this smp_mb is used for in this context, so I leave
> > an appropriate patch up to you.
> 
> It does not cost much and it enforces an initialized state. IRQ - real
> or shared ones - and napi poll could happen really soon after this point.
> There is probably some implicit memory barrier the driver could rely on.
> It would be a bit hackish though.
> 
> I'll check the history and cook a patch.

Just to let you know, I am working on a patch since I encountered a 
different(related?) issue that spams the syslog.The patch and partial analysis 
is ready but untested.

Regards,
Peter
