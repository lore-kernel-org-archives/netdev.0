From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next 0/5] Route ICMPv6 errors with the flow when ECMP in use
Date: Mon, 24 Oct 2016 11:28:47 +0200
Message-ID: <1477301332-23954-1-git-send-email-jkbs@redhat.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The motivation for this series is to route ICMPv6 error messages
together with the flow they belong to when multipath routing is in
use. It intends to bring the ECMP routing in IPv6 stack on par with
IPv4.

This enables the use of tools that rely on ICMP error messages such as
traceroute and makes PMTU discovery work both ways. However, for it to
work IPv6 flow labels have to be same in both directions
(i.e. reflected) or need to be chosen in a manner that ensures that
the flow going in the opposite direction would actually be routed to a
given path.

Changes have been tested in a virtual setup with a topology as below:

                  Re1 --- Hs1
                 /
 Hc --- Ri --- Rc
                 \
                  Re1 --- Hs2

 Hc  - client host
 HsX - server host
 Rc  - core router
 ReX - edge router
 Ri  - intermediate router

To test the changes, traceroute in UDP mode to the client host, with
flow label set, has been run from one of the server hosts. Full test
is available at [1].

-Jakub

[1] https://github.com/jsitnicki/tools/blob/master/net/tests/ecmp/test-ecmp-icmpv6-error-routing.sh


Jakub Sitnicki (5):
  ipv6: Fold rt6_info_hash_nhsfn() into its only caller
  net: Extend struct flowi6 with multipath hash
  ipv6: Use multipath hash from flow info if available
  ipv6: Compute multipath hash for sent ICMP errors from offending
    packet
  ipv6: Compute multipath hash for forwarded ICMP errors from offending
    packet

 include/linux/icmpv6.h |  2 ++
 include/net/flow.h     |  1 +
 net/ipv6/icmp.c        | 21 +++++++++++++++++++++
 net/ipv6/route.c       | 40 +++++++++++++++++++++++++++++-----------
 4 files changed, 53 insertions(+), 11 deletions(-)

-- 
2.7.4
