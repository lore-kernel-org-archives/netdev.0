From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2 0/6] inet: frags: cleanup and kmem_cache use
Date: Fri,  1 Aug 2014 12:29:42 +0200
Message-ID: <1406888988-20742-1-git-send-email-nikolay@redhat.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Westphal <fw@strlen.de>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Alexander Aring <alex.aring@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753515AbaHAKax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 06:30:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
This patchset does a couple of small cleanups in patches 1-5 and then in
patch 06 it introduces the use of kmem_cache for allocation/freeing of
inet_frag_queue+header objects.

v2: Broke up patch 02 into 3 patches as David suggested

Here are the results of a couple of netperf runs:
netperf options: -l 30 -I95,5 -i 15,10 -m 64k

- 10 gig before the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.155.1 () port 0 AF_INET : +/-2.500% @ 95% conf. 
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      442466      0    7551.39
212992           30.00      439130           7494.45

- 10 gig after the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.155.1 () port 0 AF_INET : +/-2.500% @ 95% conf. 
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      458846      0    7830.94
212992           30.00      457575           7809.25

- Virtio before the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.144.1 () port 0 AF_INET : +/-2.500% @ 95% conf.
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      735000      0    12543.96
212992           30.00      560322           9562.79

- Virtio after the patchset
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.144.1 () port 0 AF_INET : +/-2.500% @ 95% conf. 
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992   64000   30.00      731729      0    12488.14
212992           30.00      647241           11046.21

CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
CC: Florian Westphal <fw@strlen.de>
CC: David S. Miller <davem@davemloft.net>
CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
CC: James Morris <jmorris@namei.org>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Alexander Aring <alex.aring@gmail.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>

Best regards,
 Nikolay Aleksandrov


Nikolay Aleksandrov (6):
  inet: frags: use INC_STATS_BH in the ipv6 reassembly code
  inet: frags: rename last_in to flags
  inet: frags: enum the flag definitions and add descriptions
  inet: frags: fix function declaration alignment in inet_fragment
  inet: frags: use INET_FRAG_EVICTED to prevent icmp messages
  inet: frags: use kmem_cache for inet_frag_queue

 include/net/inet_frag.h                 | 50 +++++++++++++++++++++++++--------
 net/ieee802154/reassembly.c             | 21 ++++++++------
 net/ipv4/inet_fragment.c                | 41 ++++++++++++++++-----------
 net/ipv4/ip_fragment.c                  | 35 ++++++++++++-----------
 net/ipv6/netfilter/nf_conntrack_reasm.c | 20 +++++++------
 net/ipv6/reassembly.c                   | 45 ++++++++++++++++-------------
 6 files changed, 133 insertions(+), 79 deletions(-)

-- 
1.9.3
