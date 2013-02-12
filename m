From: Chris Friesen <chris.friesen@genband.com>
Subject: how to handle bonding failover when using a bridge over the bond?
Date: Tue, 12 Feb 2013 17:19:50 -0600
Message-ID: <511ACE16.3080906@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og120.obsmtp.com ([64.18.2.18]:38243 "EHLO
	exprod7og120.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754500Ab3BLXUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 18:20:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've got a scenario that seems to be not well handled with the current 
bonding code in linux, but maybe I'm missing something.

I have a physical host with two ethernet links that are bonded together 
(active/backup).  Each link is connected to a separate L2 switch, which 
are in turn connected with a crosslink for redundancy.

The physical host is running multiple virtual machines each with a 
virtual adapter.  The virtual adapters and the bond are all bridged 
together to allow communication between the virtual machines, the host, 
and the outside world.

Now suppose one of the slave links fails. The bond device will failover 
to the other slave and send out a gratuitous arp on the newly active 
slave.  This will cause the L2 switches to update their lookup tables 
for the MAC address associated with the bond (so it now points to the 
newly active slave), but doesn't update the MAC addresses associated 
with the various virtual machines.  If someone on the network sends a 
packet to one of the virtual machines, the switch will try to send it 
over the failed slave.

What's the recommended solution for this?  The logical solution would 
seem to be to have something issue GARPs for each virtual machine when 
the bond device fails over, but there doesn't seem to be any way to 
register for notification (via rtnetlink for instance) when the bond 
fails over.  I could monitor for carrier loss, but that wouldn't work 
for the case where bonding is using arp monitoring.

Any suggestions?

Thanks,
Chris
