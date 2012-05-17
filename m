From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] ipv6: fix incorrect ipsec transport mode fragment
Date: Thu, 17 May 2012 15:42:00 +0800
Message-ID: <4FB4ABC8.5000506@cn.fujitsu.com>
References: <20120215104021.GC31660@secunet.com> <1336965660-14201-1-git-send-email-gaofeng@cn.fujitsu.com> <20120514130528.GA24733@secunet.com> <20120514.184132.1506982467448756718.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	lw@cn.fujitsu.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:30453 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760008Ab2EQHlj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 03:41:39 -0400
In-Reply-To: <20120514.184132.1506982467448756718.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B405=E6=9C=8815=E6=97=A5 06:41, David Miller =E5=86=
=99=E9=81=93:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Mon, 14 May 2012 15:05:28 +0200
>=20
>> There might be other opinions, but I don't like to see this IPsec mo=
de
>> dependent stuff hacked into the generic ipv6 output path.
>=20
> Completely agreed.

Hi David

how do you think about adding function pointer to struct xfrm_mode?
when prefering xfrm_mode,there must be some ipsec codes in the generic =
ipv6 output
path,just like below.it looks ugly.

int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
        int offset, int len, int odd, struct sk_buff *skb),
        void *from, int length, int transhdrlen,
        int hlimit, int tclass, struct ipv6_txoptions *opt, struct flow=
i6 *fl6,
        struct rt6_info *rt, unsigned int flags, int dontfrag)
{
#ifdef CONFIG_XFRM
        struct xfrm_state *x =3D rt->dst.xfrm;
        if (x && x->outer_mode && x->outer_mode->append_data) {
                x->outer_mode->append_data(...);
        } else
#endif
                __ip6_append_data(...);
}

I want to use one bit of rt6_info->rt6i_flags to identify the actions w=
e should
do in ip6_append_data. BUT it seems not what the rt6i_flags should do.t=
his may
make rt6i_flags in chaos.

What's your comment?

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
