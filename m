From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] skbuff: fix skb_segment with zero copy skbs
Date: Tue, 11 Mar 2014 16:27:14 -0400 (EDT)
Message-ID: <20140311.162714.1118698288267206477.davem@davemloft.net>
References: <1394468807-25980-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jbenc@redhat.com,
	netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394468807-25980-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 10 Mar 2014 18:29:01 +0200

> This fixes a bug in skb_segment where it moves frags
> between skbs without orphaning them.
> This causes userspace to assume it's safe to
> reuse the buffer, and receiver gets corrupted data.
> This further might leak information from the
> transmitter on the wire.
> 
> To fix track which skb does a copied frag belong
> to, and orphan frags when copying them.
> 
> As we are tracking multiple skbs here, using
> short names (skb,nskb,fskb,skb_frag,frag) becomes confusing.
> So before adding another one, I refactor these names
> slightly.
> 
> Patch is split out to make it easier to
> verify that all trasformations are trivially correct.
> 
> The problem was observed in the field,
> so I think that the patch is necessary on stable
> as well.

Series applied and queued up for -stable, thanks for fixing this.
