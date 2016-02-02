From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [RFC PATCH 3/7] net: sched: add cls_u32 offload hooks for netdevs
Date: Tue, 2 Feb 2016 18:25:49 +0200
Message-ID: <CAJ3xEMjRRUgHo_J4yQr3Z9wSJA7aRAzHc1ZNoBVP5WRmDFTRjw@mail.gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810>
	<20160201015023.13871.69865.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>, ast@fb.com,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	horms@verge.net.au, Linux Netdev List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jiri@mellanox.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36749 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbcBBQZu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 11:25:50 -0500
Received: by mail-io0-f182.google.com with SMTP id g73so22960066ioe.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 08:25:49 -0800 (PST)
In-Reply-To: <20160201015023.13871.69865.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 1, 2016 at 3:50 AM, John Fastabend <john.fastabend@gmail.com> wrote:
> This patch allows netdev drivers to consume cls_u32 offloads via
> the ndo_setup_tc ndo op.
>
> This works aligns with how network drivers have been doing qdisc
> offloads for mqprio.

[...]

> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -779,17 +779,21 @@ static inline bool netdev_phys_item_id_same(struct netdev_phys_item_id *a,
>  typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>                                        struct sk_buff *skb);
>
> -/* This structure holds attributes of qdisc and classifiers
> +/* These structures hold the attributes of qdisc and classifiers
>   * that are being passed to the netdevice through the setup_tc op.
>   */
>  enum {
>         TC_SETUP_MQPRIO,
> +       TC_SETUP_CLSU32,
>  };
>
> +struct tc_cls_u32_offload;
> +
>  struct tc_to_netdev {
>         unsigned int type;
>         union {
>                 u8 tc;
> +               struct tc_cls_u32_offload *cls_u32;
>         };
>  };

So under this approach we're making the HW driver u32 aware. Do we
really want to go there?

The flow-dissector + actions structure way of describing matching and
actions maybe had some
drawbacks but it's not affiliated with a specific networking component
(here TC/U32). When we look
fwd do we expect everything (netfilter offloads for example) to be
expressed in u32 terms?

Or.
