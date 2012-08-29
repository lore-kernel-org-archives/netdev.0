From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 02/19] Cleaning up the IPv6 MTU checking in the IPVS xmit
 code, by using a common helper function __mtu_check_toobig_v6().
Date: Wed, 29 Aug 2012 10:02:37 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1208290959010.32281@ask.diku.dk>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
 <1346190539-9963-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1346190539-9963-3-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Just a little nitpick.

The original title/subj was:
  "ipvs: IPv6 MTU checking cleanup and bugfix"

And the curr/used title/subj were part of the commit text.


On Tue, 28 Aug 2012, Patrick McHardy wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
>
Insert:
  Cleaning up the IPv6 MTU checking in the IPVS xmit code, by using a
  common helper function __mtu_check_toobig_v6().

> The MTU check for tunnel mode can also use this helper as
> ntohs(old_iph->payload_len) + sizeof(struct ipv6hdr) is qual to
> skb->len.  And the 'mtu' variable have been adjusted before
> calling helper.
>
> Notice, this also fixes a bug, as the the MTU check in ip_vs_dr_xmit_v6()
> were missing a check for skb_is_gso().
>
> This bug e.g. caused issues for KVM IPVS setups, where different
> Segmentation Offloading techniques are utilized, between guests,
> via the virtio driver.  This resulted in very bad performance,
> due to the ICMPv6 "too big" messages didn't affect the sender.
>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> ---
> net/netfilter/ipvs/ip_vs_xmit.c |   21 +++++++++++++++------
> 1 files changed, 15 insertions(+), 6 deletions(-)

[cut]

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
