From: Santwona.Behera@Sun.COM
Subject: [PATCH 0/3] Add support for RX packet classification in a network
 device
Date: Mon, 09 Feb 2009 15:12:11 -0800
Message-ID: <4990B84B.5040108@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:40009 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbZBIXMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 18:12:34 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n19NCQbY010588
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 15:12:28 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KET00400LJ7SK00@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Mon,
 09 Feb 2009 15:12:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of 3 patches was originally posted on December 22, '08. This is 
a respin of the patches, incorporating feedback received from the 
original posting.

Added new interfaces to ethtool to add, delete and manage rules for RX
packet classification (network 5-tuple filtering configuration) with niu
driver as the first user of this API.

This feature has 3 related patches:

1. An ethtool application patch.
2. A kernel patch for the ethtool interface.
3. A kernel patch for the niu driver that implements the ethtool config
ioctl functions.

Following is a short description of this feature, following the
original proposal posted in Sept '08.

- The ethertool application has a new interface to add a classification
rule and the target RX ring for packets that match the rule. The rules
are added on a per port basis. Each new rule that is added is 
represented by a unique ID. This ID has to be used by the user to delete
the rule or query the details of the rule (both interfaces provided via 
ethertool).

- Here is the list of cmds/interfaces that have been added to ethertool 
(as suboptions in the RX network flow classification option) to achieve
this:

   - get the number of RX rings available to this port.
   - add a rule (flow-tuple/mask to RX ring mapping)
   - delete a rule
   - query a particular rule or all rules for this port

- Within ethertool, there is a manager for these rules that orders the
rules on a per port basis using longest prefix first ordering. This 
manager assumes low-to-high order for matching the rules in the network 
device.

- In the niu driver, there is a local array of the tcam_entries (for
supporting queries from ethertool).

- There is no protection against inconsistencies between the tcam
entries and the user view of it that can arise if multiple instances of
ethertool happen to write the same rule (tcam_entry).


Thanks,

--santwona
