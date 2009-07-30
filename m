From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bonding ALB sends bogus packets
Date: Thu, 30 Jul 2009 13:35:45 -0700
Message-ID: <20090730133545.77e5a76a@nehalam>
References: <20090730130656.680e9152@nehalam>
	<22132.1248985699@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>, bonding-devel@lists.sf.net,
	netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41760 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751876AbZG3Ufv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 16:35:51 -0400
In-Reply-To: <22132.1248985699@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Jul 2009 13:28:19 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
> >The bonding ALB mode builds packets with type, ETH_P_LOOP.
> >
> >Well ETH_P_LOOP is defined as 0x0060 which looks completely bogus.
> >All Ethernet types less than 1536 are interpreted as 802.2 frames.
> >The result is that the resulting packet looks like a bogus 802.2
> >frame to the other host (or switch).  I have no idea what the 
> >initial design was or what the purpose of this code is, but it
> >should either send a real packet or nothing at all.
> 
> 	I've looked at that code before, too, although I hadn't noticed
> that ETH_P_LOOP is under the limit for interpretation as a length
> instead of a type.
> 
> 	I believe the purpose of the code is to update the switch's MAC
> address table for the port and insure it's correct, since the alb mode
> can move MAC addresses around amongst the set of slaves.
> 
> 	-J

Then it ought to send an ARP or at least a real-looking 802.2 packet.
Also, if the purpose was to update switch MAC table, why does it need
to do it so often, rather than only when MAC address is swapped.
