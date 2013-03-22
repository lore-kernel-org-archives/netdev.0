From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH] net: add ETH_P_802_3_MIN
Date: Fri, 22 Mar 2013 22:49:38 +0900
Message-ID: <20130322134938.GA4220@verge.net.au>
References: <1363854568-32228-1-git-send-email-horms@verge.net.au>
	<20130321.115608.570355867509300023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, isdn-iHCpqvpFUx0uJkBD2foKsQ@public.gmane.org, mchehab-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stefanr-MtYdepGKPcBMYopoZt5u/LNAH6kLmebB@public.gmane.org,
	linux1394-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130321.115608.570355867509300023.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 21, 2013 at 11:56:08AM -0400, David Miller wrote:
> From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> Date: Thu, 21 Mar 2013 17:29:28 +0900
> 
> > Add a new constant ETH_P_802_3_MIN, the minimum ethernet type for
> > an 802.3 frame. Frames with a lower value in the ethernet type field
> > are Ethernet II.
> > 
> > Also update all the users of this value that I could find to use the
> > new constant.
> > 
> > I anticipate adding some more users of this constant when
> > adding MPLS support to Open vSwtich.
> > 
> > As suggested by Jesse Gross.
> > 
> > Compile tested only.
> > 
> > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> 
> You missed a few cases:
> 
> drivers/media/dvb-core/dvb_net.c:       } while (p->ule_sndu_type < 1536);
> drivers/media/dvb-core/dvb_net.c:                               if (priv->ule_sndu_type < 1536) {
> net/atm/lec.h: *    is less than 1536(0x0600) MUST be encoded by placing that length
> drivers/net/wireless/ray_cs.c:  if (ntohs(proto) >= 1536) { /* DIX II ethernet frame */
> net/bridge/netfilter/ebtables.c:                if (FWINV2(ntohs(ethproto) >= 1536, EBT_IPROTO))
> include/linux/if_vlan.h:        if (ntohs(proto) >= 1536) {
> net/bluetooth/bnep/netdev.c:    if (proto >= 1536)
> net/openvswitch/flow.c: if (ntohs(proto) >= 1536)
> net/mac80211/tx.c:      } else if (ethertype >= 0x600) {
> net/wireless/util.c:    } else if (ethertype > 0x600) {
> 
> In fact, the last line looks like a bug, it should be >= not >.

Thanks for finding those.

> Could you take care of these bits and respin your patch?

Sure.
