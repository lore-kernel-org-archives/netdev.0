From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 6/6] doc: update switchdev L3 section
Date: Thu, 22 Sep 2016 10:31:10 +0300
Message-ID: <20160922073110.GC13287@splinter>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
 <1474458794-5512-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, linville@tuxdriver.com,
        andy@greyhouse.net, f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        jhs@mojatatu.com, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, ivecera@redhat.com, kaber@trash.net,
        john@phrozen.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36378 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750968AbcIVHbN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 03:31:13 -0400
Content-Disposition: inline
In-Reply-To: <1474458794-5512-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 01:53:14PM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> This is to reflect the change of FIB offload infrastructure from
> switchdev objects to FIB notifier.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  Documentation/networking/switchdev.txt | 27 ++++++++++++++-------------
>  1 file changed, 14 insertions(+), 13 deletions(-)
> 
> diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
> index 44235e8..c956ab8 100644
> --- a/Documentation/networking/switchdev.txt
> +++ b/Documentation/networking/switchdev.txt
> @@ -314,30 +314,29 @@ the kernel, with the device doing the FIB lookup and forwarding.  The device
>  does a longest prefix match (LPM) on FIB entries matching route prefix and
>  forwards the packet to the matching FIB entry's nexthop(s) egress ports.
>  
> -To program the device, the driver implements support for
> -SWITCHDEV_OBJ_IPV[4|6]_FIB object using switchdev_port_obj_xxx ops.
> -switchdev_port_obj_add is used for both adding a new FIB entry to the device,
> -or modifying an existing entry on the device.
> +To program the device, the driver has to register a FIB notifier handler
> +using register_fib_notifier. There are following events available:

"The following events are available:" maybe?

> +FIB_EVENT_ENTRY_ADD: used for both adding a new FIB entry to the device,
> +                     or modifying an existing entry on the device.
> +FIB_EVENT_ENTRY_DEL: used for removing a FIB entry
> +FIB_EVENT_RULE_ADD, FIB_EVENT_RULE_DEL: used to propagate FIB rule changes
>  
> -XXX: Currently, only SWITCHDEV_OBJ_ID_IPV4_FIB objects are supported.
> +FIB_EVENT_ENTRY_ADD and FIB_EVENT_ENTRY_DEL events pass:
>  
> -SWITCHDEV_OBJ_ID_IPV4_FIB object passes:
> -
> -	struct switchdev_obj_ipv4_fib {         /* IPV4_FIB */
> +	struct fib_entry_notifier_info {
> +		struct fib_notifier_info info; /* must be first */
>  		u32 dst;
>  		int dst_len;
>  		struct fib_info *fi;
>  		u8 tos;
>  		u8 type;
> -		u32 nlflags;
>  		u32 tb_id;
> -	} ipv4_fib;
> +		u32 nlflags;
> +	};
>  
>  to add/modify/delete IPv4 dst/dest_len prefix on table tb_id.  The *fi
>  structure holds details on the route and route's nexthops.  *dev is one of the
> -port netdevs mentioned in the routes next hop list.  If the output port netdevs
> -referenced in the route's nexthop list don't all have the same switch ID, the
> -driver is not called to add/modify/delete the FIB entry.
> +port netdevs mentioned in the routes next hop list.

s/routes/route's/ ?

Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks!

>  
>  Routes offloaded to the device are labeled with "offload" in the ip route
>  listing:
> @@ -355,6 +354,8 @@ listing:
>  	12.0.0.4 via 11.0.0.9 dev sw1p2  proto zebra  metric 20 offload
>  	192.168.0.0/24 dev eth0  proto kernel  scope link  src 192.168.0.15
>  
> +The "offload" flag is set in case at least one device offloads the FIB entry.
> +
>  XXX: add/mod/del IPv6 FIB API
>  
>  Nexthop Resolution
> -- 
> 2.5.5
> 
