From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Tue, 26 Apr 2011 18:21:04 +0200
Message-ID: <1303834864.3358.58.camel@edumazet-laptop>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>
	 <1303799597.2747.214.camel@edumazet-laptop>
	 <20110425.235600.104065244.davem@davemloft.net>
	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: "Rose, Gregory V" <gregory.v.rose@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62090 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021Ab1DZQVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:21:09 -0400
Received: by wya21 with SMTP id 21so595812wya.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 09:21:08 -0700 (PDT)
In-Reply-To: <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 09:12 -0700, Rose, Gregory V a =C3=A9crit=
 :

> I'm fine with however you folks want to approach this, just give me s=
ome direction.

I would just try following patch :


diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 4c4ac3f..22cac81 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -210,6 +210,7 @@ int netlink_sendskb(struct sock *sk, struct sk_buff=
 *skb);
 #else
 #define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
 #endif
+#define NLMSG_DUMPSIZE SKB_WITH_OVERHEAD(8192UL)
=20
 #define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
=20
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index c8f35b5..cb8d6ac 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1669,7 +1669,7 @@ static int netlink_dump(struct sock *sk)
 	struct nlmsghdr *nlh;
 	int len, err =3D -ENOBUFS;
=20
-	skb =3D sock_rmalloc(sk, NLMSG_GOODSIZE, 0, GFP_KERNEL);
+	skb =3D sock_rmalloc(sk, NLMSG_DUMPSIZE, 0, GFP_KERNEL);
 	if (!skb)
 		goto errout;
=20


