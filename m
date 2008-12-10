From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 0/9] netns: make IPv6 multicast forwarding per-namespace - V2
Date: Wed, 10 Dec 2008 17:03:01 +0100
Message-ID: <20081210160301.883947374@theryb.frec.bull.fr>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:42109 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697AbYLJQD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 11:03:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset introduces the support for network namespaces in IPv6
multicast forwarding code (net/ipv6/ip6mr.c).

The first patches in the series moves global data from ip6mr.c into 
struct netns_ipv6 to prepare netns support. Data are still referenced in
init_net only. One of these patches makes the related /proc entries
per-namespace.

The last patch does the main job and enables the network namespace support
by replacing all the init_net references with the proper net retrieved
from sockets or net devices.

The patchset applies on top of net-next-2.6

Changelog
=========
V2:
* Counter cache_resolve_queue_len for unresolved entries must also be
  per-namespace if we don't want to be limited to 10 unresolved entries
  for all the netns. New patch:
  "netns: ip6mr: declare counter cache_resolve_queue_len per-namespace"
* Reordered the series a bit

Regards,
Benjamin

