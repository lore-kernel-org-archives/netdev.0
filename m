From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: is the work queue is initialized at wrong place?
Date: Thu, 18 Jul 2013 23:53:43 +0200
Message-ID: <20130718215343.GA25075@electric-eye.fr.zoreil.com>
References: <5838023.rAHnY47tlv@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Peter Wu <lekensteyn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39983 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759308Ab3GRVxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 17:53:54 -0400
Content-Disposition: inline
In-Reply-To: <5838023.rAHnY47tlv@al>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Wu <lekensteyn@gmail.com> :
[...]
> However, this queue is only initialized in rtl_open:
> 
> 6673         INIT_WORK(&tp->wk.work, rtl_task);
> 6674 
> 6675         smp_mb();
> 
> Shouldn't this INIT_WORK be done in rtl_init_one ?

(or cancel_work_sync in rtl8169_close to reduce the scope)

I do not see how the current code could hurt but it's really ugly.

> I do not know what this smp_mb is used for in this context, so I leave
> an appropriate patch up to you.

It does not cost much and it enforces an initialized state. IRQ - real
or shared ones - and napi poll could happen really soon after this point.
There is probably some implicit memory barrier the driver could rely on.
It would be a bit hackish though.

I'll check the history and cook a patch.

Thanks.

-- 
Ueimor
