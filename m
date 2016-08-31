From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next V4 3/4] net/sched: cls_flower: Classify packet
 in ip tunnels
Date: Wed, 31 Aug 2016 17:12:38 +0200
Message-ID: <20160831151238.GC1986@nanopsycho>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
 <1472647584-6713-4-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36024 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933835AbcHaPMl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 11:12:41 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so8055777wmf.3
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 08:12:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1472647584-6713-4-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Aug 31, 2016 at 02:46:23PM CEST, hadarh@mellanox.com wrote:
>From: Amir Vadai <amir@vadai.me>
>
>Introduce classifying by metadata extracted by the tunnel device.
>Outer header fields - source/dest ip and tunnel id, are extracted from
>the metadata when classifying.
>
>For example, the following will add a filter on the ingress Qdisc of shared
>vxlan device named 'vxlan0'. To forward packets with outer src ip
>11.11.0.2, dst ip 11.11.0.1 and tunnel id 11. The packets will be
>forwarded to tap device 'vnet0' (after metadata is released):
>
>$ filter add dev vxlan0 protocol ip parent ffff: \
>    flower \
>      enc_src_ip 11.11.0.2 \
>      enc_dst_ip 11.11.0.1 \
>      enc_key_id 11 \
>      dst_ip 11.11.11.1 \
>    action tunnel_key release \
>    action mirred egress redirect dev vnet0
>
>The action tunnel_key, will be introduced in the next patch in this
>series.
>
>Signed-off-by: Amir Vadai <amir@vadai.me>
>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>---
> include/uapi/linux/pkt_cls.h |  11 +++++
> net/sched/cls_flower.c       | 101 ++++++++++++++++++++++++++++++++++++++++++-
> 2 files changed, 110 insertions(+), 2 deletions(-)
>

<snip>	
	
>@@ -345,7 +382,6 @@ static int fl_set_key(struct net *net, struct nlattr **tb,
> 		mask->indev_ifindex = 0xffffffff;
> 	}
> #endif
>-
> 	fl_set_key_val(tb, key->eth.dst, TCA_FLOWER_KEY_ETH_DST,
> 		       mask->eth.dst, TCA_FLOWER_KEY_ETH_DST_MASK,
> 		       sizeof(key->eth.dst));


Please remove this hunk. Other than that,

Acked-by: Jiri Pirko <jiri@mellanox.com>
