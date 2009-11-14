From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP throughput drops sharply around MTU of 180 bytes
Date: Sat, 14 Nov 2009 10:12:44 +0100
Message-ID: <4AFE748C.3050100@gmail.com>
References: <51d384e10911140028r76e1aefei3a224b5c542d82e8@mail.gmail.com> <4AFE6FF0.3030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang79@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53137 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754712AbZKNJMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 04:12:41 -0500
In-Reply-To: <4AFE6FF0.3030101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>=20
> Oh well, this reminds me TCP_MAXSEG doesnt work as expected...

Oops, this problem I had few years ago was fixed last year in 2.6.27, s=
orry ...

commit f5fff5dc8a7a3f395b0525c02ba92c95d42b7390
Author: Tom Quetchenbach <virtualphtn@gmail.com>
Date:   Sun Sep 21 00:21:51 2008 -0700

    tcp: advertise MSS requested by user

    I'm trying to use the TCP_MAXSEG option to setsockopt() to set the =
MSS
    for both sides of a bidirectional connection.

    man tcp says: "If this option is set before connection establishmen=
t, it
    also changes the MSS value announced to the other end in the initia=
l
    packet."

    However, the kernel only uses the MTU/route cache to set the advert=
ised
    MSS. That means if I set the MSS to, say, 500 before calling connec=
t(),
    I will send at most 500-byte packets, but I will still receive 1500=
-byte
    packets in reply.

    This is a bug, either in the kernel or the documentation.

    This patch (applies to latest net-2.6) reduces the advertised value=
 to
    that requested by the user as long as setsockopt() is called before
    connect() or accept(). This seems like the behavior that one would
    expect as well as that which is documented.

    I've tried to make sure that things that depend on the advertised M=
SS
    are set correctly.

    Signed-off-by: Tom Quetchenbach <virtualphtn@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>



