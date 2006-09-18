From: David Miller <davem@davemloft.net>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 18 Sep 2006 14:22:47 -0700 (PDT)
Message-ID: <20060918.142247.14844785.davem@davemloft.net>
References: <20060918162847.GA4863@ms2.inr.ac.ru>
	<200609181850.22851.ak@suse.de>
	<20060918210321.GA4780@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, master@sectorb.msk.ru, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:21392
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751924AbWIRVXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 17:23:15 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060918210321.GA4780@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Tue, 19 Sep 2006 01:03:21 +0400

> 1. It even does not disable possibility to record timestamp inside
>    driver, which Alan was afraid of. The sequence is:
> 
> 	if (!skb->tstamp.off_sec)
>                 net_timestamp(skb);
> 
> 2. Maybe, netif_rx() should continue to get timestamp in netif_rx().
> 
> 3. NAPI already introduced almost the same inaccuracy. And it is really
>    silly to waste time getting timestamp in netif_receive_skb() a few
>    moments before the packet is delivered to a socket.
> 
> 4. ...but clock source, which takes one of top lines in profiles
>    must be repaired yet. :-)

Ok, ok, but don't we have queueing disciplines that need the timestamp
even on ingress?
