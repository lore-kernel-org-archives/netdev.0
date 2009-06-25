From: Markus Wick <markus@selfnet.de>
Subject: "ip route local ..." outside the table 255 (local)
Date: Thu, 25 Jun 2009 02:38:35 +0200
Message-ID: <200906250238.40369.markus@selfnet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2568960.Og7Kp10HQd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.selfnet.de ([141.70.124.9]:35580 "EHLO mail.selfnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751240AbZFYApI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 20:45:08 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.selfnet.de (Postfix) with ESMTP id 28230B36060
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 02:38:46 +0200 (CEST)
Received: from mail.selfnet.de ([127.0.0.1])
 by localhost (mailtest.selfnet.de [127.0.0.1]) (amavisd-maia, port 10024)
 with ESMTP id 27062-10 for <netdev@vger.kernel.org>;
 Thu, 25 Jun 2009 02:38:45 +0200 (CEST)
Received: from degasus.localnet (degasus.vaih.selfnet.de [10.4.186.33])
	by mail.selfnet.de (Postfix) with ESMTPSA id D439CB3605E
	for <netdev@vger.kernel.org>; Thu, 25 Jun 2009 02:38:45 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart2568960.Og7Kp10HQd
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

Hello

Is it possible to make a route of type local outside the local table?
I want to make a redirect without changing the destination ip address.
I was able to create this routes without any error messages, but no package=
=20
arrived at my socket.
Is this a bug or an undokumented feature?

I dont know where to search for the bug, but I write an example for reprodu=
ce.

Thanks

Markus


## This is a small script listening on 0.0.0.0:2525
## It sends back the src and dst ip and port
python repeat.py &

## try to connect, but there is no route to this network
## my computer has the 10.0.11.43, you have to change this
nc -s 10.0.11.43 192.168.34.56 2525
#> (UNKNOWN) [192.168.34.56] 2525 (?) : No route to host

## redirect everything to this network to the local machine
## and it works :-)
ip route add local 192.168.0.0/16 dev eth0 table local
nc -s 10.0.11.43 192.168.34.56 2525
#> SRC IP:   192.168.0.1
#> SRC Port: 43468
#> DST IP:   192.168.34.56
#> DST Port: 2525

## now the same in a new table
## delete the old route, create a new rule and add ower route
## but this time it is not working and I dont know why
ip route del 192.168.0.0/16 table local
ip rule add table 1 pref 1
ip route add local 192.168.0.0/16 dev eth0 table 1
nc -w 10 -s 10.0.11.43 192.168.34.56 2525
#> (UNKNOWN) [192.168.34.56] 2525 (?) : Connection timed out

## clean up everyting ;-)
ip route del 192.168.0.0/16 table 1
ip rule del pref 1
kill %


repeat.py:
#!/usr/bin/python
from socket import socket
serv =3D socket()
serv.bind(('',2525))
serv.listen(1)

while True:
  (s,client) =3D serv.accept()
  s.send('SRC IP:   ' + str(client[0]) + '\n')
  s.send('SRC Port: ' + str(client[1]) + '\n')
  s.send('DST IP:   ' + str(s.getsockname()[0]) + '\n')
  s.send('DST Port: ' + str(s.getsockname()[1]) + '\n')
  s.close()

--nextPart2568960.Og7Kp10HQd
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iQIcBAABAgAGBQJKQscMAAoJEIJAXxkDX2HFgdAP/i5cxSdP4fK8ll5D8IWrQGDh
0Y0cXulTyO9GLWasW/NipwVpyL27LR+WMTfEdIusVMWhTgX844xERSE+e6dhop4P
FxEtYHpOOYaQS3v/C3rVakW262PzIwZlvdUKXQQCYfhDtSSFR1N3JJ3ChXFO0/+c
32PxN+jFdvKz1uIkklZ3l+j1KA404P62UUOHvpRihy6JXeA/A4qfQy50HSURnlFH
ZlfumIEYQlHG6VlUmWSYVVbsaQ+oemvZhZJpUXYKxk0NAAZyGxFFIpNNKfxIggSM
SUa3JLl7HNAi5xbVVb5aGcAHYmQKaPpjC6+n/CivoXKqSUK8zWcWD3wsl819+/Gw
EYFdcGKHnXtIdX8xYVyj8tOMdYacUFO+krXIBBfMDhHDf64vtlmtJG1mP2o0ifmV
Hoi1Qy6c85NcUhTYJCphQ5y78vKHC6976W49Uarn42OOni5Rb5pTx+wc+ZXi+dMs
5F0+5rfMahQSpCwzdjVeSTG1zGxlLq3brkdhIWKWpM2HQ5T3MOUZeylxhbmLfVqI
ekwmRsLc0CmmAMTyLTs4FmHRttXdOnnugGHFM93l3hAUrYIV0J6cgRuHzNNsFJyY
cGzPNxYkmjWMshZEF00P8oqOLGzr1XxcXgrUWtusFlIS1enYBYh+GXm+P8kkULb5
Txb+pqxZElNv8DpUAuZP
=zMvR
-----END PGP SIGNATURE-----

--nextPart2568960.Og7Kp10HQd--
