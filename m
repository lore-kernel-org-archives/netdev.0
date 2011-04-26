From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Tue, 26 Apr 2011 08:33:17 +0200
Message-ID: <1303799597.2747.214.camel@edumazet-laptop>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	davem@davemloft.net
To: Greg Rose <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54169 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756764Ab1DZGdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 02:33:23 -0400
Received: by wya21 with SMTP id 21so193661wya.19
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2011 23:33:22 -0700 (PDT)
In-Reply-To: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 avril 2011 =C3=A0 15:01 -0700, Greg Rose a =C3=A9crit :
> The message size allocated for rtnl info dumps was limited to a singl=
e page.
> This is not enough for additional interface info available with devic=
es
> that support SR-IOV.  Check that the amount of data allocated is suff=
icient
> for the amount of data requested.
>=20
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> ---
>=20
>  include/linux/rtnetlink.h |    1 +
>  net/core/rtnetlink.c      |    6 ++++++
>  net/netlink/af_netlink.c  |   37 +++++++++++++++++++++++++++++++----=
--
>  3 files changed, 38 insertions(+), 6 deletions(-)
>=20

Hmm, thats a hack, because netlink_dump() is generic and you add
something very specific.

I prefer something that allows one dump() to reallocate a bigger skb

Maybe changing->dump() prototype to struct sk_buff **pskb instead of
struct sk_buff *skb.

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c8f35b5..7fa6735 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1681,7 +1681,7 @@ static int netlink_dump(struct sock *sk)
 		goto errout_skb;
 	}
=20
-	len =3D cb->dump(skb, cb);
+	len =3D cb->dump(&skb, cb);
=20
 	if (len > 0) {
 		mutex_unlock(nlk->cb_mutex);


