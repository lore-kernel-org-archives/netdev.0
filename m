From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Subject: [PATCH for 2.6.27] Structure icmp6hdr (IPv6/ICMPv6) with bug in the bitfields!
Date: Tue, 14 Oct 2008 23:38:11 +0100
Message-ID: <1338007712.20081014233811@net.ipl.pt>
References: <159769323.20081014120620@net.ipl.pt> <20081014.135423.91524319.davem@davemloft.net>
Reply-To: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.net.ipl.pt ([192.104.48.14]:57518 "EHLO
	smtp-out1.net.ipl.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbYJNWiN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 18:38:13 -0400
In-Reply-To: <20081014.135423.91524319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

Thanks for your time on this, follows a new patch made against 2.6.27,
this time I minimized the cut&paste to avoid corrupting the patch.

diff -wurNbB linux-2.6.27/include/linux/icmpv6.h linux-2.6.27fix/includ=
e/linux/icmpv6.h
--- linux-2.6.27/include/linux/icmpv6.h 2008-10-09 23:13:53.000000000 +=
0100
+++ linux-2.6.27fix/include/linux/icmpv6.h      2008-10-14 23:24:31.000=
000000 +0100
@@ -40,16 +40,18 @@
                 struct icmpv6_nd_ra {
                        __u8            hop_limit;
 #if defined(__LITTLE_ENDIAN_BITFIELD)
-                       __u8            reserved:4,
+                       __u8            reserved:3,
                                        router_pref:2,
+                                       home_agent:1,
                                        other:1,
                                        managed:1;
=20
 #elif defined(__BIG_ENDIAN_BITFIELD)
                        __u8            managed:1,
                                        other:1,
+                                       home_agent:1,
                                        router_pref:2,
-                                       reserved:4;
+                                       reserved:3;
 #else
 #error "Please fix <asm/byteorder.h>"
 #endif
diff -wurNbB linux-2.6.27/net/ipv6/ndisc.c linux-2.6.27fix/net/ipv6/ndi=
sc.c
--- linux-2.6.27/net/ipv6/ndisc.c       2008-10-09 23:13:53.000000000 +=
0100
+++ linux-2.6.27fix/net/ipv6/ndisc.c    2008-10-14 23:24:31.000000000 +=
0100
@@ -1199,7 +1199,7 @@
                }
                neigh->flags |=3D NTF_ROUTER;
        } else if (rt) {
-               rt->rt6i_flags |=3D (rt->rt6i_flags & ~RTF_PREF_MASK) |=
 RTF_PREF(pref);
+               rt->rt6i_flags =3D (rt->rt6i_flags & ~RTF_PREF_MASK) | =
RTF_PREF(pref);
        }
=20
        if (rt)



Best regards.

Tuesday, October 14, 2008, 9:54:23 PM, you wrote:

> From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
> Date: Tue, 14 Oct 2008 12:06:20 +0100

>> Follows a =E2=80=9Cdiff=E2=80=9D with the changes I=E2=80=99ve made =
to correct this problem
>> (I=E2=80=99ve made it against kernel 2.6.23, but I=E2=80=99ve confir=
med that the
>> problem still exists in 2.6.25)

> Please make your patch against current sources, it does not apply
> to the current tree.
> =04=14?=06?=EC=B9=BB=1C?&?=05???=1Ba??e??A=06=C7=A7t=1Ba|=19b??A?{.n?=
+?????]z?A?{a|=16?w0h|=16???,j=07???fj:+v??=06?=1E?=19=1E?w?=06??2??=06=
f???h??b??Aj?A??i=07????????zPh?=0F?j:+v??=06)=DF=A4=18m?



--=20
Best regards,

=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-
Pedro Ribeiro
IPLNet - Rede de dados e comunica=C3=A7=C3=B5es
Instituto Polit=C3=A9cnico de Lisboa (IPL)
Mail: mailto:pribeiro-bulk@net.ipl.pt
VoIP: sip:pribeiro@net.ipl.pt
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-

