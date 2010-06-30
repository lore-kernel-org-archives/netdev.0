From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [Pv-drivers] [PATCH net-next-2.6 3/3] vmxnet3: Remove
 incorrect implementation of ethtool_ops::get_flags()
Date: Wed, 30 Jun 2010 16:58:54 +0100
Message-ID: <1277913534.2082.28.camel@achroite.uk.solarflarecom.com>
References: <1277901872.2082.10.camel@achroite.uk.solarflarecom.com>
	 <1277902060.2082.13.camel@achroite.uk.solarflarecom.com>
	 <8B1F619C9F5F454E81D90D3C161698D703362510AE@EXCH-MBX-3.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Bhavesh Davda <bhavesh@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12255 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756312Ab0F3P65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 11:58:57 -0400
In-Reply-To: <8B1F619C9F5F454E81D90D3C161698D703362510AE@EXCH-MBX-3.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-30 at 08:44 -0700, Bhavesh Davda wrote:
> Thanks for fixing this, Ben! Had to look at ethtool-2.6.34 src to
> convince myself of the correctness. Looks good to me. 
> 
> Signed-off-by: Bhavesh Davda <bhavesh@vmware.com>
> 
> ps: I do wonder, however, why not always use ethtool_op_get_flags for
> all drivers, and mask whatever is returned by the driver specific
> dev->ethtool_ops->get_flags with flags_dup_features instead of this
> approach?

I think you're right that ethtool_op_get_flags could be the implicit
default (i.e. used if ethtool_ops::get_flags is NULL) and drivers should
not have to set it.  Following this change, no drivers in net-next-2.6
will be using any other implementation.  However, I don't think
ethtool_ops::get_flags should be removed - in future there are likely to
be additional ethtool flags that do not correspond to net device feature
flags, and some drivers will need a different implementation.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

