From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Mon, 23 Nov 2015 21:41:25 -0800
Message-ID: <5653F885.10804@gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
 <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse@kernel.org, Kiran Patil <kiran.patil@intel.com>
To: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34268 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbbKXFl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 00:41:29 -0500
Received: by padhx2 with SMTP id hx2so10220448pad.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 21:41:28 -0800 (PST)
In-Reply-To: <1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2015 01:02 PM, Anjali Singhai Jain wrote:
> Replace add/del ndo ops for vxlan_port with tunnel_port so that all UDP
> based tunnels can use the same ndo op. Add a parameter to pass tunnel
> type to the ndo_op.
>
> Change all drivers to use the generalized udp tunnel offload
>
> Patch was compile tested with x86_64_defconfig.
>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
> ---

[...]

> diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
> index cb2f89f..72415aa 100644
> --- a/include/net/udp_tunnel.h
> +++ b/include/net/udp_tunnel.h
> @@ -9,6 +9,12 @@
>   #include <net/addrconf.h>
>   #endif
>
> +enum udp_tunnel_type {
> +	UDP_TUNNEL_UNSPEC,
> +	UDP_TUNNEL_VXLAN,
> +	UDP_TUNNEL_GENEVE,
> +};
> +
>   struct udp_port_cfg {
>   	u8			family;
>
>

I'm not a fan of UDP_TUNNEL_UNSPEC.  If you are going to implement a 
"tunnel type" field it should specify tunnel type 1:1, not just 
generically refer to UNSPEC for everything that isn't VXLAN or GENEVE. 
This way we can avoid any issues with anyone implementing an offload 
that later relies on their tunnel type value being equal to 0.

- Alex
