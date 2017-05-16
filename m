From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH v3] bridge: netlink: check vlan_default_pvid range
Date: Tue, 16 May 2017 19:23:07 +0300
Message-ID: <520dba6c-70c3-f2a4-d5e5-67253ecf5a29@cumulusnetworks.com>
References: <20170516084840.21432-1-tobias.jungel@bisdn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Tobias Jungel <tobias.jungel@bisdn.de>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36231 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdEPQXF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:23:05 -0400
Received: by mail-wm0-f53.google.com with SMTP id u65so127680048wmu.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 09:23:05 -0700 (PDT)
In-Reply-To: <20170516084840.21432-1-tobias.jungel@bisdn.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/17 11:48 AM, Tobias Jungel wrote:
> Currently it is allowed to set the default pvid of a bridge to a value
> above VLAN_VID_MASK (0xfff). This patch adds a check to br_validate and
> returns -EINVAL in case the pvid is out of bounds.
> 
> Reproduce by calling:
> 
> [root@test ~]# ip l a type bridge
> [root@test ~]# ip l a type dummy
> [root@test ~]# ip l s bridge0 type bridge vlan_filtering 1
> [root@test ~]# ip l s bridge0 type bridge vlan_default_pvid 9999
> [root@test ~]# ip l s dummy0 master bridge0
> [root@test ~]# bridge vlan
> port	vlan ids
> bridge0	 9999 PVID Egress Untagged
> 
> dummy0	 9999 PVID Egress Untagged
> 
> Fixes: 0f963b7592ef ("bridge: netlink: add support for default_pvid")
> Signed-off-by: Tobias Jungel <tobias.jungel@bisdn.de>
> ---
>   net/bridge/br_netlink.c | 6 ++++++
>   1 file changed, 6 insertions(+)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index c5ce774..47cb95b 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -835,6 +835,12 @@ static int br_validate(struct nlattr *tb[], struct nlattr *data[])
>   			return -EPROTONOSUPPORT;
>   		}
>   	}
> +
> +	if (data[IFLA_BR_VLAN_DEFAULT_PVID]) {
> +		__u16 defpvid = nla_get_u16(data[IFLA_BR_VLAN_DEFAULT_PVID]);

Please leave a blank line between the variable definition and the rest.

> +		if (defpvid >= VLAN_VID_MASK)
> +			return -EINVAL;
> +	}
>   #endif
>   
>   	return 0;
> 

This version looks good to me, with the above stylistic issue fixed feel
free to add my:

Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Thanks!
