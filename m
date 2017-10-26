From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net-next 1/3] liquidio: switchdev support for LiquidIO
 NIC
Date: Thu, 26 Oct 2017 15:00:56 -0700
Message-ID: <20171026150056.263e0a2e@cakuba.netronome.com>
References: <20171026053641.GA17861@felix-thinkpad.cavium.com>
        <20171026053727.GA17878@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        raghu.vatsavayi@cavium.com, derek.chickles@cavium.com,
        satananda.burla@cavium.com, vijaya.guvva@cavium.com
To: Felix Manlunas <felix.manlunas@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:56322 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932326AbdJZWBB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 18:01:01 -0400
Received: by mail-qk0-f193.google.com with SMTP id l194so6158627qke.13
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 15:01:00 -0700 (PDT)
In-Reply-To: <20171026053727.GA17878@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Oct 2017 22:37:27 -0700, Felix Manlunas wrote:
> +static int
> +lio_vf_rep_phys_port_name(struct net_device *dev,
> +			  char *buf, size_t len)
> +{
> +	struct lio_vf_rep_desc *vf_rep = netdev_priv(dev);
> +	struct octeon_device *oct = vf_rep->oct;
> +	int ret;
> +
> +	ret = snprintf(buf, len, "%d", vf_rep->ifidx - oct->pf_num * 64 - 1);
> +	if (ret >= len)
> +		return -EOPNOTSUPP;
> +
> +	return 0;
> +}

If you have multiple PFs please name the representors "pfXvfY".
