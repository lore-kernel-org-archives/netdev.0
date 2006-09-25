From: Mark Lord <mlord@pobox.com>
Subject: Wireless router with 2 MACs: okay with mswin, not with Linux ?
Date: Mon, 25 Sep 2006 17:14:38 -0400
Message-ID: <451846BE.5030704@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from proof.pobox.com ([207.106.133.28]:14296 "EHLO proof.pobox.com")
	by vger.kernel.org with ESMTP id S1751347AbWIYVOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 17:14:42 -0400
To: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I'm posting this from a hotel which has a wireless AP (B+G) for guests.
It took me several hours to figure out how to get the connection working
with my 2.6.18 notebook -- works just fine with other guests' mswin machines.

WEP is used, and is set up and working just fine:  I can access the AP's
built-in web interface without any troubles.  But..

The AP has two MAC addresses:

# arping -c1 192.168.1.1 -I eth1
ARPING 192.168.1.1 from 192.168.1.53 eth1
Unicast reply from 192.168.1.1 [00:11:F5:BA:67:AA]  2.164ms
Unicast reply from 192.168.1.1 [00:11:F5:77:38:C2]  5.696ms
Sent 1 probes (1 broadcast(s))
Received 2 response(s)
#

The first MAC can connect locally to the AP, but not outside.
The second MAC can connect locally and/or outside.

Linux only seems to ever use the first (no good) MAC for the AP,
rather than the second.  Whenever I try an outside access, the AP 
sends a gratuitous ARP reply, telling my machine to use the other MAC.
This seems to be ignored by Linux, but heeded by Windows.

For now, I've just written a small script to detect such a situation,
and to set a static ARP mapping for the second MAC.  This works, but is way
beyond "normal usage" for most people.

Surely there's a flag or something to have the kernel cope with this?

????
-- 
Mark Lord
Real-Time Remedies Inc.
mlord@pobox.com

