From: John <linux@8192.net>
Subject: [PATCH 0/2] bonding: Doesn't support IPv6
Date: Fri, 28 Oct 2011 18:08:00 -0700
Message-ID: <4EAB51F0.6030105@8192.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp191.iad.emailsrvr.com ([207.97.245.191]:49892 "EHLO
	smtp191.iad.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417Ab1J2BQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Oct 2011 21:16:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the "bonding" driver does not support load balancing outgoing 
traffic in LACP mode for IPv6 traffic. IPv4 (and TCP or UDP over IPv4) 
are currently supported; this patch adds transmit hashing for IPv6 (and 
TCP or UDP over IPv6), bringing IPv6 up to par with IPv4 support in the 
bonding driver.

The algorithm chosen (xor'ing the bottom three quads and then xor'ing 
that down into the bottom byte) was chosen after testing almost 400,000 
unique IPv6 addresses harvested from server logs. This algorithm had the 
most even distribution for both big- and little-endian architectures 
while still using few instructions.

Fragmented IPv6 packets are handled the same way as fragmented IPv4 
packets, ie, they are not balanced based on layer 4 information. 
Additionally, IPv6 packets with intermediate headers are not balanced 
based on layer 4 information. In practice these intermediate headers are 
rare and this should not cause any problems, the alternative (a 
packet-parsing loop and look-up table) seemed slow and complicated for 
little gain.

This is an update to a prior patch I submitted. This version includes 
bounds checking not present in the original driver or my prior patch. 
Included with the patch is an update to the bonding documentation.

Patch has been tested and performs as expected.

John
