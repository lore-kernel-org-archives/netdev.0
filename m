From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 09:03:06 +0200
Message-ID: <4A6D512A.1050504@gmail.com>
References: <4A6CA3BF.7010709@hartkopp.net> <200907270927.55728.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: =?windows-1252?Q?R=E9mi_Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35363 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbZG0HDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 03:03:20 -0400
In-Reply-To: <200907270927.55728.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=E9mi Denis-Courmont a =E9crit :
> On Sunday 26 July 2009 21:43:11 ext Oliver Hartkopp wrote:
>> i got this build error from the latest net-next-2.6:
>>
>> net/phonet/pn_dev.c: In function =91phonet_init_net=92:
>> net/phonet/pn_dev.c:221: error: implicit declaration of function
>> =91proc_net_fops_create=92
>> net/phonet/pn_dev.c: In function =91phonet_exit_net=92:
>> net/phonet/pn_dev.c:242: error: implicit declaration of function
>> =91proc_net_remove=92
>=20
> Oops. This makes me wonder why I did not get that one here on my test=
=20
> builds???
>=20

I also have this warning :

net/phonet/pn_dev.c: In function `phonet_device_get':
net/phonet/pn_dev.c:99: warning: 'dev' might be used uninitialized in t=
his function

What about following patch ?

[PATCH] phonet: phonet_device_get() fix

net/phonet/pn_dev.c: In function `phonet_device_get':
net/phonet/pn_dev.c:99: warning: 'dev' might be used uninitialized in t=
his function

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index b0d6ddd..c2b77a6 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -96,7 +96,7 @@ struct net_device *phonet_device_get(struct net *net)
 {
 	struct phonet_device_list *pndevs =3D phonet_device_list(net);
 	struct phonet_device *pnd;
-	struct net_device *dev;
+	struct net_device *dev =3D NULL;
=20
 	spin_lock_bh(&pndevs->lock);
 	list_for_each_entry(pnd, &pndevs->list, list) {

