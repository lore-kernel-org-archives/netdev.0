From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH RFC 1/3] net: Add dev_set_env_hdr_len to accept envelope
 frames
Date: Tue, 27 Sep 2016 14:23:43 +0000
Message-ID: <BL2PR07MB2306030D4912AD8F574BAF9D8DCC0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <1474966541-4420-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Patrick McHardy <kaber@trash.net>,
        "Stephen Hemminger" <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0066.outbound.protection.outlook.com ([104.47.41.66]:30624
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933202AbcI0OjS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 27 Sep 2016 10:39:18 -0400
In-Reply-To: <1474966541-4420-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* return envelope header length */
> +static inline int netif_get_env_hdr_len(struct net_device *dev) {
> +	if (dev->netdev_ops->ndo_set_env_hdr_len)
> +		return dev->env_hdr_len;
> +
> +	if (netif_reduces_vlan_mtu(dev))
> +		return 0;
> +
> +	return 4; /* VLAN_HLEN */
> +}

Why claim that `4' is the default?
What's the benefit of propagating this value to userspace if
driver doesn't actually support it?

Assuming this *is* a good default [meaning your analysis indicated
basically every driver has at least so many octets reserved]
perhaps we should consider initializing the env_hdr_len in some
common function [e.g., in setup_ether() next to the mtu] to this value?
