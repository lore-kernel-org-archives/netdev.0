From: "Laurent Chavey" <chavey@google.com>
Subject: bond_3ad.c: why does bond_3ad_set_carrier() check if the mac partnet mac is set.
Date: Thu, 31 May 2007 18:46:42 -0700
Message-ID: <97949e3e0705311846x65ba3eacjb11e68ba38e1ed38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:5263 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134AbXFABqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 21:46:46 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id l511kil4027200
	for <netdev@vger.kernel.org>; Thu, 31 May 2007 18:46:44 -0700
Received: from wr-out-0506.google.com (wrai23.prod.google.com [10.54.60.23])
	by zps36.corp.google.com with ESMTP id l511kf7C008334
	for <netdev@vger.kernel.org>; Thu, 31 May 2007 18:46:43 -0700
Received: by wr-out-0506.google.com with SMTP id i23so450628wra
        for <netdev@vger.kernel.org>; Thu, 31 May 2007 18:46:43 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

if a host configured with 802.3ad bond mode is connected to a switch
that does not support 802.3ad,  then an aggregator is selected as the
active aggregator (first link that has carrier in the slave list).
This is perfectly fine, since it lets at least one of the link become active.
(this was the behavior prior to 2.6.18)

In 2.6.18 and above, a new check for the partner mac address was added
before an aggregator's carrier is set on. If a host is  configured as
previously
described,  then no links will become active.

is that the intended behavior ?


-----
in the scenario described here, the partner mac address is always set to NULL.
so the statement is always false.

	if (agg && MAC_ADDRESS_COMPARE(&agg->partner_system, &null_mac_addr)) {
		if (!netif_carrier_ok(bond->dev)) {
			netif_carrier_on(bond->dev);
			return 1;
		}
		return 0;
	}
----
