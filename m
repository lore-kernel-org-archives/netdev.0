From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: r8169: is the work queue is initialized at wrong place?
Date: Fri, 19 Jul 2013 00:41:57 +0200
Message-ID: <2387149.B9WVEQm2aY@al>
References: <5838023.rAHnY47tlv@al> <20130718215343.GA25075@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:64706 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759024Ab3GRWmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 18:42:02 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so2048155eaj.13
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 15:42:00 -0700 (PDT)
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
Will this also work with multiple adapters? I currently have an on-board chip 
using the r8169 driver and a separate PCI card.

> I do not see how the current code could hurt but it's really ugly.
When I googled for the warning, I found some hint about something not being 
initialized. From that I guessed that rtl_open is never called when the 
network interface is not brought up (which seems to match the documentation of 
struct net_device_ops[1]).

> > I do not know what this smp_mb is used for in this context, so I leave
> > an appropriate patch up to you.
> 
> It does not cost much and it enforces an initialized state. IRQ - real
> or shared ones - and napi poll could happen really soon after this point.
> There is probably some implicit memory barrier the driver could rely on.
> It would be a bit hackish though.
>
> I'll check the history and cook a patch.

Thanks.

Regards,
Peter

 [1]: http://lxr.free-electrons.com/source/include/linux/netdevice.h#L716
