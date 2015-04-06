From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Prevent UDP tunnels from operating on garbage
 socket
Date: Mon, 06 Apr 2015 13:17:00 -0400 (EDT)
Message-ID: <20150406.131700.185460014498109286.davem@davemloft.net>
References: <20150405.221847.2119086885797169021.davem@davemloft.net>
	<CALx6S348YyYxrT+3fcXEFz=w6BYFGZwcQ6iD1PjzVePotioJKw@mail.gmail.com>
	<20150406.124114.924455461962119301.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	pablo@netfilter.org, hannes@stressinduktion.org, jiri@resnulli.us
To: tom@herbertland.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150406.124114.924455461962119301.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Mon, 06 Apr 2015 12:41:14 -0400 (EDT)

> Tom if you are saying that skb->sk should be reset to the tunnel
> socket, that doesn't work and is completely broken.

Thinking some more, I think what you are missing is that deeper in the
ipv4/ipv6 transmit call chain we do things like sk_mc_loop() etc. on
the socket and we cannot just do it on skb->sk.

To make that work correctly we must pass the tunnel socket down
through the ipv4/ipv6 packet output paths, via netfilter hooks
if necessary.

I am also really disappointed with the call signature of the udp
tunnel send paths.  You have to be honest with yourself and agree
that something with 11 arguments is not a well designed interface.

Now that hopefully you can see that the socket is actually required,
can possibly use that to trim the function signature down for
udp_tunnel{,6}_xmit_skb()?

Worst case, make a "struct udp_tunnel_state" just like I made a "struct
nf_hook_state" for the netfilter hooks.

Thanks.
