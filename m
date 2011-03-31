From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] net: ethtool support to configure number of RX rings
Date: Thu, 31 Mar 2011 14:05:20 +0100
Message-ID: <1301576720.10056.112.camel@localhost>
References: <1301482774-2173-1-git-send-email-amit.salecha@qlogic.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80FD10E8BD6@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38371 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab1CaNFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 09:05:24 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80FD10E8BD6@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-31 at 00:55 -0500, Amit Salecha wrote:
> > o Ethtool hook to configure number of RX rings.
> > o Implementation is scalable to support configuring TX rings.
> > o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
> >   but it is tigtly coupled with RX flow hash configuration.
> > o Patches for qlcnic and netxen_nic driver supporting this features
> >   will follow soon.
> >
> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> > ---
> >  include/linux/ethtool.h |   20 ++++++++++++++++++++
> >  net/core/ethtool.c      |   33 +++++++++++++++++++++++++++++++++
> >  2 files changed, 53 insertions(+), 0 deletions(-)
> >
> > diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> > index aac3e2e..de0decd 100644
> > --- a/include/linux/ethtool.h
> > +++ b/include/linux/ethtool.h
> > @@ -226,6 +226,21 @@ struct ethtool_ringparam {
> >       __u32   tx_pending;
> >  };
> >
> > +/* for configuring number of RX ring */
> > +struct ethtool_ring {
> > +     __u32   cmd;    /* ETHTOOL_{G,S}RING */
> > +
> > +     /* Read only attributes.  These indicate the maximum number
> > +      * of RX rings the driver will allow the user to set.
> > +      */
> > +     __u32   rx_max;
> > +
> > +     /* Values changeable by the user.  The valid values are
> > +      * in the range 1 to the "*_max" counterpart above.
> > +      */
> > +     __u32   rx_pending;
> > +};
> > +
> 
> Current implementation can't scale to support TX rings. Because once
> structure is defined, that can't be changed.
> As tools will have dependency on it.
> If configuring tx rings need to be supported, I need to define Tx
> parameters in struct ethtool_ring now.
> Currently qlcnic and netxen_nic driver doesn't have requirement to
> configure number of tx rings.
> Should I define tx parameters in struct ethtool_ring ?

You could take this patch: http://patchwork.ozlabs.org/patch/65202/
but drop the affinity control from it.

Your implementation of set_channels() would then refuse all changes to
the numbers of TX/other/combined channels.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

