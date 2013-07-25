From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v3] net: split rt_genid for ipv4 and ipv6
Date: Thu, 25 Jul 2013 20:13:14 +0200
Message-ID: <20130725181314.GA24007@order.stressinduktion.org>
References: <1374745632-1624-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, nicolas.dichtel@6wind.com,
	yoshfuji@linux-ipv6.org, jmorris@namei.org,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:39657 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756948Ab3GYSNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 14:13:16 -0400
Content-Disposition: inline
In-Reply-To: <1374745632-1624-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 25, 2013 at 05:47:12PM +0800, Fan Du wrote:
> +/* For callers who don't really care about whether it's IPv4 or IPv6=
 */
> +static inline void rt_genid_bump_all(struct net *net)
> +{
> +	atomic_inc(&net->ipv4.rt_genid);
> +#if IS_ENABLED(CONFIG_IPV6)
> +	atomic_inc(&net->ipv6.rt_genid);
> +#endif

You could get away with the ifdef if you just do
	rt_genid_bump_ipv4(net);
	rt_genid_bump_ipv6(net);


Somewhere something does break selinux:

  CC      security/selinux/hooks.o
In file included from security/selinux/hooks.c:93:0:
security/selinux/include/xfrm.h: In function =E2=80=98selinux_xfrm_noti=
fy_policyload=E2=80=99:
security/selinux/include/xfrm.h:54:2: error: implicit declaration of fu=
nction =E2=80=98rt_genid_bump=E2=80=99 [-Werror=3Dimplicit-function-dec=
laration]
  rt_genid_bump(&init_net);
  ^
Seems like you have overlooked the rt_genid_bump in
security/selinux/include/xfrm.h, which should be a rt_genid_bump_all

Off-topic:
Is it correct that selinux_xfrm_notify_policyload only bumps genid for
init_net?

Otherwise I don't see any problems arising from this patch because of
the rt_genid split.

Greetings,

  Hannes
