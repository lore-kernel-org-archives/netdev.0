From: Stephen Hemminger <stephen@networkplumber.org>
Subject: net-next headers break user source compatiablity
Date: Thu, 25 Jun 2015 15:38:46 -0400
Message-ID: <20150625153846.0535d249@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:36182 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069AbbFYTit convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 15:38:49 -0400
Received: by igbiq7 with SMTP id iq7so126221755igb.1
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 12:38:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current net-next headers break build of iproute2. Looks like in.h needs=
 the
same libc-compat.h dance as was done in in6.h



$ gcc -Wall -Wstrict-prototypes  -Wmissing-prototypes -Wmissing-declara=
tions -Wold-style-definition -Wformat=3D2 -O2 -I../include -DRESOLVE_HO=
STNAMES -DLIBDIR=3D\"/usr/lib\" -DCONFDIR=3D\"/etc/iproute2\" -D_GNU_SO=
URCE -D_FILE_OFFSET_BITS=3D64 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE=
  -DHAVE_SETNS -DHAVE_ELF -DCONFIG_GACT -DCONFIG_GACT_PROB -DIPT_LIB_DI=
R=3D\"/lib/xtables\" -DYY_NO_INPUT $(pkg-config xtables --cflags)   -c =
-o em_ipset.o em_ipset.c
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
=2E./include/linux/in.h:26:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_IP=E2=80=99
   IPPROTO_IP =3D 0,  /* Dummy protocol for TCP  */
   ^
/usr/include/netinet/in.h:42:5: note: previous definition of =E2=80=98I=
PPROTO_IP=E2=80=99 was here
     IPPROTO_IP =3D 0,    /* Dummy protocol for TCP.  */
     ^
=2E./include/linux/in.h:28:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_ICMP=E2=80=99
   IPPROTO_ICMP =3D 1,  /* Internet Control Message Protocol */
   ^
/usr/include/netinet/in.h:44:5: note: previous definition of =E2=80=98I=
PPROTO_ICMP=E2=80=99 was here
     IPPROTO_ICMP =3D 1,    /* Internet Control Message Protocol.  */
     ^
=2E./include/linux/in.h:30:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_IGMP=E2=80=99
   IPPROTO_IGMP =3D 2,  /* Internet Group Management Protocol */
   ^
/usr/include/netinet/in.h:46:5: note: previous definition of =E2=80=98I=
PPROTO_IGMP=E2=80=99 was here
     IPPROTO_IGMP =3D 2,    /* Internet Group Management Protocol. */
     ^
=2E./include/linux/in.h:32:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_IPIP=E2=80=99
   IPPROTO_IPIP =3D 4,  /* IPIP tunnels (older KA9Q tunnels use 94) */
   ^
/usr/include/netinet/in.h:48:5: note: previous definition of =E2=80=98I=
PPROTO_IPIP=E2=80=99 was here
     IPPROTO_IPIP =3D 4,    /* IPIP tunnels (older KA9Q tunnels use 94)=
=2E  */
     ^
=2E./include/linux/in.h:34:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_TCP=E2=80=99
   IPPROTO_TCP =3D 6,  /* Transmission Control Protocol */
   ^
/usr/include/netinet/in.h:50:5: note: previous definition of =E2=80=98I=
PPROTO_TCP=E2=80=99 was here
     IPPROTO_TCP =3D 6,    /* Transmission Control Protocol.  */
     ^
=2E./include/linux/in.h:36:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_EGP=E2=80=99
   IPPROTO_EGP =3D 8,  /* Exterior Gateway Protocol  */
   ^
/usr/include/netinet/in.h:52:5: note: previous definition of =E2=80=98I=
PPROTO_EGP=E2=80=99 was here
     IPPROTO_EGP =3D 8,    /* Exterior Gateway Protocol.  */
     ^
=2E./include/linux/in.h:38:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_PUP=E2=80=99
   IPPROTO_PUP =3D 12,  /* PUP protocol    */
   ^
/usr/include/netinet/in.h:54:5: note: previous definition of =E2=80=98I=
PPROTO_PUP=E2=80=99 was here
     IPPROTO_PUP =3D 12,    /* PUP protocol.  */
     ^
=2E./include/linux/in.h:40:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_UDP=E2=80=99
   IPPROTO_UDP =3D 17,  /* User Datagram Protocol  */
   ^
/usr/include/netinet/in.h:56:5: note: previous definition of =E2=80=98I=
PPROTO_UDP=E2=80=99 was here
     IPPROTO_UDP =3D 17,    /* User Datagram Protocol.  */
     ^
=2E./include/linux/in.h:42:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_IDP=E2=80=99
   IPPROTO_IDP =3D 22,  /* XNS IDP protocol   */
   ^
