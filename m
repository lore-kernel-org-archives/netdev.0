From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: =?UTF-8?Q?nonlocal=5Fbind=20=26=20IPv=36?=
Date: Fri, 25 Jun 2010 20:59:58 +0200
Message-ID: <30fe1fa984e52f4cca318e54f9d97a21@chewa.net>
References: <201006252043.45581.michal.humpula@hudrydum.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Humpula <michal.humpula@hudrydum.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:45337 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756746Ab0FYS77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 14:59:59 -0400
In-Reply-To: <201006252043.45581.michal.humpula@hudrydum.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 25 Jun 2010 20:43:45 +0200, Michal Humpula=0D
<michal.humpula@hudrydum.cz> wrote:=0D
> I was just wondering, what's wrong with this?=0D
=0D
It's not in unified format :D=0D
=0D
> *** linux-2.6.34/net/ipv6/af_inet6.c    2010-05-16 23:17:36.000000000=
=0D
> +0200=0D
> --- linux-2.6.34-hack/net/ipv6/af_inet6.c       2010-06-25=0D
> 19:50:19.000000000 +0200=0D
> ***************=0D
> *** 345,354 ****=0D
> --- 345,356 ----=0D
>                         if (!(addr_type & IPV6_ADDR_MULTICAST)) {=0D
>                                 if (!ipv6_chk_addr(net, &addr->sin6_a=
ddr,=0D
>                                                    dev, 0)) {=0D
> +           if (!sysctl_ip_nonlocal_bind) {=0D
>                                         err =3D -EADDRNOTAVAIL;=0D
>                                         goto out_unlock;=0D
>             }=0D
>                                 }=0D
> +                       }=0D
>                         rcu_read_unlock();=0D
>                 }=0D
>         }=0D
> =0D
> Motivation: just want to balance one IPv6 address between two nodes w=
ith=0D
> the help of keepalived the same way I do it with IPv4 without the nee=
d=0D
> of restarting the daemons binding on that IP.=0D
=0D
nonlocal_bind seems a bit 80's to me. Why don't you bind the daemon to=0D
[::]? If it needs to know its own address, it can always use getsocknam=
e()=0D
for connected sockets and IPV6_PKTINFO ancillary data for datagram sock=
ets.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

