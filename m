From: dhananjay.tembe@calsoftinc.com
Subject: Doubt...
Date: Mon, 19 Mar 2007 02:33:48 +0530 (IST)
Message-ID: <1400.67.169.183.149.1174251828.squirrel@webmail.calsoftinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inbox2.nyi.net ([64.147.100.114]:56618 "HELO inbox2.nyi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751165AbXCRVKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 17:10:30 -0400
Received: from webmail.calsoftinc.com (mail.calsofthq.com [172.16.0.7])
	by mail.calsofthq.com (8.13.6/8.13.6) with ESMTP id l2IL3mCE014940
	for <netdev@vger.kernel.org>; Mon, 19 Mar 2007 02:33:48 +0530
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
      I am facing a problem when I run tc on the bonded nic cards.
When I run tc on a single nic card, it worked perfectly fine. But when I
run tc on a bond of two nics, tc gives poor performance.  The two nics
were bonded in round-robin (load balancing) mode. I created a qdisc, class
and a filter as follows:

tc qdisc add dev bond0 root handle 1: htb
tc class add dev bond0 parent 1: classid 1:1 htb rate 240mbps
tc class add dev bond0 parent 1:1 classid 1:2 htb rate 50 ceil 50 quantum
1500

I started a TCP traffic between this bond (2gbit bandwidth) and a remote
nic (1gbit bandwidth).
Without qos, bond was transmitting at 960Mbps.
After I executed above mentioned commands, it was expected that the bond
will transmit at 400Mbps but it was transmitting only at 70Mbps.
Same thing was observed with different qos rates for class 1:2, outbound
traffic through bond was very less than the rate specified in the tc
command.

Is getting poor performance after running tc over a bond is a known issue?
Please help me with this issue.

Thanks and regards,
---Dhananjay.

