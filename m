From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [RFC PATCH 0/2] RFC: Caching IPv6 exthdr in skb->cb[]
Date: Mon, 03 Sep 2012 23:15:57 +0200
Message-ID: <20120903211504.8851.6894.stgit@dragon>
References: <Pine.GSO.4.63.1208291427170.26100@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: "Patrick McHardy" <kaber@trash.net>,
	Hans Schillstrom <hans@schillstrom.com>,
	Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.63.1208291427170.26100@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Patrick and Hans,

This is my followup to:
  [PATCH 2/3] ipvs: Fix faulty IPv6 extension header handling in IPVS

Where you proposed improving the overall architecture of IPv6
extension header parsing not only for IPVS but for other related
Netfilter subsystems as well.

We discussed using/extending inet6_skb_parm/IP6CB.  There was not
enough room for extending inet6_skb_parm directly, so I have
introduced a struct inet6_skb_exthdr_cache/IP6CB_EXTHDR, which extend
IP6CB.

The question is if this approach will work.  Can netfilter be allowed
to modify data after inet6_skb_parm/IP6CB, given all the different
HOOKs ?

If we find this is a valid approach, then I'll update the IPVS patches
to also use this.

This patchset is based upon:
 Patrick's tree:  git://github.com/kaber/nf-next-ipv6-nat.git

---

Jesper Dangaard Brouer (2):
      netfilter: More users of ipv6_find_hdr_cb()
      net: Cache IPv6 extension header "skip" parsing


 include/linux/ipv6.h                      |   15 +++++++++++
 include/linux/netfilter_ipv6/ip6_tables.h |   40 +++++++++++++++++++++++++++++
 net/ipv6/netfilter/ip6_tables.c           |    2 +
 net/netfilter/xt_TPROXY.c                 |    2 +
 net/netfilter/xt_socket.c                 |    2 +
 5 files changed, 58 insertions(+), 3 deletions(-)


--
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
