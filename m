From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv4 Multicast: prevent reception of mcast frames from
	unjoined groups
Date: Fri, 11 Jul 2008 14:23:04 -0400
Message-ID: <20080711182304.GD4534@hmsreliant.think-freely.org>
References: <20080711173125.GB4534@hmsreliant.think-freely.org> <OFE508C572.3640A61A-ON88257483.0061886C-88257483.00623A05@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jmorris@namei.org, kaber@trash.net,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	netdev@vger.kernel.org, pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3321 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441AbYGKS1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 14:27:12 -0400
Content-Disposition: inline
In-Reply-To: <OFE508C572.3640A61A-ON88257483.0061886C-88257483.00623A05@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 11, 2008 at 10:53:01AM -0700, David Stevens wrote:
> > currently in ip_mc_sf_allow we assume that we need to allow the frame if 
> no
> > match is found, but that has the affect of causing frames to be received 
> for
> > groups a socket hasn't joined.  I asked david aobut this specifically.
> 
>         You asked me about this? Or the other David? :-) I don't remember
> seeing anything on this-- at least not recently.
> 
It was you (I wrote from my rh address :)), the question of note that I asked
you about:

>>>
>>> 4) Finally, what if process B bound itself to INADDR_ANY rather than to
>>>the
>>> specific multicast group.  Should it see process A's sent frames then?
>>
>>        Not if the group membership is on lo and the sends are on eth0.
>>The
>>reason it isn't seeing the packets is not the binding, but the group
>>membership. To hear packets you're sending out an interface, you must
>>join that group on that interface *and* the sender must allow loopback by
>>not clearing IP_MULTICAST_LOOP. Joining the group on a different interface
>>really is joining a different group, as far as multicasting is concerned.

>         But in the sentence above, I think you missed the point of the
> mail I sent before. Joining a group or not on a particular socket has
> nothing at all to do with delivery of multicasts to the socket.
> 
>         Multicast addresses, like unicast addresses, are for the entire
> machine, not just the socket that does the join. If anyone on the
> machine has joined the group and your binding matches the packet, you
> will receive a copy. That's intentional. If you don't join any groups
> at all, but bind to INADDR_ANY, you will receive packets for the port
> and protocol and any local unicast or multicast address (including
> groups joined by any other process on the machine).
> 
>  +-DLS

If thats the final word, then I'll believe you, but it seems to me that
receiving multicast traffic on a socket that didn't specifically join a
multicast group is asking for trouble, as every application needs to be prepared
to handle data payloads it was not expected to recieve.

Can you clarify your statement above with the one that I copied in from you
earlier?

Regards
Neil


-- 
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
