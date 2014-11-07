From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 05/10] rocker: introduce rocker switch driver
Date: Fri, 07 Nov 2014 15:08:25 -0500 (EST)
Message-ID: <20141107.150825.1684787513959523136.davem@davemloft.net>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	<1415265610-9338-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbaKGUIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2014 15:08:34 -0500
In-Reply-To: <1415265610-9338-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  6 Nov 2014 10:20:05 +0100

> +#include <generated/utsrelease.h>

The version of this driver is not the version of the kernel, please do not
pretend that it is.

Define a proper DRV_MODULE_VERSION and MODULE_VERSION() like other drivers
do rather than using UTS_RELEASE or whatever.

> +static u32 rocker_msix_vector(struct rocker *rocker, unsigned vector)

Please do not use plain "unsigned", always say "unsigned int".

> +#ifdef CONFIG_NET_SWITCHDEV
> +	.ndo_sw_parent_id_get		= rocker_port_sw_parent_id_get,
> +#endif

Maybe better to just make the driver depend upon NET_SWITCHDEV?

> +struct rocker_desc {
> +	u64 buf_addr;
> +	u64 cookie;
> +	u16 buf_size;
> +	u16 tlv_size;
> +	u16 resv[5];
> +	u16 comp_err;
> +} __packed __aligned(8);

This __packed seems unnecessary, and __packed should always be avoided
when possible because it generates terrible code on some cpus.

> +/* Rocker DMA TLV struct */
> +struct rocker_tlv {
> +	u32 type;
> +	u16 len;
> +} __packed __aligned(8);

Likewise.
