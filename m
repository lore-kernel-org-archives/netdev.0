From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next v2 3/7] ipv4: ipmr: Don't forward packets already
 forwarded by hardware
Date: Tue, 3 Oct 2017 13:26:35 +0300
Message-ID: <067cd4b7-791f-fe7a-7131-d90dd2362b00@cumulusnetworks.com>
References: <20171003075812.1540-1-jiri@resnulli.us>
 <20171003075812.1540-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, andrew@lunn.ch, dsa@cumulusnetworks.com,
        edumazet@google.com, willemb@google.com, johannes.berg@intel.com,
        dcaratti@redhat.com, pabeni@redhat.com, daniel@iogearbox.net,
        f.fainelli@gmail.com, fw@strlen.de, gfree.wind@vip.163.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:52779 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdJCK0i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 06:26:38 -0400
Received: by mail-wm0-f54.google.com with SMTP id k4so13679187wmc.1
        for <netdev@vger.kernel.org>; Tue, 03 Oct 2017 03:26:38 -0700 (PDT)
In-Reply-To: <20171003075812.1540-4-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/17 10:58, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Change the ipmr module to not forward packets if:
>  - The packet is marked with the offload_mr_fwd_mark, and
>  - Both input interface and output interface share the same parent ID.
> 
> This way, a packet can go through partial multicast forwarding in the
> hardware, where it will be forwarded only to the devices that share the
> same parent ID (AKA, reside inside the same hardware). The kernel will
> forward the packet to all other interfaces.
> 
> To do this, add the ipmr_offload_forward helper, which per skb, ingress VIF
> and egress VIF, returns whether the forwarding was offloaded to hardware.
> The ipmr_queue_xmit frees the skb and does not forward it if the result is
> a true value.
> 
> All the forwarding path code compiles out when the CONFIG_NET_SWITCHDEV is
> not set.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - Use dev_parent_id.len field instead of the dev_parent_id_valid field
> ---
>  net/ipv4/ipmr.c | 37 ++++++++++++++++++++++++++++++++-----
>  1 file changed, 32 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 1b161ad..b3ee01b 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -1859,10 +1859,33 @@ static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
>  	return dst_output(net, sk, skb);
>  }
>  

Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
