From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/5] skbuff: fix skb_segment with zero copy skbs
Date: Mon, 10 Mar 2014 18:29:01 +0200
Message-ID: <1394468807-25980-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jbenc@redhat.com, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a bug in skb_segment where it moves frags
between skbs without orphaning them.
This causes userspace to assume it's safe to
reuse the buffer, and receiver gets corrupted data.
This further might leak information from the
transmitter on the wire.

To fix track which skb does a copied frag belong
to, and orphan frags when copying them.

As we are tracking multiple skbs here, using
short names (skb,nskb,fskb,skb_frag,frag) becomes confusing.
So before adding another one, I refactor these names
slightly.

Patch is split out to make it easier to
verify that all trasformations are trivially correct.

The problem was observed in the field,
so I think that the patch is necessary on stable
as well.

Michael S. Tsirkin (5):
  skbuff: skb_segment: s/frag/nskb_frag/
  skbuff: skb_segment: s/skb_frag/frag/
  skbuff: skb_segment: s/skb/head_skb/
  skbuff: skb_segment: s/fskb/list_skb/
  skbuff: skb_segment: orphan frags before copying

 net/core/skbuff.c | 100 +++++++++++++++++++++++++++++-------------------------
 1 file changed, 54 insertions(+), 46 deletions(-)

-- 
MST
