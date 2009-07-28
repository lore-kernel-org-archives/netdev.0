From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pppol2tp: calls unregister_pernet_gen_device() at unload
 time
Date: Tue, 28 Jul 2009 15:47:39 +0200
Message-ID: <4A6F017B.4060909@gmail.com>
References: <bug-13760-10286@http.bugzilla.kernel.org/> <20090722134557.2457c5f5.akpm@linux-foundation.org> 	<43d009740907222339n50ebe411ya6453dc5a294b9a0@mail.gmail.com> 	<20090723000100.d74d6b1c.akpm@linux-foundation.org> <43d009740907272340g7f98ed55lfff38bfedd867a99@mail.gmail.com> <4A6EBA88.8030205@cosmosbay.com> <4A6ECA3A.4050309@openvz.org> <4A6EEF69.1050001@cosmosbay.com> <4A6EF0BF.2050801@gmail.com> <4A6EF705.6070403@openvz.org> <4A6EFA35.3060309@gmail.com> <4A6EFB81.4090105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	Igor M Podlesny <for.poige+bugzilla.kernel.org@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:54360 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703AbZG1Nrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 09:47:52 -0400
In-Reply-To: <4A6EFB81.4090105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Seems drivers/net/pppol2tp.c is a suspect...
>=20
> It uses register_pernet_gen_device() from pppol2tp_init()
> but doesnt call unregister_pernet_gen_device()

OK patch seems really easy...

This bug was added in commit 4e9fb8016a351b5b9da7fea32bcfdbc9d836e421
net: pppol2tp - introduce net-namespace functionality

So this is a stable candidate I guess ?

Thank you


[PATCH] pppol2tp: calls unregister_pernet_gen_device() at unload time

=46ailure to call unregister_pernet_gen_device() can exhaust memory
if module is loaded/unloaded many times.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index e7935d0..e0f9219 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2680,6 +2680,7 @@ out_unregister_pppol2tp_proto:
 static void __exit pppol2tp_exit(void)
 {
 	unregister_pppox_proto(PX_PROTO_OL2TP);
+	unregister_pernet_gen_device(pppol2tp_net_id, &pppol2tp_net_ops);
 	proto_unregister(&pppol2tp_sk_proto);
 }
=20
