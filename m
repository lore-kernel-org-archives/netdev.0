From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Tue, 29 Jun 2010 16:05:23 +0100
Message-ID: <1277823923.2112.26.camel@achroite.uk.solarflarecom.com>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
	 <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
	 <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org>
	 <20100628161412.7d9d0e4f@dhcp-lab-109.englab.brq.redhat.com>
	 <1277734724.2089.10.camel@achroite.uk.solarflarecom.com>
	 <1277822484.2112.19.camel@achroite.uk.solarflarecom.com>
	 <20100629170025.7a130e28@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Amit Salecha <amit.salecha@qlogic.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51510 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756303Ab0F2PF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 11:05:26 -0400
In-Reply-To: <20100629170025.7a130e28@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-29 at 17:00 +0200, Stanislaw Gruszka wrote:
> On Tue, 29 Jun 2010 15:41:24 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > On Mon, 2010-06-28 at 15:18 +0100, Ben Hutchings wrote:
> > > On Mon, 2010-06-28 at 16:14 +0200, Stanislaw Gruszka wrote:
> > > [...]
> > > > My plan is something like that:
> > > > 
> > > > static const struct ethtool_ops my_ethtool_ops = {
> > > >         .get_flags              = ethtool_op_get_flags,
> > > >         .set_flags              = ethtool_op_set_flags,
> > > > 	.supported_flags	= ETH_FLAG_LRO
> > > > }
> > > > 
> > > > Plus op->supported_flags check in ethtool_op_set_flags. That will allow
> > > > to define flags per driver. There is also possible to add supported_flags
> > > > to netdev, but I would like to avoid that - in such case drivers can use
> > > > custom .set_flags function.
> > > 
> > > Sounds good to me.
> > 
> > On second thoughts, this is not going work - supported_flags may need to
> > be different for different chips handled by the same driver.  
> 
> I thought about driver custom ethtool_ops::set_flags in that case.
> 
> > In fact,
> > this is already the case in sfc.  So I think you should do what I
> > suggested previously - add a supported_flags parameter to
> > ethtool_op_set_flags.
> 
> What about call from net/core/ethtool.c ? 

ethtool_op_set_flags() doesn't provide a correct default behaviour since
it ignores unknown flags.  So it cannot be used directly as an
implementation of ethtool_ops::set_flags even now.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

