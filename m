From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add ETH_P_802_3_MIN
Date: Thu, 21 Mar 2013 11:56:08 -0400 (EDT)
Message-ID: <20130321.115608.570355867509300023.davem@davemloft.net>
References: <1363854568-32228-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	stefanr@s5r6.in-berlin.de, isdn@linux-pingi.de, mchehab@redhat.com,
	linux1394-devel@lists.sourceforge.net, linux-media@vger.kernel.org,
	dev@openvswitch.org
To: horms@verge.net.au
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1363854568-32228-1-git-send-email-horms@verge.net.au>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>
Date: Thu, 21 Mar 2013 17:29:28 +0900

> Add a new constant ETH_P_802_3_MIN, the minimum ethernet type for
> an 802.3 frame. Frames with a lower value in the ethernet type field
> are Ethernet II.
> 
> Also update all the users of this value that I could find to use the
> new constant.
> 
> I anticipate adding some more users of this constant when
> adding MPLS support to Open vSwtich.
> 
> As suggested by Jesse Gross.
> 
> Compile tested only.
> 
> Signed-off-by: Simon Horman <horms@verge.net.au>

You missed a few cases:

drivers/media/dvb-core/dvb_net.c:       } while (p->ule_sndu_type < 1536);
drivers/media/dvb-core/dvb_net.c:                               if (priv->ule_sndu_type < 1536) {
net/atm/lec.h: *    is less than 1536(0x0600) MUST be encoded by placing that length
drivers/net/wireless/ray_cs.c:  if (ntohs(proto) >= 1536) { /* DIX II ethernet frame */
net/bridge/netfilter/ebtables.c:                if (FWINV2(ntohs(ethproto) >= 1536, EBT_IPROTO))
include/linux/if_vlan.h:        if (ntohs(proto) >= 1536) {
net/bluetooth/bnep/netdev.c:    if (proto >= 1536)
net/openvswitch/flow.c: if (ntohs(proto) >= 1536)
net/mac80211/tx.c:      } else if (ethertype >= 0x600) {
net/wireless/util.c:    } else if (ethertype > 0x600) {

In fact, the last line looks like a bug, it should be >= not >.

Could you take care of these bits and respin your patch?

Thanks!
