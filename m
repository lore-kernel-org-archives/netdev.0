From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 07/10] bridge: call netdev_sw_port_stp_update
 when bridge port STP status changes
Date: Thu, 06 Nov 2014 08:59:27 -0800
Message-ID: <545BA8EF.4060601@gmail.com>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us> <1415265610-9338-8-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:40849 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbaKFRAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 12:00:04 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so1608468pab.27
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 09:00:03 -0800 (PST)
In-Reply-To: <1415265610-9338-8-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/06/2014 01:20 AM, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> To notify switch driver of change in STP state of bridge port, add new
> .ndo op and provide swdev wrapper func to call ndo op. Use it in bridge
> code then.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

[snip]

>  #endif /* _LINUX_SWITCHDEV_H_ */
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 86c239b..13fecf1 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -17,6 +17,7 @@
>  #include <net/net_namespace.h>
>  #include <net/sock.h>
>  #include <uapi/linux/if_bridge.h>
> +#include <net/switchdev.h>
>  
>  #include "br_private.h"
>  #include "br_private_stp.h"
> @@ -304,6 +305,7 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
>  
>  	br_set_state(p, state);
>  	br_log_state(p);
> +	netdev_sw_port_stp_update(p->dev, p->state);

Is there a reason netdev_sw_port_stp_update() is not folded in
br_set_state()? Are we missing calls to br_set_state() in some locations?
--
Florian
