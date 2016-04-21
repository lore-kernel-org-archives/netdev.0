From: Valdis.Kletnieks@vt.edu
Subject: Re: linux-next: zillions of lockdep whinges in include/net/sock.h:1408
Date: Thu, 21 Apr 2016 05:05:55 -0400
Message-ID: <43037.1461229555@turing-police.cc.vt.edu>
References: <66816.1461198639@turing-police.cc.vt.edu>
 <1461224532.4101068.585250481.7A43E285@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461229555_7324P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461224532.4101068.585250481.7A43E285@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1461229555_7324P
Content-Type: text/plain; charset=us-ascii

On Thu, 21 Apr 2016 09:42:12 +0200, Hannes Frederic Sowa said:
> Hi,
>
> On Thu, Apr 21, 2016, at 02:30, Valdis Kletnieks wrote:
> > linux-next 20160420 is whining at an incredible rate - in 20 minutes of
> > uptime, I piled up some 41,000 hits from all over the place (cleaned up
> > to skip the CPU and PID so the list isn't quite so long):
>
> Thanks for the report. Can you give me some more details:
>
> Is this an nfs socket? Do you by accident know if this socket went
> through xs_reclassify_socket at any point? We do hold the appropriate
> locks at that point but I fear that the lockdep reinitialization
> confused lockdep.

It wasn't an NFS socket, as NFS wasn't even active at the time.  I'm reasonably
sure that multiple sockets were in play, given that tcp_v6_rcv and
udpv6_queue_rcv_skb were both implicated.  I strongly suspect that pretty much
any IPv6 traffic could do it - the frequency dropped off quite a bit when I
closed firefox, which is usually a heavy network hitter on my laptop.


--==_Exmh_1461229555_7324P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVxiX8wdmEQWDXROgAQLI+RAAkA0dLhdBkySQm5+jK/ZHa0/EyZyopJCA
/KoozJ/hEvhheVdrMLfOSw9ratJSyhgxzaJiV2zAM/QB3QT8jzRsgJiK4onyL9Il
hVzL4meP4RjHI0tLCkPZ8BdMpwqwoRB3oJM5oS67PyQfFCgvHFmhrOCKRBLWsuAr
/2VMVL417MBZ4voLyCYnCJIf6nkx6ZnLmIvz+lOpdFn7y3II8MS/voBy2gJV1KNb
/MHT6PzuP19Lwc5fSYv1ciG+FCM1wx6GwqETQUd2abOrM4wfNNKVrTop2tcVBC1p
EF1hcWPnkcN1oJelWVc5hwtjdLsnzjtyt158w0Vj1QPIZtdRmuHC8J4C8NX4yhqG
mfAmCt2LD08mwscqtNYskEdorfM7pjmXUJ/+MYt04TbYT6fZtWD54eacUd+0zfxV
xY9H7W2enKCpFgCSd2Uz1DvTXwU6q+u9k6Pex4JAv4bkdox2Elhn5QcVssFTDFs3
LTiRyu+TSEKBsGWBnF0jiLIINGW14/r0nZ2IjiEOOwrKOu/1tM3Cbh5NOXL1TN9/
tA41P+uK1xjCkH3znIyc1jUjT9bLy7Z9xFzMc5OqocOl5wwJDv1YHRjIqgb4or4q
hzm8wGoTVIuLeURnO/Qt39ZuwT+Pklzf+ddCsFxibmOD8bWD/qAScclgm1eX6qpU
BUQZr1vRPdM=
=E/8B
-----END PGP SIGNATURE-----

--==_Exmh_1461229555_7324P--