/usr/include/netinet/in.h:58:5: note: previous definition of =E2=80=98I=
PPROTO_IDP=E2=80=99 was here
     IPPROTO_IDP =3D 22,    /* XNS IDP protocol.  */
     ^
=2E./include/linux/in.h:44:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_TP=E2=80=99
   IPPROTO_TP =3D 29,  /* SO Transport Protocol Class 4 */
   ^
/usr/include/netinet/in.h:60:5: note: previous definition of =E2=80=98I=
PPROTO_TP=E2=80=99 was here
     IPPROTO_TP =3D 29,    /* SO Transport Protocol Class 4.  */
     ^
=2E./include/linux/in.h:46:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_DCCP=E2=80=99
   IPPROTO_DCCP =3D 33,  /* Datagram Congestion Control Protocol */
   ^
/usr/include/netinet/in.h:62:5: note: previous definition of =E2=80=98I=
PPROTO_DCCP=E2=80=99 was here
     IPPROTO_DCCP =3D 33,    /* Datagram Congestion Control Protocol.  =
*/
     ^
=2E./include/linux/in.h:48:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_IPV6=E2=80=99
   IPPROTO_IPV6 =3D 41,  /* IPv6-in-IPv4 tunnelling  */
   ^
/usr/include/netinet/in.h:64:5: note: previous definition of =E2=80=98I=
PPROTO_IPV6=E2=80=99 was here
     IPPROTO_IPV6 =3D 41,     /* IPv6 header.  */
     ^
=2E./include/linux/in.h:50:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_RSVP=E2=80=99
   IPPROTO_RSVP =3D 46,  /* RSVP Protocol   */
   ^
/usr/include/netinet/in.h:66:5: note: previous definition of =E2=80=98I=
PPROTO_RSVP=E2=80=99 was here
     IPPROTO_RSVP =3D 46,    /* Reservation Protocol.  */
     ^
=2E./include/linux/in.h:52:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_GRE=E2=80=99
   IPPROTO_GRE =3D 47,  /* Cisco GRE tunnels (rfc 1701,1702) */
   ^
/usr/include/netinet/in.h:68:5: note: previous definition of =E2=80=98I=
PPROTO_GRE=E2=80=99 was here
     IPPROTO_GRE =3D 47,    /* General Routing Encapsulation.  */
     ^
=2E./include/linux/in.h:54:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_ESP=E2=80=99
   IPPROTO_ESP =3D 50,  /* Encapsulation Security Payload protocol */
   ^
/usr/include/netinet/in.h:70:5: note: previous definition of =E2=80=98I=
PPROTO_ESP=E2=80=99 was here
     IPPROTO_ESP =3D 50,      /* encapsulating security payload.  */
     ^
=2E./include/linux/in.h:56:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_AH=E2=80=99
   IPPROTO_AH =3D 51,  /* Authentication Header protocol */
   ^
/usr/include/netinet/in.h:72:5: note: previous definition of =E2=80=98I=
PPROTO_AH=E2=80=99 was here
     IPPROTO_AH =3D 51,       /* authentication header.  */
     ^
=2E./include/linux/in.h:58:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_MTP=E2=80=99
   IPPROTO_MTP =3D 92,  /* Multicast Transport Protocol  */
   ^
/usr/include/netinet/in.h:74:5: note: previous definition of =E2=80=98I=
PPROTO_MTP=E2=80=99 was here
     IPPROTO_MTP =3D 92,    /* Multicast Transport Protocol.  */
     ^
=2E./include/linux/in.h:60:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_BEETPH=E2=80=99
   IPPROTO_BEETPH =3D 94,  /* IP option pseudo header for BEET */
   ^
/usr/include/netinet/in.h:76:5: note: previous definition of =E2=80=98I=
PPROTO_BEETPH=E2=80=99 was here
     IPPROTO_BEETPH =3D 94,   /* IP option pseudo header for BEET.  */
     ^
=2E./include/linux/in.h:62:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_ENCAP=E2=80=99
   IPPROTO_ENCAP =3D 98,  /* Encapsulation Header   */
   ^
/usr/include/netinet/in.h:78:5: note: previous definition of =E2=80=98I=
PPROTO_ENCAP=E2=80=99 was here
     IPPROTO_ENCAP =3D 98,    /* Encapsulation Header.  */
     ^
=2E./include/linux/in.h:64:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_PIM=E2=80=99
   IPPROTO_PIM =3D 103,  /* Protocol Independent Multicast */
   ^
/usr/include/netinet/in.h:80:5: note: previous definition of =E2=80=98I=
PPROTO_PIM=E2=80=99 was here
     IPPROTO_PIM =3D 103,    /* Protocol Independent Multicast.  */
     ^
