From: Ben Greear <greearb@candelatech.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 09:40:06 -0700
Message-ID: <54298B66.8060807@candelatech.com>
References: <5425EAA6.7040302@gmail.com> <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com> <54295971.2040402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:50200 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbaI2QpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 12:45:25 -0400
In-Reply-To: <54295971.2040402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2014 06:06 AM, David Ahern wrote:

> The features of note:
> - resource efficiency -- not having to create a proces/thread/socket per VRF to have a "presence" in all VRFs. e.g., a VRF any context that allows 1 socket to
> work across VRFs (L3 raw socket, TCP listen socket, unconnected UDP socket). Daemons run a 'vrf any' context; connected clients run a specific vrf context. For
> non-connected sockets VRF context can be passed via cmsg.
> 
> - same IP address on different interfaces in different vrfs. i.e., VRF specific routing and neighbor tables
> 
> - cross VRF routing. ability to receive message on 1 vrf and send it on another. Can be handled by the process itself (e.g., L3 vpns).

We have implemented support for at least most of this (excepting duplicate IPs)
using routing tables, rules, and (optionally, xorp as the router).

It works ok for our purposes (network simulator), but peformance is not great because
you end up with a large number of ip rules and they are effectively evaluated linearly
it seems.

A quick way to improve performance in our scenario would be to bind rules to
specific interfaces, so that packets process a smaller number of rules when
they enter an interface, I think...but I have not looked into it closely.


It is hard to show you an example of this without you installing our
software to visualize what we are trying to do, but it our software
will work on standard kernels, and we auto-generate a perl script
that sets up all of the rules and such.  You could compare the network
diagram in our GUI with the perl script and I think understand the
basics of what we are doing fairly quickly.  If you want to take a detailed
look, let me know and I'll set you up with a demo license.



Thanks,
Ben


> 
> Thanks,
> David
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
