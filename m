From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 14:16:51 +0100
Message-ID: <1277731011.2089.1.camel@achroite.uk.solarflarecom.com>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
	 <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:35307 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab0F1NQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 09:16:54 -0400
In-Reply-To: <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-28 at 14:58 +0200, Stanislaw Gruszka wrote:
> On Mon, 28 Jun 2010 07:36:04 -0500
> Amit Salecha <amit.salecha@qlogic.com> wrote:
> 
> > -	ethtool_op_set_flags(netdev, data);
> > -
> > -	hw_lro = (data & ETH_FLAG_LRO) ? QLCNIC_LRO_ENABLED : 0;
> > +	if (data & ETH_FLAG_LRO) {
> > +		hw_lro = QLCNIC_LRO_ENABLED;
> > +		netdev->features |= NETIF_F_LRO;
> > +	} else {
> > +		hw_lro = 0;
> > +		netdev->features &= ~NETIF_F_LRO;
> > +	}
> > 
> > Above hunk is unnecessary.
> 
> Yes, I did not describe that change in the changelog. I want to
> remove such usage of ethtool_op_set_flags() for my furher patches, where
> I plan to add return EOPNOTSUPP to ethtool_op_set_flags().

You might as well remove ethtool_op_set_flags() in that case, as this is
equivalent to the behaviour when ethtool_ops::set_flags is NULL.

It would be more useful to add a supported_flags parameter to
ethtool_op_set_flags() so it can check the requested flags against the
driver/hardware capabilities.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

