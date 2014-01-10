From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 0/3] Improve tracing at the driver/core boundary
Date: Fri, 10 Jan 2014 22:15:39 +0000
Message-ID: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:23233 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751790AbaAJWPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 17:15:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches add static tracpeoints at the driver/core boundary which
record various skb fields likely to be useful for datapath debugging.
On the TX side the boundary is where the core calls ndo_start_xmit, and
on the RX side it is where any of the various exported receive functions
is called.

The set of skb fields is mostly based on what I thought would be
interesting for sfc.

These patches are basically the same as what I sent as an RFC in
November, but rebased.  They now depend on 'net: core: explicitly select
a txq before doing l2 forwarding', so please merge net into net-next
before trying to apply them.  The first patch fixes a code formatting
error left behind after that fix.

Ben.

Ben Hutchings (3):
  net: Fix indentation in dev_hard_start_xmit()
  net: Add net_dev_start_xmit trace event, exposing more skb fields
  net: Add trace events for all receive entry points, exposing more skb
    fields

 include/trace/events/net.h | 158 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c             | 105 ++++++++++++++++++------------
 2 files changed, 222 insertions(+), 41 deletions(-)


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
