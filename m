From: "Chris Friesen" <cfriesen@nortel.com>
Subject: dhcp/bonding interaction question
Date: Tue, 23 Sep 2008 09:24:32 -0600
Message-ID: <48D90A30.8000701@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04f.nortel.com ([47.129.242.57]:63642 "EHLO
	zcars04f.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbYIWPc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 11:32:29 -0400
Received: from zcarhxs1.corp.nortel.com (zcarhxs1.corp.nortel.com [47.129.230.89])
	by zcars04f.nortel.com (Switch-2.2.6/Switch-2.2.0) with ESMTP id m8NFOme20391
	for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 15:24:48 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've recently run into an interesting issue, and I was hoping to get 
some suggestions.

We've got a boot server configured with two bonded links using the XOR 
tx mode.  Another board comes up.  It's got two links which will 
eventually be bonded.  It issues a DHCP request to the server over one 
of the links, which arrives on one of the bonded slaves.  The server 
sends a reply, but the XOR results in the packet being sent back via the 
other slave.  On the booting blade the xid in the packet doesn't match 
the xid for the device on which the packet was received, so the packet 
is dropped.

What's the proper solution here?  Should dhcpd be forcing reply packets 
out the slave on which the packet was received?

Chris
