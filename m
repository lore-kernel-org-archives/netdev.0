From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 3/3] vxlan: virtual extensible lan
Date: Wed, 3 Oct 2012 18:54:46 -0700
Message-ID: <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
References: <20121001223232.566037595@vyatta.com> <20121001223254.349753999@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:46164 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753871Ab2JDBzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 21:55:08 -0400
Received: by mail-pb0-f46.google.com with SMTP id rr4so73358pbb.19
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2012 18:55:06 -0700 (PDT)
In-Reply-To: <20121001223254.349753999@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 1, 2012 at 3:32 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> --- /dev/null   1970-01-01 00:00:00.000000000 +0000
> +++ b/drivers/net/vxlan.c       2012-10-01 15:08:38.024499080 -0700
> +/* Transmit local packets over Vxlan
> + *
> + * Outer IP header inherits ECN and DF from inner header.
> + * Outer UDP destination is the VXLAN assigned port.
> + *           source port is based on hash of flow if available
> + *                       otherwise use a random value
> + */
> +static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
[...]
> +       hash = skb_get_rxhash(skb);
[...]
> +       uh->dest = htons(vxlan_port);
> +       uh->source = hash ? :random32();

I think this may lead to packet reordering in some cases.  If the
protocol is unknown then it may still represent part of a flow and
random source ports could lead to taking different paths.

Also, does it make sense to restrict the range of ports to, say, the
upper half of the range?
