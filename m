From: Felix Fietkau <nbd@openwrt.org>
Subject: bridge igmp snooping implementation
Date: Tue, 25 Sep 2012 12:18:21 +0200
Message-ID: <506184ED.5040104@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:44397 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab2IYKSY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 06:18:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'v been looking at the bridge IGMP snooping code and I noticed that it
appears to not keep track of multicast group member IP addresses. Is
this intentional?

It seems to me that this would lead to issues when multiple members of
the same multicast group are behind the same bridge port, and one of
them leaves.

I'm currently looking into adding a feature that allows bridge ports to
be configured to selectively turn multicast traffic into unicast
traffic. For this I would need to change the code to keep track of
member IP and MAC addresses.

This helps a lot on 802.11, where unicast is often much cheaper than
multicast, even when sending out duplicate packets (higher data rates
and aggregation heavily reduce airtime utilization).

- Felix
