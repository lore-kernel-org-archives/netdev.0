From: Chris Friesen <chris.friesen@genband.com>
Subject: bonding and SR-IOV -- do we need arp_validation for loadbalancing
 too?
Date: Tue, 24 Jul 2012 09:57:03 -0600
Message-ID: <500EC5CF.3080400@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	andy@greyhouse.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og127.obsmtp.com ([64.18.2.210]:56828 "EHLO
	exprod7og127.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916Ab2GXP5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 11:57:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We've been starting to look at bonding VFs from separate physical 
devices in a guest, but we've run into a problem.

The host is bonding the corresponding PFs, and it uses arp monitoring. 
  What we have found is that any broadcast traffic from the guest (if 
they enable arp monitoring, for example) will be seen by the internal L2 
switch of the NIC and sent up into the host, where the bonding driver 
will count it as incoming packets and use it to mark the link as good.

The only solutions I've been able to come up with are:
1) add arp validation for load balancing modes as well as active-backup.
2) put all the VMs in VLANs

Anyone have any better ideas?

Chris


-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
