From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/3] MIPS: lantiq: add ethernet driver
Date: Tue, 12 Apr 2011 16:54:24 -0700
Message-ID: <20110412165424.0b6ba71a@nehalam>
References: <1302624675-18652-1-git-send-email-blogic@openwrt.org>
	<1302624675-18652-3-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ralf Baechle <ralf@linux-mips.org>,
	Ralph Hempel <ralph.hempel@lantiq.com>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: John Crispin <blogic@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36906 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932095Ab1DLXy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Apr 2011 19:54:27 -0400
In-Reply-To: <1302624675-18652-3-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Apr 2011 18:11:14 +0200
John Crispin <blogic@openwrt.org> wrote:

> +
> +struct ltq_mii_priv {
> +	struct ltq_eth_data *pldata;
> +	struct resource *res;
> +	struct net_device_stats stats;

You don't need to have private stats structure it is part
of net_device in recent kernels. In fact, since you don't
set .ndo_get_stats, the driver is getting the default function
which prints the values from network_device, not your priv structure.

Also, please consider adding basic ethtool support to
show speed/duplex and driver information.

-- 
