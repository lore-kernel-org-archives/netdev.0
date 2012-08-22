From: Chris Friesen <chris.friesen@genband.com>
Subject: bonding: why zero out bond_dev->dev_addr when last slave removed?
Date: Wed, 22 Aug 2012 14:48:12 -0600
Message-ID: <5035458C.9000804@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og111.obsmtp.com ([64.18.2.175]:58616 "EHLO
	exprod7og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933231Ab2HVUu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 16:50:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I've got a couple questions about the bonding driver.


I was wondering about the rationale for zeroing out bond_dev->dev_addr 
when the last slave is removed from the bond.

Assuming bond0 is currently using the mac address of eth0 then doing

ifenslave -d bond0 eth0
ifenslave -d bond0 eth1
ifenslave bond0 eth1
ifenslave bond0 eth0

ends up changing the MAC address of the bond link. Given that the bond 
itself stays up during this time, why don't we let the bond device keep 
it's previous MAC address (at least if fail_over_mac is zero)?

Is this to account for the case where we move the bond to totally 
different devices such that the old MAC no longer belongs to one of the 
slaves but instead belongs to a NIC outside the bond?

Chris


-- 

Chris Friesen
Software Designer

3500 Carling Avenue
Ottawa, Ontario K2H 8E9
www.genband.com
