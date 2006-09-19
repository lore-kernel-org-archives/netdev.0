From: David Miller <davem@davemloft.net>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Tue, 19 Sep 2006 12:47:51 -0700 (PDT)
Message-ID: <20060919.124751.24100694.davem@davemloft.net>
References: <200609181850.22851.ak@suse.de>
	<20060918211759.GB31746@tentacle.sectorb.msk.ru>
	<20060918220038.GB14322@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: master@sectorb.msk.ru, ak@suse.de, hawk@diku.dk,
	harry@atmos.washington.edu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:32197
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1752009AbWISTrq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 15:47:46 -0400
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <20060918220038.GB14322@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Tue, 19 Sep 2006 02:00:38 +0400

> * I do not undestand what the hell dhcp needs timestamps for.

I can't even find a reference to SIOCGSTAMP in the
dhcp-2.0pl5 or dhcp3-3.0.3 sources shipped in Ubuntu.

But I will note that tpacket_rcv() expects to always get
valid timestamps in the SKB, it does a:

	if (skb->tstamp.off_sec == 0) { 
		__net_timestamp(skb);
		sock_enable_timestamp(sk);
	}

so that it can fill in the h->tp_sec and h->tp_usec
fields.
