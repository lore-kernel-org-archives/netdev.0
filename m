From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2 1/2] if_link: add client name to port
 profile
Date: Sat, 4 Oct 2014 20:05:23 -0700
Message-ID: <20141004200523.4fc102e3@urahara>
References: <1412289683-8278-1-git-send-email-_govind@gmx.com>
	<1412289683-8278-2-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:58042 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbaJEDFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 23:05:36 -0400
Received: by mail-pd0-f171.google.com with SMTP id ft15so1522349pdb.30
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2014 20:05:35 -0700 (PDT)
In-Reply-To: <1412289683-8278-2-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  3 Oct 2014 04:11:22 +0530
Govindarajulu Varadarajan <_govind@gmx.com> wrote:

> This patch adds client name to port profile.
> 
> This is used by netlink client to send the client name in port profile.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  include/uapi/linux/if_link.h | 1 +
>  net/core/rtnetlink.c         | 2 ++
>  2 files changed, 3 insertions(+)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 0bdb77e..6ae0b0b 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -512,6 +512,7 @@ enum {
>  	IFLA_PORT_HOST_UUID,		/* binary UUID */
>  	IFLA_PORT_REQUEST,		/* __u8 */
>  	IFLA_PORT_RESPONSE,		/* __u16, output only */
> +	IFLA_PORT_VMNAME,		/* vm-name used by port profile */
>  	__IFLA_PORT_MAX,
>  };
>  
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index a688268..116d647 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1238,6 +1238,8 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
>  				    .len = PORT_UUID_MAX },
>  	[IFLA_PORT_REQUEST]	= { .type = NLA_U8, },
>  	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
> +	[IFLA_PORT_VMNAME]	= { .type = NLA_STRING,
> +				    .len = PORT_PROFILE_MAX },
>  };
>  
>  static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)

Maybe you could use the existing IFLA_IFALIAS?
It is already supported by iproute tools and sysfs, and can be used by net-snmp as well.
You would just be setting the default string, users could change it.
