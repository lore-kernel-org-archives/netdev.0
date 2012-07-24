From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: bonding and SR-IOV -- do we need arp_validation for loadbalancing
 too?
Date: Tue, 24 Jul 2012 14:38:36 -0600
Message-ID: <500F07CC.4030201@genband.com>
References: <500EC5CF.3080400@genband.com> <20120724164220.GA1721@minipsycho.orion> <21683.1343153629@death.nxdomain> <500F032D.3070104@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og121.obsmtp.com ([64.18.2.20]:41065 "EHLO
	exprod7og121.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab2GXUje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:39:34 -0400
In-Reply-To: <500F032D.3070104@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/24/2012 02:18 PM, Chris Friesen wrote:
>
> A more general solution might be to have the device driver also track 
> the time of the last incoming packet that came from the external 
> network (rather than a VF) and having the bond driver ignore those 
> packets for the purpose of link health.  Doing this efficiently would 
> likely require some kind of hardware support though--as an example the 
> 82599 seems to support this with the "LB" bit in the rx descriptor.

That should of course be reversed.  We want the bond driver to only use 
the packets from the external network for the purpose of link health.

Does anyone other than bonding actually care about dev->last_rx?  If not 
then we could just change the drivers to only set it for external packets.

Chris
