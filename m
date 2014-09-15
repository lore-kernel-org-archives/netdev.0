From: Joe M <joe9mail@gmail.com>
Subject: Figuring out how vti works
Date: Mon, 15 Sep 2014 09:20:43 -0500
Message-ID: <20140915142043.GA22070@master>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bg08WKrSYDhXBjb5"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:34977 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561AbaIOOUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 10:20:46 -0400
Received: by mail-oa0-f41.google.com with SMTP id n16so2610466oag.28
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 07:20:45 -0700 (PDT)
Received: from master.localdomain (ip68-103-51-213.ks.ok.cox.net. [68.103.51.213])
        by mx.google.com with ESMTPSA id g2sm7768640oej.3.2014.09.15.07.20.44
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Sep 2014 07:20:45 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello Steffen Klassert,

Very sorry for this bother.

I could not figure out how vti works with ipsec and your patch was the
latest to ip_vti.c. If you cannot help, please excuse me.

I cannot get the vpn traffic to get on the vti tunnel. tcpdump on vti
does not show anything. I think the tunnel lookup code, for some
reason, is not able to use the "vtil" tunnel.

The pings worked fine if I remove the ip_vti and ip_tunnel modules,
the "mark=1" from /etc/ipsec.conf and the iptables mangle rules to
set-mark.

This is with strongswan 5.2.0. Can you please help?

This is my setup on moon (master hostname)

cat /etc/ipsec.conf
# /etc/ipsec.conf - strongSwan IPsec configuration file

config setup

conn %default
        ikelifetime=60m
        keylife=20m
        rekeymargin=3m
        keyingtries=1
        keyexchange=ikev2
        mobike=no

conn master-bnglr
        leftid="C=CH, O=strongSwan, CN=master"
        leftcert=masterCert.der
        left=192.168.0.11
        leftsubnet=192.168.0.0/24
        rightid="C=CH, O=strongSwan, CN=bnglr"
        right=%any
        rightsubnet=192.168.1.0/24
        auto=add
        mark=1


sudo cat /etc/ipsec.secrets
# /etc/ipsec.secrets - strongSwan IPsec secrets file

  : RSA masterKey.der


sudo ip tunnel list
vtil: ip/ip  remote 192.168.1.232  local 192.168.0.11  ttl inherit ikey 0  okey 1
ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0

sudo ip route list
default via 192.168.0.1 dev enp4s0  metric 202
127.0.0.0/8 dev lo  scope host
192.168.0.0/24 dev enp4s0  proto kernel  scope link  src 192.168.0.11
metric 202
192.168.1.0/24 dev vtil  scope link


sudo ip xfrm policy
src 192.168.1.0/24 dst 192.168.0.0/24
        dir fwd priority 2883
        mark 1/0xffffffff
        tmpl src <bnglr public ip> dst 192.168.0.11
                proto esp reqid 2 mode tunnel
src 192.168.1.0/24 dst 192.168.0.0/24
        dir in priority 2883
        mark 1/0xffffffff
        tmpl src <bnglr public ip> dst 192.168.0.11
                proto esp reqid 2 mode tunnel
src 192.168.0.0/24 dst 192.168.1.0/24
        dir out priority 2883
        mark 1/0xffffffff
        tmpl src 192.168.0.11 dst <bnglr public ip>
                proto esp reqid 2 mode tunnel
src 0.0.0.0/0 dst 0.0.0.0/0
        socket in priority 0
src 0.0.0.0/0 dst 0.0.0.0/0
        socket out priority 0
src 0.0.0.0/0 dst 0.0.0.0/0
        socket in priority 0
src 0.0.0.0/0 dst 0.0.0.0/0
        socket out priority 0
src ::/0 dst ::/0
        socket in priority 0
src ::/0 dst ::/0
        socket out priority 0
src ::/0 dst ::/0
        socket in priority 0
src ::/0 dst ::/0
        socket out priority 0

sudo ip xfrm state
src 192.168.0.11 dst <bnglr public ip>
        proto esp spi 0xc3b23fb1 reqid 2 mode tunnel
        replay-window 32 flag af-unspec
        mark 1/0xffffffff
        auth-trunc hmac(sha1) 0x33f17d71abbc9ccdbef83ecba9e1c0711c3767a0 96
        enc cbc(aes) 0xe790b24d9e9f71aec28f8ed00013f411
        encap type espinudp sport 4500 dport 8993 addr 0.0.0.0
src <bnglr public ip> dst 192.168.0.11
        proto esp spi 0xc8bcf9b0 reqid 2 mode tunnel
        replay-window 32 flag af-unspec
        mark 1/0xffffffff
        auth-trunc hmac(sha1) 0xb780288b0cf20aa7f010552837cc03a04e29198a 96
        enc cbc(aes) 0xd0db2ec7e9bb83cbc6a9d20feb6eab49
        encap type espinudp sport 8993 dport 4500 addr 0.0.0.0


I tried setting the mangle rules to set-mark but that did not help. I
could not find any more documentation.

Thanks again and Sorry for the bother,
Joe


--bg08WKrSYDhXBjb5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUFvW7AAoJENvmPC7PRKkIjTUQAJRckUteEBKRRRQE8SFrta4E
WQGSGkTQBuRWhtbE+alyMYVy1Uy8WpUxYzH6MboiRYcTud6q6koKvwVwPqHhu/ZI
8GKMdBqiU0JTt2IsbTCwKX4SlTlWz5ACyRWhzzYtnY4omqB4PggAUKN6bQzsbTDk
CyoQ5KspUk3QKwbtliN2xIz2hdvN0BGXiQ6Kucq8wM/P/FEjUrFMU0eYQLv9LSqv
P802ndfHtLXwQ5laDt+6M4w1h/Zy1mQeg6Y7gR1uS35Jd3iz+d0qTqz14WMjEjIc
lLclR/mI/huYvt85mJU8MaUFHYduPYgRHDaJR2TrfjnTUGGazVu/PEu9tqeivqOU
KCSOooX8cXJOqAiJ4ExrodFW3qU6YW3fh6Q5hBxOBykEyRyFm1/+MxfjgHZGhhIo
exjTN6JFViG+MjdOrzdYT26hWPbeZ5AQCEN3SVxhKahrYfwlHR1xFxTnMCULCMT8
e4dpbjwQ4l4prTlKRSlZ6NYEU5eJx1AX+p5GN1EF7cBBq/ZrrZIc48PiLSGFk3WU
UDxTiYyVBITIWGj7NhxKMpfimudxcU+wyzPyVpIiNqYDTsTdB9AphM+cixSWuc0R
JBOTJt6ClWZcvKbmrFD3Ez6g2oJpmNcy1C7yDJGQ1qVzboUFSJ19Aj7ZxCbd0UZD
Ud7tqqDa9r8fJgeh0TfJ
=CsMK
-----END PGP SIGNATURE-----

--bg08WKrSYDhXBjb5--
