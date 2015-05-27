From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [ipsec PATCH 0/3] Preserve skb->mark through VTI tunnels
Date: Wed, 27 May 2015 07:16:37 -0700
Message-ID: <20150527141042.1576.47399.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-crypto@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au
To: steffen.klassert@secunet.com, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are meant to try and address the fact the VTI tunnels are
currently overwriting the skb->mark value.  I am generally happy with the
first two patches, however the third patch still modifies the skb->mark,
though it undoes after the fact.

The main problem I am trying to address is the fact that currently if I use
an v6 over v6 VTI tunnel I cannot receive any traffic on the interface as
the skb->mark is bleeding through and causing the traffic to be dropped.

---

Alexander Duyck (3):
      ip_vti/ip6_vti: Do not touch skb->mark on xmit
      xfrm: Override skb->mark with tunnel->parm.i_key in xfrm_input
      ip_vti/ip6_vti: Preserve skb->mark after rcv_cb call


 net/ipv4/ip_vti.c     |   14 ++++++++++----
 net/ipv6/ip6_vti.c    |   13 ++++++++++---
 net/xfrm/xfrm_input.c |   17 ++++++++++++++++-
 3 files changed, 36 insertions(+), 8 deletions(-)

--
