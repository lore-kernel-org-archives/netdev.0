From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: RE: Question regarding failure utilizing bonding mode 5
 (balance-tlb)
Date: Sat, 3 Aug 2013 07:47:15 +0000
Message-ID: <979A8436335E3744ADCD3A9F2A2B68A52ACF96BB@SJEXCHMB10.corp.ad.broadcom.com>
References: <1375333968.21294.30.camel@lb-tlvb-yuvalmin.il.broadcom.com>
 <7717.1375412975@death.nxdomain>
 <979A8436335E3744ADCD3A9F2A2B68A52ACF959B@SJEXCHMB10.corp.ad.broadcom.com>
 <12779.1375476808@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>
To: "Jay Vosburgh" <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3530 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab3HCHrd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 03:47:33 -0400
In-Reply-To: <12779.1375476808@death.nxdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Again, I think the permanent address is restored only when the bond
> >releases the slave, which I don't think happens when the slave is unloaded.
> 
> 	Ah, ok, I was understanding "unloaded" to mean "remove from the
> bond."  I think you actually mean "set administratively down," e.g., "ip
> link set dev slave down" or the like.  I don't think mere loss of
> carrier would trigger the sequence of events, because that won't go
> through a dev_close / dev_open cycle.
> 
> 	Doing that (an admin down / up bounce) would, indeed, cause a
> failover, but the bond will not reprogram the MAC on the slave (it
> presumes that a fail / recovery will not disrupt the MAC address, which
> is apparently not true in this instance).
> 
> 	I'll have to look at the code a bit, but for now can you confirm
> that what you actually mean is, essentially:
> 
> 	Given a bond0 with two slaves, eth0 and eth1, in tlb mode, eth0
> being the active,
> 
> 	1) "ip link set dev eth0 down" which will fail over to eth1
> 		(swapping the contents of their dev_addr fields).
> 
> 	2) "ip link set dev eth0 up" eth0 comes back up, reprograms its
> 		MAC to the wrong thing (what was in dev_addr).
> 
> 	3) repeat steps 1 and 2 for eth1
> 
> 	Is this correct?
> 

Yes, sorry for the earlier confusion.
I think in the case described `alb_swap_mac_addr()' will be called, 
replacing eth0 and eth1's dev_addr, causing eth0 to have dev_addr
which defers from  the bond device's. Once eth0 reloads, it will use
the different MAC address for configuring FW/HW.
