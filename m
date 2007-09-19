From: Roland Dreier <rdreier@cisco.com>
Subject: Re: new NAPI interface broken
Date: Wed, 19 Sep 2007 08:33:51 -0700
Message-ID: <adafy1ak6u8.fsf@cisco.com>
References: <200709071137.02801.ossthema@de.ibm.com>
	<20070914.151252.85399360.davem@davemloft.net>
	<200709181815.45954.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:49237 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbXISPdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 11:33:53 -0400
In-Reply-To: <200709181815.45954.ossthema@de.ibm.com> (Jan-Bernd Themann's message of "Tue, 18 Sep 2007 18:15:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > One other thing I observed is that I can not unload the module as the
 > ref counter of the eth device is too low. I haven't tracked down the 
 > source of this problem yet.

I suspect that this is because netif_rx_reschedule() was missing a
dev_hold() to match the dev_put() in netif_rx_complete().  Dave merged
a fix for that problem yesterday, so current net-2.6.24 should be OK.
Let us know if it's not OK, because then there's another bug...

 - R.
