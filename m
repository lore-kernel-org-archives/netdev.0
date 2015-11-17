From: Alexander Aring <alex.aring@gmail.com>
Subject: RFC: right userspace interface for providing 6lowpan contexts
Date: Wed, 18 Nov 2015 00:03:57 +0100
Message-ID: <20151117230332.GA6219@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-bluetooth@vger.kernel.org, linux-wpan@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de, marcel@holtmann.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37869 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932286AbbKQXEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 18:04:05 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recently sent some 6lowpan stateful compression patches to netdev. It
provides to setup 6lowpan contexts entries (ipv6 prefixes and prefix-length
by id) via debugfs manually at the moment.

This means, it works when all other "network nodes" also sets the same
ID's inside the table _manually_.

Well, it exists a RFC (and others) [0] to share the prefixes (contexts) inside
the network without manually manipulate the tables.

The rfc6775 describes new ICMPv6 option fields and ICMPv6 messages. I
want to talk about the ICMPv6 messages which are handled by userspace to
handle the necessary option fields.

The case is now, rfc6775 describes 6CO option fields for RA [1]. For this
reason we need an userspace interface to manipulate/get the current
context entries which are currently stored inside the kernel.

These context tables are:

 - A per interface declaration.
 - Maximum 16 entries.
 - Provides: ID, address prefix (can also 128 bit) and prefix-len

My question is what would be the best to do a userspace interface:

Note:
 These context tables should only available for 6LoWPAN interface types,
 which means: ARPHRD_6LOWPAN.

- netlink entry?
   - RTNL netlink?
   - 6lowpan netlink?
     - We don't currently has any netlink connection for net/6lowpan
       branch, but it's possible to add one special "6lowpan" netlink
       family to provide all 6LoWPAN configuration which belongs to
       ARPHRD_6LOWPAN. We need such interface of course for other
       settings as well.
- per interface, sysfs entry
  - should _maybe_ looks like the debugfs entries.

Thanks for any suggestion.

- Alex

[0] https://tools.ietf.org/html/rfc6775
[1] https://tools.ietf.org/html/rfc6775#section-5.4
