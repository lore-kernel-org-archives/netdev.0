From: christophe leroy <christophe.leroy@c-s.fr>
Subject: Performance loss due to commit  37c3185 ([NET]: Added GSO toggle)
Date: Sat, 20 Jun 2015 11:55:03 +0200
Message-ID: <55853877.9080000@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2.236.17.93.rev.sfr.net ([93.17.236.2]:61703 "EHLO
	mailhub1.si.c-s.fr" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751630AbbFTKcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 06:32:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Herbert,

In commit "[NET]: Added GSO toggle"=20
37c3185a02d4b85fbe134bf5204535405dd2c957,
you force NETIF_F_HW_CSUM if GSO feature is selected.
By default, SW GSO is active as soon as a network board has NETIF_F_SG=20
feature.
This means that function sk_setup_caps() forces NETIF_F_HW_CSUM for any=
=20
board having NETIF_F_SG

=46or boards having no HW checksum capability, this results in performa=
nce=20
loss due to data copy being done in skb_do_copy_data_nocache() with=20
copy_from_user() then checksum being done later with csum_partial()=20
instead of getting both done at the same time using=20
csum_and_copy_from_user()

Is there a reason for forcing NETIF_F_HW_CSUM   ?

Christophe

---
L'absence de virus dans ce courrier =C3=A9lectronique a =C3=A9t=C3=A9 v=
=C3=A9rifi=C3=A9e par le logiciel antivirus Avast.
https://www.avast.com/antivirus
