From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 04:14:48 +0400
Message-ID: <20100421001448.GA31724@ioremap.net>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com> <1271802676.7895.457.camel@edumazet-laptop> <v2n46c8cb3e1004201618s37e9f0c6j7527e59673a34322@mail.gmail.com> <1271806945.7895.581.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:37128 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231Ab0DUAp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 20:45:59 -0400
Content-Disposition: inline
In-Reply-To: <1271806945.7895.581.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Wed, Apr 21, 2010 at 01:42:25AM +0200, Eric Dumazet (eric.dumazet@gmail.com) wrote:
> If you want to check source, its in file net/ipv4/inet_connection_sock.c
> 
> function inet_csk_get_port()
> 
> you can remove the 
> 
> if (atomic_read(&hashinfo->bsockets) > (high - low) + 1) { 
> 	spin_unlock(&head->lock); 
> 	snum = smallest_rover; 
> 	goto have_snum;
> }
> 
> It will solve your problem (but bind() will probably be slow)

Netcat uses SO_REUSEADDR, so its the code path which generates an error,
but this part actually returns a port number not en error. I suppose
what happend is 'attempts' check faired and thus system failed to find
a small enough bucket which does not conflict. To test this we can
remove 'smallest_size = tb->num_owners;' assignment, but bind() can be
damn slow in this case indeed.

-- 
	Evgeniy Polyakov
