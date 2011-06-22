From: Fabienne Ducroquet <fabiduc@gmail.com>
Subject: Re: net/ipv4: commit d0733d2e29b breaks rtorrent
Date: Wed, 22 Jun 2011 16:51:44 +0200
Message-ID: <20110622145144.GA31734@localhost>
References: <20110622124045.GA3247@localhost>
 <20110622124727.GC19184@suse.de>
 <alpine.LNX.2.00.1106221508310.10066@nitsch.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcus Meissner <meissner@suse.de>, sundell.software@gmail.com,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Reinhard Max <max@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poutre.nerim.net ([62.4.16.124]:62872 "EHLO poutre.nerim.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932181Ab1FVPBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2011 11:01:01 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1106221508310.10066@nitsch.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2011 at 03:24:53PM +0200, Reinhard Max wrote:
> On Wed, 22 Jun 2011 at 14:47, Marcus Meissner wrote:
> 
> >Can you show us the code surrounding the bind in rtorrent?

Since I'm not a developer of rtorrent I'm not sure what the right code 
to show is, so I leave that to the developer of libtorrent/rtorrent, he 
is CC'ed.

> ... or short of that, the output of "strace -e socket,bind" when
> starting rtorrent with the kernel patch not reverted?

Here it is :

socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP) = -1 EAFNOSUPPORT (Address family not supported by protocol)
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 5
bind(5, {sa_family=AF_INET6, sin6_port=htons(6903), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EINVAL (Invalid argument)

[ 95 lines with only the number in parentheses after htons changing ]

bind(5, {sa_family=AF_INET6, sin6_port=htons(6999), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EINVAL (Invalid argument)
socket(PF_INET6, SOCK_STREAM, IPPROTO_TCP) = -1 EAFNOSUPPORT (Address family not supported by protocol)
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 5
bind(5, {sa_family=AF_INET6, sin6_port=htons(6881), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EINVAL (Invalid argument)

[ 21 lines with only the number in parentheses after htons changing ]

bind(5, {sa_family=AF_INET6, sin6_port=htons(6903), inet_pton(AF_INET6, "::", &sin6_addr), sin6_flowinfo=0, sin6_scope_id=0}, 28) = -1 EINVAL (Invalid argument)


If I understand correctly, it is trying to bind an IPv6 address to a socket 
expecting an IPv4 address, so it's a bug in libtorrent/rtorrent, but it was not 
visible before because an INADDR_ANY bind is not a problem for rtorrent?

Fabienne
