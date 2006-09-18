From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RFC] Re: high latency with TCP connections
Date: Mon, 18 Sep 2006 00:31:10 -0700 (PDT)
Message-ID: <20060918.003110.88477231.davem@davemloft.net>
References: <20060830100734.GA22235@isil.ipib.msu.ru>
	<20060904160045.GA15599@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:58309
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751309AbWIRHbS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:31:18 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060904160045.GA15599@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Mon, 4 Sep 2006 20:00:45 +0400

> Try enclosed patch. I have no idea why 9.997 sec is so magic, but I
> get exactly this number on my notebook. :-)
> 
> =================
> 
> This patch enables sending ACKs each 2d received segment.
> It does not affect either mss-sized connections (obviously) or connections
> controlled by Nagle (because there is only one small segment in flight).
> 
> The idea is to record the fact that a small segment arrives
> on a connection, where one small segment has already been received
> and still not-ACKed. In this case ACK is forced after tcp_recvmsg()
> drains receive buffer.
> 
> In other words, it is a "soft" each-2d-segment ACK, which is enough
> to preserve ACK clock even when ABC is enabled.
> 
> Signed-off-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

This looks exactly like the kind of patch I tried to formulate,
very unsuccessfully, last time this topic came up a year or
so ago.

It looks perfectly fine to me, would you like me to apply it
Alexey?
