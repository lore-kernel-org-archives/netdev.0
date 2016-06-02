From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix an infoleak in tipc_nl_compat_link_dump
Date: Wed, 01 Jun 2016 23:32:16 -0700 (PDT)
Message-ID: <20160601.233216.1293792015714271361.davem@davemloft.net>
References: <1464798895-26870-1-git-send-email-kjlu@gatech.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	taesoo@gatech.edu, csong84@gatech.edu, kjlu@gatech.edu
To: kangjielu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464798895-26870-1-git-send-email-kjlu@gatech.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kangjie Lu <kangjielu@gmail.com>
Date: Wed,  1 Jun 2016 12:34:55 -0400

> diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
> index f795b1d..115aafa 100644
> --- a/net/tipc/netlink_compat.c
> +++ b/net/tipc/netlink_compat.c
> @@ -604,6 +604,7 @@ static int tipc_nl_compat_link_dump(struct tipc_nl_compat_msg *msg,
>  
>  	link_info.dest = nla_get_flag(link[TIPC_NLA_LINK_DEST]);
>  	link_info.up = htonl(nla_get_flag(link[TIPC_NLA_LINK_UP]));
> +	memset((void *)link_info.str, 0, TIPC_MAX_LINK_NAME);
>  	strcpy(link_info.str, nla_data(link[TIPC_NLA_LINK_NAME]));
>  

Please instead use "nla_strlcpy()".

Thanks.
