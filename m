From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] rtnetlink: NUL-terminate IFLA_PHYS_PORT_NAME string
Date: Thu, 4 May 2017 10:14:13 -0600
Message-ID: <1df4c5ca-9f8d-3cba-52d0-2efbd4117a69@gmail.com>
References: <20170504144858.1905-1-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Thomas Haller <thaller@redhat.com>
To: Michal Schmidt <mschmidt@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33334 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754489AbdEDQOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 12:14:16 -0400
Received: by mail-pg0-f66.google.com with SMTP id s62so2890569pgc.0
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 09:14:16 -0700 (PDT)
In-Reply-To: <20170504144858.1905-1-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/4/17 8:48 AM, Michal Schmidt wrote:
> IFLA_PHYS_PORT_NAME is a string attribute, so terminate it with \0.
> Otherwise libnl3 fails to validate netlink messages with this attribute.
> "ip -detail a" assumes too that the attribute is NUL-terminated when
> printing it. It often was, due to padding.
> 
> I noticed this as libvirtd failing to start on a system with sfc driver
> after upgrading it to Linux 4.11, i.e. when sfc added support for
> phys_port_name.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  net/core/rtnetlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index c4e84c5582..69daf393cb 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1056,7 +1056,7 @@ static int rtnl_phys_port_name_fill(struct sk_buff *skb, struct net_device *dev)
>  		return err;
>  	}
>  
> -	if (nla_put(skb, IFLA_PHYS_PORT_NAME, strlen(name), name))
> +	if (nla_put_string(skb, IFLA_PHYS_PORT_NAME, name))
>  		return -EMSGSIZE;
>  
>  	return 0;
> 

Thanks for fixing.
