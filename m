From: "Levy, Lior" <lior.levy@intel.com>
Subject: RE: [net-next-2.6 2/3] igb: add support for VF Transmit rate limit
 using iproute2
Date: Mon, 7 Feb 2011 10:08:08 -0800
Message-ID: <D8C203CB45F96D458DCD5D3CA10C7FD7014F674E63@orsmsx506.amr.corp.intel.com>
References: <1296217779-30133-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296217779-30133-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <20110128.163817.193721063.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19042 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754531Ab1BGSIL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 13:08:11 -0500
In-Reply-To: <20110128.163817.193721063.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Dave for your input.

I agree that there isn't a very good reason to log these messages.
People can use the "ip show" command to query the TX rate limit for each vf.

BTW - this feature is being configured via iproute2 and not ethtool. But still the concept is the same.

We'll re-submit the patch soon.
 
Regards,
Lior.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of David Miller
Sent: Friday, January 28, 2011 4:38 PM
To: Kirsher, Jeffrey T
Cc: Levy, Lior; netdev@vger.kernel.org; gospo@redhat.com; bphilips@novell.com
Subject: Re: [net-next-2.6 2/3] igb: add support for VF Transmit rate limit using iproute2

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 28 Jan 2011 04:29:38 -0800

> +	if (tx_rate != 0)
> +		dev_info(&adapter->pdev->dev,
> +		         "Setting Transmit rate of %d Mbps for VF %d\n",
> +		         tx_rate, vf);
> +	else
> +		dev_info(&adapter->pdev->dev,
> +		         "Transmit rate limit for VF %d is disabled\n", vf);

If you're going to print this, use netdev_info(netdev, ...).

But I think you shouldn't be logging anything at all.

No other ethtool operation logs what it did except in extremely
exceptional error conditions.  And there is nothing special
about this VF rate limiting ethtool operation to justify these
extraneous logging messages.

If people want to know if the VF is rate limited, and by how much,
then can query the configuration using ethtool.
--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
