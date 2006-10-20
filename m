From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 0/2] [NET]: RFC-compliant UDP-Lite support (RFC 3828)
Date: Fri, 20 Oct 2006 16:27:26 +0100
Message-ID: <200610201627.27358@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, alan@lxorguk.ukuu.org.uk, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, kaber@coreworks.de, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:34524 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1946178AbWJTPct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 11:32:49 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[UDP] This is a finalised, polished and tidied up revision of the full UDP-Lite patch. 
      It features:
	* RFC 3828 - compliant support for UDP-Lite over IPv4 and IPv6
	* consolidated and shared generic code between UDP and UDP-Lite
          (thanks to the help of Dave Miller)
	* separation of files specific to UDP-Lite
	* MIB/statistics support in /proc/net/snmp{6} and /proc/net/udplite{6}
	* basic netfilter/xfrm support
	* API documentation in Documentation/networking/udplite.txt

C h a n g e l o g
-----------------
Although no negative feedback has been received from IPv6-developers, the integration of UDP-Litev6
has been overhauled, in particular to make the protocol initialisation in af_inet6.c consistent with
the existing code. The detailed changes:

        * added IPV6_ADDRFORM support for UDP-Lite
	* updated documentation with regard to most recent changes
        * rewrote the UDP-Lite initialisation in af_inet6.c from scratch - it is now fully
          consistent with the existing coding style
	* fixed typos
        * made the error handling in udpv6_queue_rcv_skb consistent: to return `-1' on error
          (it used to return 0 when either skb_checksum_complete or sock_queue_rcv_skb failed)

Apart from this, the v6-side technically is not much different from the v4-side, which has been
under revision/discussion as an RFC patch for a while. The code has been thoroughly tested.


If there are no further objections or code comments, I propose this for inclusion in 2.6.20.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
--

 Documentation/networking/udplite.txt |  281    281 +   0 -     0 !
 include/linux/in.h                   |    1    1 +     0 -     0 !
 include/linux/socket.h               |    1    1 +     0 -     0 !
 include/linux/udp.h                  |   12    12 +    0 -     0 !
 include/net/ipv6.h                   |   12    9 +     3 -     0 !
 include/net/transp_v6.h              |    2    2 +     0 -     0 !
 include/net/udp.h                    |   91    87 +    4 -     0 !
 include/net/udplite.h                |  149    149 +   0 -     0 !
 include/net/xfrm.h                   |    2    2 +     0 -     0 !
 net/ipv4/af_inet.c                   |    8    7 +     1 -     0 !
 net/ipv4/netfilter/ipt_LOG.c         |   11    8 +     3 -     0 !
 net/ipv4/proc.c                      |   13    13 +    0 -     0 !
 net/ipv4/udp.c                       |  481    285 +   196 -   0 !
 net/ipv4/udplite.c                   |  118    118 +   0 -     0 !
 net/ipv4/xfrm4_policy.c              |    1    1 +     0 -     0 !
 net/ipv6/af_inet6.c                  |   21    20 +    1 -     0 !
 net/ipv6/ipv6_sockglue.c             |   11    9 +     2 -     0 !
 net/ipv6/netfilter/ip6t_LOG.c        |   10    7 +     3 -     0 !
 net/ipv6/proc.c                      |   11    11 +    0 -     0 !
 net/ipv6/udp.c                       |  330    189 +   141 -   0 !
 net/ipv6/udplite.c                   |  103    103 +   0 -     0 !
 net/ipv6/xfrm6_policy.c              |    1    1 +     0 -     0 !
 net/netfilter/xt_multiport.c         |    5    3 +     2 -     0 !
 net/netfilter/xt_tcpudp.c            |   20    19 +    1 -     0 !
 24 files changed, 1338 insertions(+), 357 deletions(-)
