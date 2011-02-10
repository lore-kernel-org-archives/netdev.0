From: Ben Greear <greearb@candelatech.com>
Subject: Problem with igb and vlans in 2.6.38-rc4
Date: Thu, 10 Feb 2011 09:57:01 -0800
Message-ID: <4D5426ED.7000801@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33203 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab1BJR5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 12:57:02 -0500
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p1AHv1VP007267
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 10 Feb 2011 09:57:01 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We have a user-space app that uses packet-sockets to grab and send
Ethernet frames (basically a user-space bridge).

This has stopped working for VLANs unless we set the physical
port MTU to be vlan-MTU + 4 (ie, 1504 for standard MTU size vlan frames).
I think this started post 2.6.34 kernel..but not exactly sure at this
time.

The test setup is essentially:

client -- vlan 5 -- [ eth4 {software-bridge} eth3 ] -- vlan 5 -- server

The software bridge machine has no VLANs enabled..it is supposed to just
read Ethernet frames from one port and xmit out the other.

The bridge machine sees rx-length errors, and if only one port is
set to 1504, the other shows xmit errors (since it doesn't like sending
a frame 4 bytes larger than MTU probably).

This used to work, and I'm hoping this change wasn't done on purpose.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

