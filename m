From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge
Date: Thu, 19 Mar 2009 17:31:52 +0100
Message-ID: <20090319163151.GB6132@psychotron.englab.brq.redhat.com>
References: <20090314094911.GA3455@psychotron.englab.brq.redhat.com> <20090315161217.7fa2c3a7@nehalam> <20090316111127.GB3484@psychotron.englab.brq.redhat.com> <20090318.232003.30974750.davem@davemloft.net> <49C2073B.8060102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:42920 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbZCSQfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2009 12:35:03 -0400
Content-Disposition: inline
In-Reply-To: <49C2073B.8060102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Mar 19, 2009 at 09:50:03AM CET, kaber@trash.net wrote:
> David Miller wrote:
>> From: Jiri Pirko <jpirko@redhat.com>
>> Date: Mon, 16 Mar 2009 12:11:28 +0100
>>
>>> I can see two solutions. Either like my patch or somehow allow bridge to know
>>> more MAC addressses per port (maybe netdev can be changed to know more then
>>> one MAC address).
>>>
>>> Any thoughts?
>>
>> The netdev struct already supports having a list of multiple unicast
>> MAC addresses, it can probably be used and inspected for this.
>>
>> I'll hold off on your patch until we make some more progress on
>> this discussion.
>
> From reading the balance-alb description, I get the impression that this
> mode is simply not meant to be used with bridging:
>
> 		Adaptive load balancing: includes balance-tlb plus
> 		receive load balancing (rlb) for IPV4 traffic, and
> 		does not require any special switch support.  The
> 		receive load balancing is achieved by ARP negotiation.
> 		The bonding driver intercepts the ARP Replies sent by
> 		the local system on their way out and overwrites the
> 		source hardware address with the unique hardware
> 		address of one of the slaves in the bond such that
> 		different peers use different hardware addresses for
> 		the server.
>
> In any case I'd tend to say that if bond-alb mode mangles outgoing MAC
> addresses, it should restore the original one for received packets
> and keep the hacks local to bonding.

To let bonding driver to resolve this I think there will be needed some kind of
hook in netif_receive_skb() as for example bridge has. I would rather do this
more general and transparent.
