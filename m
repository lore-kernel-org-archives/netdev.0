From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16626] New: Machine hangs with EIP at
 skb_copy_and_csum_dev
Date: Tue, 24 Aug 2010 07:01:42 +0200
Message-ID: <1282626102.2378.1351.camel@edumazet-laptop>
References: <20100820193835.GA6025@del.dom.local>
	 <20100821074742.GA2367@del.dom.local>
	 <1282377058.2636.12.camel@edumazet-laptop>
	 <20100821080735.GA2409@del.dom.local> <4C725FCB.2000304@fs.uni-ruse.bg>
	 <20100823124736.GA16966@ff.dom.local>
	 <1282568443.2486.34.camel@edumazet-laptop>
	 <20100823131056.GA19160@ff.dom.local> <4C727B06.2060002@fs.uni-ruse.bg>
	 <4C72802D.8090405@fs.uni-ruse.bg> <20100823141437.GA2282@del.dom.local>
	 <4C734FB5.1090702@fs.uni-ruse.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Plamen Petrov <pvp-lsts@fs.uni-ruse.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56475 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750917Ab0HXFBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 01:01:47 -0400
Received: by wyb32 with SMTP id 32so7708296wyb.19
        for <netdev@vger.kernel.org>; Mon, 23 Aug 2010 22:01:46 -0700 (PDT)
In-Reply-To: <4C734FB5.1090702@fs.uni-ruse.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 ao=C3=BBt 2010 =C3=A0 07:51 +0300, Plamen Petrov a =C3=A9cr=
it :
> So far - not so good. :(
>=20
> After I left the machine, i rebooted once. Then I logged in
> via ssh, and turned gro back ON for the tg3 nic - and in the
> next 30 minutes - another reboot.
>=20
> Today I will try to capture a picture of the oops/warning
> with my phone camera, because contrary to what you suggest,
> Jarek, there are no messages in the system logs.

Hmm... I was thinking adding a call __skb_linearize(), just in case...

diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index f5166dc..10928a2 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -1696,7 +1696,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_=
buff *skb,
 	entry =3D tp->cur_tx % NUM_TX_DESC;
=20
 	/* Note: the chip doesn't have auto-pad! */
-	if (likely(len < TX_BUF_SIZE)) {
+	if (likely(len < TX_BUF_SIZE && !__skb_linearize(skb))) {
 		if (len < ETH_ZLEN)
 			memset(tp->tx_buf[entry], 0, ETH_ZLEN);
 		skb_copy_and_csum_dev(skb, tp->tx_buf[entry]);




