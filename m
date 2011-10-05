From: Ben Greear <greearb@candelatech.com>
Subject: IPv4 multicast and mac-vlans acting weird on 3.0.4+
Date: Wed, 05 Oct 2011 09:46:38 -0700
Message-ID: <4E8C89EE.3090600@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:56250 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934476Ab1JEQqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 12:46:38 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p95Gkcdj016364
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 5 Oct 2011 09:46:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is on a hacked 3.0.4 kernel...

I am seeing an issue where an IPv4 mcast receiver will not receive
a 1473 or larger byte mcast message, but will receive a 1472.  The difference
being that 1473 ends up being two packets on the wire.  It works on
802.1Q VLANs, VETH interfaces and real Ethernet.  It does not work
on a mac-vlan hanging off the VETH.

I see packets received on the macvlan in tshark, and they appear correct.  No
obvious errors in the macvlan port stats or netstat -s,
and the 'ss' tool doesn't appear to support UDP sockets at all.

So, I'm about to go digging into the code, but if anyone has any
suggestions for places to look, please let me know!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
