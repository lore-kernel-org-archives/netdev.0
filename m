From: Vicente Feito <vicente.feito@gmail.com>
Subject: Re: [PATCH 2.6.12-rc1-mm1] net/ethernet/eth.c - eth_header
Date: Wed, 23 Mar 2005 18:15:32 +0000
Message-ID: <200503231815.33162.vicente.feito@gmail.com>
References: <200503231734.59277.vicente.feito@gmail.com> <4241D691.5000707@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4241D691.5000707@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 23 March 2005 08:50 pm, Jeff Garzik wrote:
> Vicente Feito wrote:
> > Hi,
> > Please consider applying (or droping).
> > Thank you.
> >
> > Description: This patch prevent drivers from calling eth_header with a
> > 802.3 frame using a len>1536. In such a case returns -EINVAL, which was
> > hard to choose because the ETH_HLEN is supposed to return.
> >
> > Signed-off-by: Vicente Feito <vicente.feito@gmail.com>
> >
> >
> > ------------------------------------------------------------------------
> >
> > --- linux-2.6.12-rc1-mm1/net/ethernet/eth.c.orig 2005-03-22
> > 12:49:08.000000000 +0000 +++
> > linux-2.6.12-rc1-mm1/net/ethernet/eth.c 2005-03-22 12:49:36.000000000
> > +0000 @@ -78,6 +78,8 @@ int eth_header(struct sk_buff *skb, stru
> >  {
> >   struct ethhdr *eth = (struct ethhdr *)skb_push(skb,ETH_HLEN);
> >
> > + if (type == ETH_P_802_3 && len >= 1536)
> > +  return -EINVAL;
>
> Why?  Won't this break for jumbo frames?
>
>  Jeff
True, I completely forgot about it, I was having problems with a driver and I 
though this would be a correct approach for size violation avoidance, but I 
guess it doesn't have much sense to change len >= 1536 by the 9000 of a jumbo 
packet, sorry.

Vicente
