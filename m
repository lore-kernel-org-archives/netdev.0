From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 16:14:12 +0200
Message-ID: <20100628161412.7d9d0e4f@dhcp-lab-109.englab.brq.redhat.com>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	<99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
	<20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
	<99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41648 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751284Ab0F1OOW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 10:14:22 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jun 2010 08:09:18 -0500
Amit Salecha <amit.salecha@qlogic.com> wrote:

> >> I plan to add return EOPNOTSUPP to ethtool_op_set_flags().
> I don't know what it will buy you.
> 
> Why don't you submit separate patch for below hunk, after your EOPNOTSUPP in ethtool_op_set_flags get accepted.

To do not brake things between patches, I plan to post one patch
touching every ethtool_op_set_flags() call in every driver (see below).
Hence removing that function where possible will make my work easier.
Beside I think toggling NETIF_F_FLAG bits directly is just simpler
than calling ethtool_op_set_flags() only for that purpose.

On Mon, 28 Jun 2010 14:16:51 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> > Yes, I did not describe that change in the changelog. I want to
> > remove such usage of ethtool_op_set_flags() for my furher patches, where
> > I plan to add return EOPNOTSUPP to ethtool_op_set_flags().
> 
> You might as well remove ethtool_op_set_flags() in that case, as this is
> equivalent to the behaviour when ethtool_ops::set_flags is NULL.

In case of qlcnic we change LRO settings, so removing it here is wrong.

> It would be more useful to add a supported_flags parameter to
> ethtool_op_set_flags() so it can check the requested flags against the
> driver/hardware capabilities.

My plan is something like that:

static const struct ethtool_ops my_ethtool_ops = {
        .get_flags              = ethtool_op_get_flags,
        .set_flags              = ethtool_op_set_flags,
	.supported_flags	= ETH_FLAG_LRO
}

Plus op->supported_flags check in ethtool_op_set_flags. That will allow
to define flags per driver. There is also possible to add supported_flags
to netdev, but I would like to avoid that - in such case drivers can use
custom .set_flags function.

Stanislaw
