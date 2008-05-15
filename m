From: Alan Swanson <swanson@ukfsn.org>
Subject: IPSEC IPV4 Tunnel Requires IPV6 WIth 2.6.25?
Date: Thu, 15 May 2008 21:09:42 +0100
Message-ID: <1210882182.9684.27.camel@zeus.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:39269 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751861AbYEOUJu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 16:09:50 -0400
Received: from localhost (smtp-filter.ukfsn.org [192.168.54.205])
	by mail.ukfsn.org (Postfix) with ESMTP id 3538CDED13
	for <netdev@vger.kernel.org>; Thu, 15 May 2008 21:14:07 +0100 (BST)
Received: from mail.ukfsn.org ([192.168.54.25])
	by localhost (smtp-filter.ukfsn.org [192.168.54.205]) (amavisd-new, port 10024)
	with ESMTP id VnW4VdigqbqP for <netdev@vger.kernel.org>;
	Thu, 15 May 2008 20:38:51 +0100 (BST)
Received: from zeus.local (87-127-90-129.no-dns-yet.enta.net [87.127.90.129])
	by mail.ukfsn.org (Postfix) with ESMTP id EEC24DECD6
	for <netdev@vger.kernel.org>; Thu, 15 May 2008 21:14:06 +0100 (BST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi. Usual non-subscriber CC replies request please.

There is a problem with 2.6.25(.4) using IPSEC on ipv4. You seem to nee=
d
to have ipv6 available otherwise a protocol not supported error is
returned when trying to set a Security Association Database. I'm using
setkey on a file but another user on the ipsec-tools-devel list reporte=
d
the same issue using racoon.

=EF=BB=BFhttp://marc.info/?l=3Dipsec-tools-devel&m=3D121015164014761&w=3D=
2

So with modules loaded you expect to work.

$ lsmod
  Module                  Size  Used by
  authenc                 5056  0=20
  ah4                     4672  0=20
  esp4                    5824  0=20
  aead                    5824  2 authenc,esp4
  xfrm4_mode_tunnel       2176  20

A static file with tunnel configuration for laptop to desktop over open
wireless not running WEP/WPA.

$ head -n 12 /etc/ipsec.conf
  #!/usr/sbin/setkey -f
 =20
  flush;
  spdflush;
 =20
  add 1.1.1.1 2.2.2.2 esp 0x500 -m tunnel
  -E rijndael-cbc 0x...
  -A hmac-sha1 0x...;
 =20
  add 2.2.2.2 1.1.1.1 esp 0x501 -m tunnel
  -E rijndael-cbc 0x...
  -A hmac-sha1 0x...;

You get protocol not supported error.

$ setkey -f /etc/ipsec.conf
  =EF=BB=BFThe result of line 8: Protocol not supported.
  The result of line 12: Protocol not supported.

But after modprobing ipv6 which automatically pulls
in =EF=BB=BFxfrm6_mode_tunnel, setkey starts working and I can communic=
ate via
IPSEC.

$ lsmod
  Module                  Size  Used by
  xfrm6_mode_tunnel       2048  4=20
  ipv6                  217444  10 xfrm6_mode_tunnel
  authenc                 5056  4=20
  ah4                     4672  0=20
  esp4                    5824  4=20
  aead                    5824  2 authenc,esp4
  xfrm4_mode_tunnel       2176  28

It really shouldn't need ipv6. Full kernel config, lsmod before and
after modprobing ipv6 are available at below URL's.

http://www.swanson.ukfsn.org/ipsec/config
http://www.swanson.ukfsn.org/ipsec/lsmod-post-modprobe-ipv6
http://www.swanson.ukfsn.org/ipsec/lsmod-pre-modprobe-ipv6

--=20
Alan.

"One must never be purposelessnessnesslessness."
