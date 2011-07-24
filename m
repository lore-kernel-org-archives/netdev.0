From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: LInux kernel 3.0 sit creation bug report
Date: Sun, 24 Jul 2011 10:42:11 +0200
Message-ID: <1311496931.6669.16.camel@edumazet-laptop>
References: <E1Qkf2u-0007ZF-DS@dex.edzone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: jsr@dex.edzone.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48748 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab1GXImQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jul 2011 04:42:16 -0400
Received: by wwe5 with SMTP id 5so3256969wwe.1
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2011 01:42:15 -0700 (PDT)
In-Reply-To: <E1Qkf2u-0007ZF-DS@dex.edzone.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 23 juillet 2011 =C3=A0 12:27 -0400, Jay Rouman a =C3=A9crit :
> Kernel 3.0 (release version)
> Summary:  sit tunnel creation fails with "No buffer space available"
>=20
> Example:
>=20
> icebox:/home/u/jsr(3)# /sbin/ip tunnel add sit0 mode sit local 216.11=
1.203.89 remote 209.51.18.1 ttl 255
> add tunnel sit0 failed: No buffer space available
>=20
> icebox:/home/u/jsr(8)# /sbin/ifconfig sit0 inet6 tunnel ::209.51.18.1
> SIOCSIFDSTADDR: No buffer space available
>=20
> Notes:
>=20
> Oddly, the ifconfig example creates a working sit0.  The "ip" example
> does not.  The problem existed in rc1 but unfortunately I did not tes=
t
> sit creation then.  This was discovered when I upgraded a machine wit=
h
> an HE tunnel to the 3.0 kernel.  I am happy to do further testing or
> provide whatever additional info I can.
>=20

I believe you use a deprecated (~10 years ago ?) way to setup your
tunnel, its not a linux-3.0 new behavior.

sit0 is reserved (fall back tunnel), you should use a different name.

Try :

# ip tunnel add aster mode sit local 216.111.203.89 remote 209.51.18.1 =
ttl 255
# ifconfig aster up

# ip tunnel
sit0: ipv6/ip  remote any  local any  ttl 64  nopmtudisc
aster: ipv6/ip  remote 209.51.18.1  local 216.111.203.89  ttl 255=20


