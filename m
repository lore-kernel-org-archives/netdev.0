From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH RFC 0/3] Preserve skb->mark through VTI tunnels
Date: Tue, 26 May 2015 15:41:10 -0700
Message-ID: <20150526223849.1328.64212.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: steffen.klassert@secunet.com, davem@davemloft.net,
	herbert@gondor.apana.org.au
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


 net/ipv4/ip_vti.c     |    9 ++++++---
 net/ipv6/ip6_vti.c    |    8 ++++++--
 net/xfrm/xfrm_input.c |   17 ++++++++++++++++-
 3 files changed, 28 insertions(+), 6 deletions(-)

--
