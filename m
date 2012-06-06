From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [v3 net-next PATCH 1/3] Added kernel support in EEE Ethtool
 commands
Date: Wed, 6 Jun 2012 22:30:59 +0100
Message-ID: <1339018259.2836.58.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339009643-22951-1-git-send-email-yuvalmin@broadcom.com>
	 <1339009643-22951-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>, <peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56957 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752170Ab2FFVbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 17:31:04 -0400
In-Reply-To: <1339009643-22951-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-06 at 22:07 +0300, Yuval Mintz wrote:
> This patch extends the kernel's ethtool interface by adding support
> for 2 new EEE commands - get_eee and set_eee.
> 
> Thanks goes to Giuseppe Cavallaro for his original patch adding this support.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

but with one tiny change required:

[...]
> +static int ethtool_set_eee(struct net_device *dev, char __user *useraddr)
> +{
> +	struct ethtool_eee edata;
> +
> +	if (!dev->ethtool_ops->get_eee)

This must check set_eee, not get_eee.

Ben.

> +		return -EOPNOTSUPP;
> +
> +	if (copy_from_user(&edata, useraddr, sizeof(edata)))
> +		return -EFAULT;
> +
> +	return dev->ethtool_ops->set_eee(dev, &edata);
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
