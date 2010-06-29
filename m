From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Tue, 29 Jun 2010 09:59:32 -0700 (PDT)
Message-ID: <20100629.095932.186303178.davem@davemloft.net>
References: <20100628161412.7d9d0e4f@dhcp-lab-109.englab.brq.redhat.com>
	<1277734724.2089.10.camel@achroite.uk.solarflarecom.com>
	<1277822484.2112.19.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgruszka@redhat.com, amit.salecha@qlogic.com,
	netdev@vger.kernel.org, amwang@redhat.com,
	anirban.chakraborty@qlogic.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38729
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932200Ab0F2Q7T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 12:59:19 -0400
In-Reply-To: <1277822484.2112.19.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 29 Jun 2010 15:41:24 +0100

> On Mon, 2010-06-28 at 15:18 +0100, Ben Hutchings wrote:
>> On Mon, 2010-06-28 at 16:14 +0200, Stanislaw Gruszka wrote:
>> [...]
>> > My plan is something like that:
>> > 
>> > static const struct ethtool_ops my_ethtool_ops = {
>> >         .get_flags              = ethtool_op_get_flags,
>> >         .set_flags              = ethtool_op_set_flags,
>> > 	.supported_flags	= ETH_FLAG_LRO
>> > }
>> > 
>> > Plus op->supported_flags check in ethtool_op_set_flags. That will allow
>> > to define flags per driver. There is also possible to add supported_flags
>> > to netdev, but I would like to avoid that - in such case drivers can use
>> > custom .set_flags function.
>> 
>> Sounds good to me.
> 
> On second thoughts, this is not going work - supported_flags may need to
> be different for different chips handled by the same driver.  In fact,
> this is already the case in sfc.  So I think you should do what I
> suggested previously - add a supported_flags parameter to
> ethtool_op_set_flags.

I think this is necessary too, otherwise we'll need to have N copies of
ethtool_ops in a driver in this situation.
