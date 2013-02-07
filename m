From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH 1/1] net: fec: fix miss init spinlock
Date: Thu, 7 Feb 2013 09:42:40 +0800
Message-ID: <CAHrpEqR9u5t8fZOYRq4k_vTsEORVsNwa2C_rLaxesmusY5e9-Q@mail.gmail.com>
References: <1359708986-23634-1-git-send-email-Frank.Li@freescale.com>
	<loom.20130204T174808-896@post.gmane.org>
	<CAHrpEqSXhEBQpnR60mjP67gbVWNemfa3tTuoDTKipej_6QQ62g@mail.gmail.com>
	<loom.20130205T111507-687@post.gmane.org>
	<CAHrpEqTsUjWjxY3_C4kGL_S0pgpYawgBaSip3DEnZd3CY1hn0A@mail.gmail.com>
	<51125F28.4000409@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jim Baxter <jim_baxter@mentor.com>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:55953 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757493Ab3BGBml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 20:42:41 -0500
Received: by mail-wi0-f172.google.com with SMTP id ez12so6291055wid.11
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 17:42:40 -0800 (PST)
In-Reply-To: <51125F28.4000409@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/2/6 Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com>:
> On 2/6/2013 1:50 AM, Frank Li wrote:
>>
>>
>> It is not easy to fix. Need put tx to NAPI poll function.
>> I will work on that after China New year holiday
>
>
> Converting Tx to NAPI is the best solution, but you can put a temporary fix
> in.  Don't take a spin_lock() in fec_enet_tx(), rather take a
> spin_lock_irqsave() since you're still in HARDIRQ context.
>

That's not help.
skb_tx_timestamp function call some function using lock, which lock
used at the other place, just call spinlock_bh.

skb_tx_timestamp seem be called only in softirq context, not irq context.

> -PJ
