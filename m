From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: IPsec policy database customization proposal
Date: Mon, 21 Jul 2014 13:01:43 +0200
Message-ID: <20140721110143.GA3396@secunet.com>
References: <CADdy8Hq=Pi2PwuA4JLhd2smV7FKSwFLGCDvbCpviSqxhFaKTfg@mail.gmail.com>
 <20140708113541.GT32371@secunet.com>
 <CADdy8Hps=2Xfs5TTgSQZtCKTCmL32AyxbuCeT59s3MmRZF6Bbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36551 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754350AbaGULBy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2014 07:01:54 -0400
Content-Disposition: inline
In-Reply-To: <CADdy8Hps=2Xfs5TTgSQZtCKTCmL32AyxbuCeT59s3MmRZF6Bbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2014 at 09:35:41AM +0200, Christophe Gouault wrote:
> 
> There are several multi-field classification algorithms, but few seem
> adapted to SPD/SAD lookup:
> 
> - linear search
> - hierarchical tries
> - set-pruning tries
> - grid-of-tries
> - bit-vector linear search
> - cross-producting

We used a cross-producting algorithm for a while to do
policy lookups. It scaled for policy lookups because
the policy database was rather static. It does not
scale at all for state lookups because states change
quite often and the cross-product table must be
reconstructed whenever the database changes.

> 
> As far as I understand, the only things that concerned you about the
> patchset were:
> 
> - using /proc to configure the algorithm, you prefer netlink.
> - adding a configuration API that could potentially be later
> deprecated. My feeling is that the choice of a brand new SPD algorithm
> will not happen before long.
> - calculation of thresholds is not automatic. As I already suggested,
> it may be configured by a daemon if an automatic system is needed.

Why do you think a daemon can do a better job in automatic
configuration? We maintain the policy hashlists inside the
kernel, so we should know the best about their sizes.

But I agree that not everybody wants to have such an automatic
configuration, so we need some knobs to tune it from userspace.

> 
> What if I rework the patchset and replace the configuration via /proc
> by a configuration by netlink:
> 
> - supporting message XFRM_MSG_NEWSPDINFO from userland, with
>   attribute XFRMA_SPD_HTHRESH
> - adding XFRMA_SPD_HTHRESH attribute to XFRM_MSG_NEWSPDINFO messages
> from the kernel in reply to XFRM_MSG_GETSPDINFO?
> 

OK.
