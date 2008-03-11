From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: Ixgbe question
Date: Mon, 10 Mar 2008 18:01:24 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52049D5CD4@orsmsx418.amr.corp.intel.com>
References: <47D5A7A4.30606@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Ben Greear" <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8529 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751109AbYCKBFZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2008 21:05:25 -0400
Content-class: urn:content-classes:message
In-Reply-To: <47D5A7A4.30606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> I have a pair of IXGBE NICs in a system, and notice a strange
> case where the NIC is not always 'UP' after my programs finish
> trying to configure it.  I haven't noticed this with any other
> NICs, but I also just moved to 2.6.23.17 from 23.9 and 23.14.
> 
> I see this in the logs:
> 
> ADDRCONF(NETDEV_UP): eth0: link is not ready
> 
> It would seem to me that we should be able to set the admin
> state to UP, even if the link is not up??
> 
> Kernel is 2.6.23.17 plus my hacks.   Ixgbe driver is version
> 1.3.7.8-lro. 
> 
> Hardware is quad-core Intel, 2 build-in e1000, 2-port ixgbe (CX4)
> chipset NIC 
> on a pcie riser.

addrconf_notify() is printing that message, and I see it if you enable
IPv6 on an interface.  I don't think it is ixgbe specific.

it doesn't depend or preclude administrative UP, it is from the notify
handler getting a NETDEV_UP message, regardless of link state. 

you'll see some other message like:
ADDRCONF(NETDEV_CHANGE): eth6: link becomes ready

when you plug in the cable, all courtesy of Ipv6

Jesse
