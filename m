From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Subject: linux-next Problems with VPN tunnel - no packets sent
Date: Tue, 02 Dec 2014 15:41:39 -0500
Message-ID: <17929.1417552899@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1417552899_7336P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1417552899_7336P
Content-Type: text/plain; charset=us-ascii

Recent linux-next has broken my Juniper VPN client.  The tunnel gets created,
routes get added, but trying to actually send packets across results in packets
just disappearing. 'ifconfig' consistently reports exactly 1 packet sent (even
after a 'ping' command or similar should have sent multiple packets.

tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1400
        inet 172.27.1.40  netmask 255.255.255.255  destination 172.27.1.40
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
        RX packets 1  bytes 355 (355.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 1  bytes 61 (61.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Still broken in next-20141201, and bisection fingers this commit:

commit e0b46d0ee9c240c7430a47e9b0365674d4a04522
Author: Herbert Xu <herbert@gondor.apana.org.au>
Date:   Fri Nov 7 21:22:23 2014 +0800

    tun: Use iovec iterators

    This patch removes the use of skb_copy_datagram_const_iovec in
    favour of the iovec iterator-based skb_copy_datagram_iter.

This commit is in the kernel, and does *not* fix the problem:

commit 8c847d254146d32c86574a1b16923ff91bb784dd
Author: Jason Wang <jasowang@redhat.com>
Date:   Thu Nov 13 16:54:14 2014 +0800

    tun: fix issues of iovec iterators using in tun_put_user()

So there's apparently additional issues that Jason didn't address. I tried to
revert Herbert's patch for testing, but there's at  least 5 or 6 other patches
that need reverting first, so I abandoned that unless it becomes necessary...

What's the best way to proceed?

--==_Exmh_1417552899_7336P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVH4kAwdmEQWDXROgAQL2XBAAjsij8ySSYMOJZ77nN+/YI2HJVl6xt5ma
9vupieu2xMptaWrjhW9IEYdGkdzsDTsANGv4K8nr80m6cI3AmRkXKYiYIVsGUpmL
tSxIbs+S9ks7zJCtHECB3+WwWpG6HGfCaxHGY+/BVdSGbdUrTOgIzlC30tpizUJ0
3VgpkiKGwjdzx2TVLu47JMpokynq8+xogFAmT+hiJ/mNKKq8FESPeL9Q/GlnPz4K
jujrLvluzz3ff5uaYKQ/dJLisxsVdBMnBEHQ2rp+XnVTOf5d2D1XWu1am5+cjX/C
v9a3iphUxwaUSZ9VYQSanlF3DoLV6S3lFsV5kB/sTBhMr/yQKJrc0haLm4unZ8+O
QM0iHdnjs35v2EGUEh8bvObR3Sg5ZZjnrWXRQeiXMG8BCGJy5RXX0XnldoU5FG8C
1Y6D3fxk7yP1+VUN6VNyeXMvEZ03LtOWodbinZOMSkYjbEpRTxBu089529G8t/T4
UcVCBcZmxBCo5iWUBVId3wIC8L/jUekcu3GpEyQ8B6t3bIRVJ9rUyIj/zI061Y3i
55XW/oEbP5r5tcjOBibFoo62cvxTuwgcMyhhc6kyj/aiwhztNg6OdtoLFvCz2Vbw
uhj0jwTlhw3Z7HCBr8hpEwz9mesgEhtGKlM79sJhG0kP0/Qqdzxx71OuESl9iZXI
X51IEV4SVxE=
=dIq8
-----END PGP SIGNATURE-----

--==_Exmh_1417552899_7336P--
