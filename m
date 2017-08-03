From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 0/4] IP: cleanup LSRR option processing
Date: Thu,  3 Aug 2017 18:07:04 +0200
Message-ID: <cover.1501775813.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37960 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751010AbdHCQHc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Aug 2017 12:07:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The __ip_options_echo() function expect a valid dst entry in skb->dst;
as result we sometimes need to preserve the dst entry for the whole IP
RX path.

The current usage of skb->dst looks more a relic from ancient past that
a real functional constraint. This patchset tries to remove such usage,
and than drops some hacks currently in place in the IP code to keep
skb->dst around.

__ip_options_echo() uses of skb->dst for two different purposes: retrieving
the netns assicated with the skb, and modify the ingress packet LSRR address
list. 

The first patch removes the code modifying the ingress packet, and the second
one provides an explicit netns argument to __ip_options_echo(). The following
patches cleanup the current code keeping arund skb->dst for __ip_options_echo's
sake.

Updating the __ip_options_echo() function has been previously discussed here:

http://marc.info/?l=linux-netdev&m=150064533516348&w=2

Paolo Abeni (4):
  IP: do not modify ingress packet IP option in ip_options_echo()
  ip/options: explicitly provide net ns to __ip_options_echo()
  Revert "ipv4: keep skb->dst around in presence of IP options"
  udp: no need to preserve skb->dst

 include/net/ip.h       |  9 +++++----
 include/net/tcp.h      |  5 +++--
 net/ipv4/icmp.c        |  4 ++--
 net/ipv4/ip_options.c  |  9 +++------
 net/ipv4/ip_output.c   |  2 +-
 net/ipv4/ip_sockglue.c | 16 +++++-----------
 net/ipv4/syncookies.c  |  2 +-
 net/ipv4/tcp_ipv4.c    |  2 +-
 net/ipv4/udp.c         | 13 +++++--------
 9 files changed, 26 insertions(+), 36 deletions(-)

-- 
2.13.3
