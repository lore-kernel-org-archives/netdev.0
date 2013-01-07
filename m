From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH repost] net,wireless: check against default_ethtool_ops
Date: Mon, 7 Jan 2013 18:20:58 +0100
Message-ID: <CAHXqBFLQau4iROXA=GL9EQFYJpRGJHpkuW7knt=9YfSqz+_XRQ@mail.gmail.com>
References: <20130107095548.GA6931@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Ben Greear <greearb@candelatech.com>,
	=?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>,
	linux-wireless@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:38080 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab3AGRVT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 12:21:19 -0500
In-Reply-To: <20130107095548.GA6931@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/1/7 Stanislaw Gruszka <sgruszka@redhat.com>:
> Since:
>
> commit 2c60db037034d27f8c636403355d52872da92f81
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Sun Sep 16 09:17:26 2012 +0000
>
>     net: provide a default dev->ethtool_ops
>
> wireless core does not correctly assign ethtool_ops. In order to fix
> the problem, and avoid assigning ethtool_ops on each individual cfg80=
211
> drivers, we check against default_ethool_ops pointer instead of NULL =
in
> wireless core.
[...]

You could instead move the assignment of default ethtool_ops to just af=
ter
call_netdevice_notifiers(NETDEV_REGISTER) in register_netdevice() or
just after call_netdevice_notifiers(NETDEV_POST_INIT) and initialize th=
e default
wireless ethtool_ops in NETDEV_POST_INIT hook. That will avoid the expo=
rt.

Either way is good because register_netdevice() is called under RTNL, s=
o
ethtool_ops can't be called until it returns. NETDEV_POST_INIT seams mo=
re
natural to me, but it's not a strong opinion.

Best Regards,
Micha=C5=82 Miros=C5=82aw
