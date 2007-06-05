From: noboru.obata.ar@hitachi.com
Subject: Re: [RFC] Failover-friendly TCP retransmission
Date: Tue, 05 Jun 2007 22:05:36 +0900 (JST)
Message-ID: <20070605.220536.73364034.noboru.obata.ar@hitachi.com>
References: <XNM1$2$0$3$$2$8$4$A$2004314U46640bd2@hitachi.com>
    <p738xazbwha.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:35345 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757668AbXFENGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 09:06:04 -0400
Received: from mlsv16.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id 87BDC37C82
	for <netdev@vger.kernel.org>; Tue,  5 Jun 2007 22:06:01 +0900 (JST)
In-Reply-To: <p738xazbwha.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andi,

Andi Kleen <andi@firstfloor.org> writes:
> > Please note first that I want to address physical failures by
> > the failover-capable network devices, which are increasingly
> > becoming important as Xen-based VM systems are getting popular.
> > Reducing a single-point-of-failure (physical device) is vital on
> > such VM systems.
> 
> Just you typically still have lots of other single points of failures in 
> a single system, some of them quite less reliable than your typical
> NIC. But at least it gives impressive demos when pulling ethernet cables @)

Indeed :-)


> > If TCP retransmission misses the time frame between event #1 and
> > #3 in Background above (between 20 and 30sec since network
> > failure), a failure causes the system-level failover where the
> > network-device-level failover should be enough.
> 
> You should probably make sure that the device ends up returning the
> right NET_XMIT_* code for such drops to TCP, in particular
> NET_XMIT_DROP. This might require slight driver interface
> changes. Also right now it only affects the congestion window, I think, 
> it  might be reasonable to let it affect the timer backoff too.

Well, I don't think it can be a help.

Your suggestion, to utilize NET_XMIT_* code returned from an
underlying layer, is done in tcp_transmit_skb.

But my problem is that tcp_transmit_skb is not called during a
certain period of time.  So I'm suggesting to cap RTO value so
that tcp_transmit_skb gets called more frequently.

Does it make sense, Andi?

Regards,

-- 
OBATA Noboru (noboru.obata.ar@hitachi.com)
