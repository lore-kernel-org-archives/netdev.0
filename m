From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH v2 00/10] Low-level Ethernet debugging features.
Date: Fri, 10 Feb 2012 15:09:48 +0100
Message-ID: <1328882988.2443.23.camel@edumazet-laptop>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6E6A@saturn3.aculab.com>
	 <1328881897.2443.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>, jeffrey.t.kirsher@intel.com,
	Jeff Kirsher <tarbal@gmail.com>, netdev@vger.kernel.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:39433 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab2BJOJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 09:09:53 -0500
Received: by wgbgn7 with SMTP id gn7so481342wgb.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 06:09:51 -0800 (PST)
In-Reply-To: <1328881897.2443.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 14:51 +0100, Eric Dumazet a =C3=
=A9crit :

> 2) As is, we can leak kernel memory content to wire since we dont
> initialize the padding data.
>=20
>=20

=46alse alarm, this is properly handled by de620_write_block( ... , pad=
);

Other drivers do :

	if (skb->len < ETH_ZLEN) {
		if (skb_padto(skb, ETH_ZLEN))
			goto out;
	}
