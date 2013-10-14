From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [RFC PATCH 0/2] Improve tracing at the driver/core boundary
Date: Mon, 14 Oct 2013 15:39:12 +0100
Message-ID: <1381761552.1626.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:21421 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755072Ab3JNOjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 10:39:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add static tracpeoints at the driver/core boundary which
record various skb fields likely to be useful for datapath debugging.
On the TX side the boundary is where the core calls ndo_start_xmit, and
on the RX side it is where any of the various exported receive functions
is called.

The set of skb fields is mostly based on what I thought would be
interesting for sfc, and may need to be augmented to be more general.

Ben.

Ben Hutchings (2):
  net: Add net_dev_start_xmit trace event, exposing more skb fields
  net: Add trace events for all receive entry points, exposing more skb
    fields

 include/trace/events/net.h | 158 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             | 102 ++++++++++++++++++-----------
 2 files changed, 221 insertions(+), 39 deletions(-)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
