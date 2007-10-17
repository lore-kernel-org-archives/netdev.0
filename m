From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [patch] ipv6.7: IPV6_ROUTER_ALERT sockopt correction
Date: Wed, 17 Oct 2007 09:19:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710170911360.21784@netcore.fi>
References: <20071014111147.GE20850@mcdonald.org.uk>
 <Pine.LNX.4.64.0710150849580.17284@netcore.fi> <20071016201550.GC28453@mcdonald.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Andrew McDonald <andrew@mcdonald.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:43130 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763599AbXJQGTd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 02:19:33 -0400
In-Reply-To: <20071016201550.GC28453@mcdonald.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Oct 2007, Andrew McDonald wrote:
> For why you don't want to packets to be forwarded, consider a simple
> example that applies to something like RSVP:
> - packet hits router, identified as potentially interesting from router
> alert option
> - packet passed to user space, confirmed as really interesting and
> processed
> - create new packet (based on the one that came in and the RSVP
> processing you've done) and send it out
>
> You don't want the original packet you received to be forwarded, only
> your new packet.

Router alert option on a hop-by-hop header means that every router on 
the path should process the option.

You did not mention the rationale why the it would be reasonable for a 
packet that would otherwise be forwarded by the Linux router and 
expected to be processed by every router on the path to be re-created 
at every step, and every user-space application have to do that.

In the specific case of RSVP packets, AFAIK (e.g., Path and PathTear 
messages), the content of the RSVP packet is expected to be the 
same at every hop.

Your argument might make sense in the case where the payload of the 
packet carrying router-alert option is expected to change at every 
hop.  I believe that's not the intent of any router alert options that 
I'm aware of.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
