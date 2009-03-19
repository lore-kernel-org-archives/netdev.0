From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work properly
 in bridge
Date: Thu, 19 Mar 2009 09:50:03 +0100
Message-ID: <49C2073B.8060102@trash.net>
References: <20090314094911.GA3455@psychotron.englab.brq.redhat.com>	<20090315161217.7fa2c3a7@nehalam>	<20090316111127.GB3484@psychotron.englab.brq.redhat.com> <20090318.232003.30974750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, shemminger@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62637 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491AbZCSIuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 04:50:07 -0400
In-Reply-To: <20090318.232003.30974750.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jiri Pirko <jpirko@redhat.com>
> Date: Mon, 16 Mar 2009 12:11:28 +0100
> 
>> I can see two solutions. Either like my patch or somehow allow bridge to know
>> more MAC addressses per port (maybe netdev can be changed to know more then
>> one MAC address).
>>
>> Any thoughts?
> 
> The netdev struct already supports having a list of multiple unicast
> MAC addresses, it can probably be used and inspected for this.
> 
> I'll hold off on your patch until we make some more progress on
> this discussion.

 From reading the balance-alb description, I get the impression that this
mode is simply not meant to be used with bridging:

		Adaptive load balancing: includes balance-tlb plus
		receive load balancing (rlb) for IPV4 traffic, and
		does not require any special switch support.  The
		receive load balancing is achieved by ARP negotiation.
		The bonding driver intercepts the ARP Replies sent by
		the local system on their way out and overwrites the
		source hardware address with the unique hardware
		address of one of the slaves in the bond such that
		different peers use different hardware addresses for
		the server.

In any case I'd tend to say that if bond-alb mode mangles outgoing MAC
addresses, it should restore the original one for received packets
and keep the hacks local to bonding.
