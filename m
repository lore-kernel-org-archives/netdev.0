From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: possible bug in net/tc35815.c in linux-2.6.19
Date: Sat, 24 Feb 2007 13:37:55 +0100
Message-ID: <45E031A3.806@googlemail.com>
References: <45DFEC09.3020801@cs.stanford.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Philip Guo <pg@cs.stanford.edu>, Jeff Garzik <jeff@garzik.org>,
	ahennessy@mvista.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:60558 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263AbXBXMiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 07:38:20 -0500
Received: by nf-out-0910.google.com with SMTP id o25so1157406nfa
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 04:38:19 -0800 (PST)
In-Reply-To: <45DFEC09.3020801@cs.stanford.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Philip,

Philip Guo napisa=C5=82(a):
> Hi,
>=20
> I am a graduate student working on finding bugs in Linux drivers usin=
g
> an automated research tool.  I think I've found a possible bug in
> net/tc35815.c, and I'd appreciate it if you could confirm/disconfirm =
it.
>=20
> Thanks,
> Philip
>=20
> ---
> net/tc35815.c
>=20
> tc35815_driver is never unregistered in tc35815_cleanup_module()
>=20
> static int __init tc35815_init_module(void)
> {
>     return pci_register_driver(&tc35815_driver);
> }
>=20
> static void __exit tc35815_cleanup_module(void)
> {
>     struct net_device *next_dev;
>=20
>     while (root_tc35815_dev) {
>         struct net_device *dev =3D root_tc35815_dev;
>         next_dev =3D ((struct tc35815_local *)dev->priv)->next_module=
;
>         iounmap((void *)(dev->base_addr));
>         unregister_netdev(dev);
>         free_netdev(dev);
>         root_tc35815_dev =3D next_dev;
>     }
> }
>=20
>=20

I think that you are right, but I don't know this code.

Jeff, what do you think about this?

Regards,
Michal

PS. Philip, please sign this patch.

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)

Signed-off-by: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>

--- linux-mm-clean/drivers/net/tc35815.c	2007-02-04 19:44:54.000000000 =
+0100
+++ linux-mm/drivers/net/tc35815.c	2007-02-24 13:07:34.000000000 +0100
@@ -1740,6 +1740,8 @@ static void __exit tc35815_cleanup_modul
 		free_netdev(dev);
 		root_tc35815_dev =3D next_dev;
 	}
+
+	pci_unregister_driver(&tc35815_driver);
 }
 module_init(tc35815_init_module);
 module_exit(tc35815_cleanup_module);
