From: John <linux@8192.net>
Subject: [PATCH V3 0/2] bonding support for IPv6 transmit hashing
Date: Fri, 29 Jun 2012 23:17:05 -0700
Message-ID: <4FEE99E1.9050905@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp153.dfw.emailsrvr.com ([67.192.241.153]:38185 "EHLO
	smtp153.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517Ab2F3G0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2012 02:26:39 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by smtp32.relay.dfw1a.emailsrvr.com (SMTP Server) with ESMTP id 44ECD5046F
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 02:17:02 -0400 (EDT)
Received: by smtp32.relay.dfw1a.emailsrvr.com (Authenticated sender: john-AT-8192.net) with ESMTPSA id 10D9A50396
	for <netdev@vger.kernel.org>; Sat, 30 Jun 2012 02:17:01 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the "bonding" driver does not support load balancing outgoing
traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4)
are currently supported; this patch adds transmit hashing for IPv6
(and TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support
in the bonding driver.

The algorithm chosen (xor'ing the bottom three quads and then xor'ing
the bottom three bytes of that) was chosen after testing almost 400,000
unique IPv6 addresses harvested from server logs. This algorithm
had the most even distribution for both big- and little-endian
architectures while still using few instructions.

Fragmented IPv6 packets are handled the same way as fragmented
IPv4 packets, ie, they are not balanced based on layer 4
information. Additionally, IPv6 packets with intermediate headers
are not balanced based on layer 4 information. In practice these
intermediate headers are not common and this should not cause any
problems, and the alternative (a packet-parsing loop and look-up table)
seemed slow and complicated for little gain.

This is an update to a prior patch I submitted. This version includes
a clarified description, more thorough bounds checking, updates
functions to call bond_xmit_hash_policy_l2 rather than re-implement
the same logic, incorporates Jay's style suggestions, and patches
against net-next. Patch has been tested and performs as expected.

John
