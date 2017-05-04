From: Daniel Borkmann <daniel@iogearbox.net>
Subject: iproute2 build error due to sr-ipv6 lwtunnel
Date: Thu, 04 May 2017 11:13:39 +0200
Message-ID: <590AF0C3.6070006@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56341 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752691AbdEDJNw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 05:13:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I'm getting the following build error from e8493916a8ed ("iproute:
add support for SR-IPv6 lwtunnel encapsulation"). Reverting your
commit makes iproute2 build again for me. Please take a look.

[...]
     CC       iplink_vrf.o
     CC       iproute_lwtunnel.o
In file included from ../include/linux/seg6.h:18:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:131:26: error: expected identifier before numeric constant
  #define IPPROTO_HOPOPTS  0 /* IPv6 hop-by-hop options */
                           ^
In file included from /usr/include/resolv.h:57:0,
                  from ../include/utils.h:6,
                  from iproute_lwtunnel.c:32:
/usr/include/netinet/in.h:196:8: error: redefinition of ‘struct in6_addr’
  struct in6_addr
         ^
In file included from ../include/linux/seg6.h:18:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:32:8: note: originally defined here
  struct in6_addr {
         ^
In file included from /usr/include/resolv.h:57:0,
                  from ../include/utils.h:6,
                  from iproute_lwtunnel.c:32:
/usr/include/netinet/in.h:237:8: error: redefinition of ‘struct sockaddr_in6’
  struct sockaddr_in6
         ^
In file included from ../include/linux/seg6.h:18:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:49:8: note: originally defined here
  struct sockaddr_in6 {
         ^
In file included from /usr/include/resolv.h:57:0,
                  from ../include/utils.h:6,
                  from iproute_lwtunnel.c:32:
/usr/include/netinet/in.h:273:8: error: redefinition of ‘struct ipv6_mreq’
  struct ipv6_mreq
         ^
In file included from ../include/linux/seg6.h:18:0,
                  from iproute_lwtunnel.c:26:
../include/linux/in6.h:59:8: note: originally defined here
  struct ipv6_mreq {
         ^
iproute_lwtunnel.c: In function ‘parse_encap_seg6’:
iproute_lwtunnel.c:375:3: warning: passing argument 3 of ‘inet_get_addr’ from incompatible pointer type [enabled by default]
    inet_get_addr(s, NULL, &srh->segments[i]);
    ^
In file included from iproute_lwtunnel.c:32:0:
../include/utils.h:241:5: note: expected ‘struct in6_addr *’ but argument is of type ‘struct in6_addr *’
  int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6);
      ^
make[1]: *** [iproute_lwtunnel.o] Error 1
make: *** [all] Error 2
[root@localhost iproute]#

Thanks,
Daniel
