From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Subject: [PATCH] FIXED: IPv6 Route selection now correct with multiple gateways and preferences
Date: Tue, 14 Oct 2008 21:07:32 +0100
Message-ID: <1316147719.20081014210732@net.ipl.pt>
References: <159769323.20081014120620@net.ipl.pt> <87y70rxri6.fsf@natisbad.org>
Reply-To: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: arno@natisbad.org,
	=?utf-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.net.ipl.pt ([192.104.48.14]:53247 "EHLO
	smtp-out1.net.ipl.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbYJNUHf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 16:07:35 -0400
In-Reply-To: <87y70rxri6.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Arnaud and all,

I=E2=80=99ve found the other part of the problem.
ndisc_router_discovery () at ndisc.c weren=E2=80=99t correctly updating=
 the
flags in the route table, the problem is now fixed with the correct
default router being updated as soon as the next RA with the new
preference is received.

=46ollows the two patches made against 2.6.23 (this one and the first
I=E2=80=99ve sent) but I=E2=80=99ve seen in 2.6.26 the problem also exi=
sts and the fix
should apply without problems.

Can any of the maintainers give-me some expectations of when (and if) t=
his fix
will be added to a kernel release?

Should I patch all of our ~60 Linux machines or wait for a general
upgrade with a new kernel soon?

Thanks for all the support in this subject.

Best regards.

#######################################################################

--- linux-2.6.23-gentoo-r9orig/net/ipv6/ndisc.c    2007-10-09 21:31:38.=
000000000 +0100
+++ linux-2.6.23-gentoo-r9/net/ipv6/ndisc.c    2008-10-14 20:07:48.0000=
00000 +0100
@@ -1101,7 +1101,7 @@
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

(this part is a "repost" just to keep both patches together)

--- linux-2.6.23-gentoo-r9orig/include/linux/icmpv6.h      2007-10-09 2=
1:31:38.000000000 +0100
+++ linux-2.6.23-gentoo-r9/include/linux/icmpv6.h      2008-10-13 17:42=
:56.000000000 +0100
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

 #elif defined(__BIG_ENDIAN_BITFIELD)
                        __u8            managed:1,
                                        other:1,
+                                       home_agent:1,
                                        router_pref:2,
-                                       reserved:4;
+                                       reserved:3;
 #else
 #error "Please fix <asm/byteorder.h>"

--=20
Best regards,

=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-
Pedro Ribeiro
IPLNet - Rede de dados e comunica=C3=A7=C3=B5es
Instituto Polit=C3=A9cnico de Lisboa (IPL)
Mail: mailto:pribeiro@net.ipl.pt
VoIP: sip:pribeiro@net.ipl.pt
=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D=
-=3D-=3D-=3D-=3D-=3D-=3D-=3D-=3D-