=2E./include/linux/in.h:66:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_COMP=E2=80=99
   IPPROTO_COMP =3D 108,  /* Compression Header Protocol  */
   ^
/usr/include/netinet/in.h:82:5: note: previous definition of =E2=80=98I=
PPROTO_COMP=E2=80=99 was here
     IPPROTO_COMP =3D 108,    /* Compression Header Protocol.  */
     ^
=2E./include/linux/in.h:68:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_SCTP=E2=80=99
   IPPROTO_SCTP =3D 132,  /* Stream Control Transport Protocol */
   ^
/usr/include/netinet/in.h:84:5: note: previous definition of =E2=80=98I=
PPROTO_SCTP=E2=80=99 was here
     IPPROTO_SCTP =3D 132,    /* Stream Control Transmission Protocol. =
 */
     ^
=2E./include/linux/in.h:70:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_UDPLITE=E2=80=99
   IPPROTO_UDPLITE =3D 136, /* UDP-Lite (RFC 3828)   */
   ^
/usr/include/netinet/in.h:86:5: note: previous definition of =E2=80=98I=
PPROTO_UDPLITE=E2=80=99 was here
     IPPROTO_UDPLITE =3D 136, /* UDP-Lite protocol.  */
     ^
=2E./include/linux/in.h:74:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_RAW=E2=80=99
   IPPROTO_RAW =3D 255,  /* Raw IP packets   */
   ^
/usr/include/netinet/in.h:88:5: note: previous definition of =E2=80=98I=
PPROTO_RAW=E2=80=99 was here
     IPPROTO_RAW =3D 255,    /* Raw IP packets.  */
     ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:76:3: error: redeclaration of enumerator =E2=80=
=98IPPROTO_MAX=E2=80=99
   IPPROTO_MAX
   ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:90:5: note: previous definition of =E2=80=98I=
PPROTO_MAX=E2=80=99 was here
     IPPROTO_MAX
     ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:81:8: error: redefinition of =E2=80=98struct in=
_addr=E2=80=99
 struct in_addr {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:31:8: note: originally defined here
 struct in_addr
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:161:8: error: redefinition of =E2=80=98struct i=
p_mreq=E2=80=99
 struct ip_mreq  {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:264:8: note: originally defined here
 struct ip_mreq
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:166:8: error: redefinition of =E2=80=98struct i=
p_mreqn=E2=80=99
 struct ip_mreqn {
        ^
In file included from /usr/include/netinet/in.h:37:0,
                 from /usr/include/netdb.h:27,
                 from em_ipset.c:20:
/usr/include/x86_64-linux-gnu/bits/in.h:119:8: note: originally defined=
 here
 struct ip_mreqn
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:172:8: error: redefinition of =E2=80=98struct i=
p_mreq_source=E2=80=99
 struct ip_mreq_source {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:273:8: note: originally defined here
 struct ip_mreq_source
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:178:8: error: redefinition of =E2=80=98struct i=
p_msfilter=E2=80=99
 struct ip_msfilter {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:323:8: note: originally defined here
 struct ip_msfilter
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:190:8: error: redefinition of =E2=80=98struct g=
roup_req=E2=80=99
 struct group_req {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:300:8: note: originally defined here
 struct group_req
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:195:8: error: redefinition of =E2=80=98struct g=
roup_source_req=E2=80=99
 struct group_source_req {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:309:8: note: originally defined here
 struct group_source_req
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:201:8: error: redefinition of =E2=80=98struct g=
roup_filter=E2=80=99
 struct group_filter {
        ^
In file included from /usr/include/netdb.h:27:0,
                 from em_ipset.c:20:
/usr/include/netinet/in.h:344:8: note: originally defined here
 struct group_filter
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:213:8: error: redefinition of =E2=80=98struct i=
n_pktinfo=E2=80=99
 struct in_pktinfo {
        ^
In file included from /usr/include/netinet/in.h:37:0,
                 from /usr/include/netdb.h:27,
                 from em_ipset.c:20:
/usr/include/x86_64-linux-gnu/bits/in.h:127:8: note: originally defined=
 here
 struct in_pktinfo
        ^
In file included from ../include/linux/netfilter.h:7:0,
                 from /usr/include/xtables.h:18,
                 from em_ipset.c:26:
=2E./include/linux/in.h:221:8: error: redefinition of =E2=80=98struct s=
ockaddr_in=E2=80=99
 struct sockaddr_in {
        ^
In file included from /usr/include/netinet/in.h:23:0,
                 from /usr/include/netdb.h:27,
                 from em_ipset.c:20:
/usr/include/x86_64-linux-gnu/sys/socket.h:90:17: note: originally defi=
ned here
 typedef union { __SOCKADDR_ALLTYPES
                 ^
