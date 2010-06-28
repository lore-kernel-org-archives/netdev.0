From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCH -next] qlcnic: fail when try to setup unsupported
 features
Date: Mon, 28 Jun 2010 08:09:18 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F82CB7D4E@MNEXMB2.qlogic.org>
References: <20100628113134.0c5208b0@dhcp-lab-109.englab.brq.redhat.com>
	<99737F4847ED0A48AECC9F4A1974A4B80F82CB7D46@MNEXMB2.qlogic.org>
 <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Amerigo Wang <amwang@redhat.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:18661 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751665Ab0F1NJW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 09:09:22 -0400
In-Reply-To: <20100628145819.74d22d5f@dhcp-lab-109.englab.brq.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> I plan to add return EOPNOTSUPP to ethtool_op_set_flags().
I don't know what it will buy you.

Why don't you submit separate patch for below hunk, after your EOPNOTSUPP in ethtool_op_set_flags get accepted.

BTW, thanks of this fix.

-----Original Message-----
From: Stanislaw Gruszka [mailto:sgruszka@redhat.com] 
Sent: Monday, June 28, 2010 6:28 PM
To: Amit Salecha
Cc: netdev@vger.kernel.org; Amerigo Wang; Anirban Chakraborty
Subject: Re: [PATCH -next] qlcnic: fail when try to setup unsupported features

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
