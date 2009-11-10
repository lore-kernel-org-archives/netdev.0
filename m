From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 15:29:39 +0100
Message-ID: <4AF978D3.7030207@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53581 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756183AbZKJO3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 09:29:42 -0500
In-Reply-To: <4AF84BF3.5020302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson a =E9crit :
> This is a significantly revised implementation of an earlier (year-ol=
d)
> patch that no longer applies cleanly, with permission of the original
> author (Adam Langley).  That patch was previously reviewed:
>=20
>    http://thread.gmane.org/gmane.linux.network/102586
>=20
> The principle difference is using a TCP option to carry the cookie no=
nce,
> instead of a user configured offset in the data.  This is more flexib=
le and
> less subject to user configuration error.  Such a cookie option has b=
een
> suggested for many years, and is also useful without SYN data, allowi=
ng
> several related concepts to use the same extension option.
>=20
>    "Re: SYN floods (was: does history repeat itself?)", September 9, =
1996.
>    http://www.merit.net/mail.archives/nanog/1996-09/msg00235.html
>=20
>    "Re: what a new TCP header might look like", May 12, 1998.
>    ftp://ftp.isi.edu/end2end/end2end-interest-1998.mail
>=20
> Data structures are carefully composed to require minimal additions.
> For example, the struct tcp_options_received cookie_plus variable fit=
s
> between existing 16-bit and 8-bit variables, requiring no additional
> space (taking alignment into consideration).  There are no additions =
to
> tcp_request_sock, and only 1 pointer in tcp_sock.
>=20
> Allocations have been rearranged to avoid requiring GFP_ATOMIC, with
> only one unavoidable exception in tcp_create_openreq_child(), where t=
he
> tcp_sock itself is created GFP_ATOMIC.
>=20
> These functions will also be used in subsequent patches that implemen=
t
> additional features.
>=20
> Requires:
>   TCPCT part 1a: add request_values parameter for sending SYNACK
>   TCPCT part 1b: TCP_MSS_DEFAULT, TCP_MSS_DESIRED
>   TCPCT part 1c: sysctl_tcp_cookie_size, socket option
> TCP_COOKIE_TRANSACTIONS, functions
>   TCPCT part 1d: generate Responder Cookie
>=20
> Signed-off-by: William.Allen.Simpson@gmail.com
> ---
>  include/linux/tcp.h      |   29 ++++-
>  include/net/tcp.h        |   72 +++++++++++++
>  net/ipv4/syncookies.c    |    5 +-
>  net/ipv4/tcp.c           |  127 ++++++++++++++++++++++-
>  net/ipv4/tcp_input.c     |   86 +++++++++++++--
>  net/ipv4/tcp_ipv4.c      |   69 ++++++++++++-
>  net/ipv4/tcp_minisocks.c |   59 ++++++++---
>  net/ipv4/tcp_output.c    |  255
> +++++++++++++++++++++++++++++++++++++++++-----
>  net/ipv6/syncookies.c    |    5 +-
>  net/ipv6/tcp_ipv6.c      |   65 +++++++++++-
>  10 files changed, 701 insertions(+), 71 deletions(-)
>=20

I really tried hard to understand what was going on, and failed, becaus=
e I dont
have much time these days...

Lack of documentation maybe ? Some DATA flow could help...

Please please, cook up elementatry patches to perform one action at a t=
ime,
even if they are not fully functionnal ?

One patch to be able to send SYN + COOKIE (if we are the client)

One patch to be able to receive this SYN + COOKIE and answer a SYNACK +=
 cookies (we are the server)

One patch to ... Receive the ACK from client (if we are the server) and=
 check cookies

One patch to ...  Send the ACK (if we are the client)

Patches to receive FIN + cookies

One patch to ... enable the whole thing and setsockopt() bits

That way we could review your patches step by step, and not 770 lines i=
n one block.

