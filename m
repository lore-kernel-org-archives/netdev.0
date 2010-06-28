From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 14:58:19 +0200
Message-ID: <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	<99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Amit Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751950Ab0F1M6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jun 2010 08:58:25 -0400
In-Reply-To: <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 Jun 2010 07:36:04 -0500
Amit Salecha <amit.salecha@qlogic.com> wrote:

> -	ethtool_op_set_flags(netdev, data);
> -
> -	hw_lro = (data & ETH_FLAG_LRO) ? QLCNIC_LRO_ENABLED : 0;
> +	if (data & ETH_FLAG_LRO) {
> +		hw_lro = QLCNIC_LRO_ENABLED;
> +		netdev->features |= NETIF_F_LRO;
> +	} else {
> +		hw_lro = 0;
> +		netdev->features &= ~NETIF_F_LRO;
> +	}
> 
> Above hunk is unnecessary.

Yes, I did not describe that change in the changelog. I want to
remove such usage of ethtool_op_set_flags() for my furher patches, where
I plan to add return EOPNOTSUPP to ethtool_op_set_flags().

Stanislaw
