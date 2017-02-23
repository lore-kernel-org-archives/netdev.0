From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] vxlan: correctly validate VXLAN ID against
 VXLAN_VID_MASK
Date: Thu, 23 Feb 2017 16:34:37 +0100
Message-ID: <20170223163437.6f2a29cb@griffin>
References: <3ea499d5a3564fc7074665962b1a10cccd900e59.1487854674.git.mschiffer@universe-factory.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Matthias Schiffer <mschiffer@universe-factory.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55810 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751049AbdBWPel (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 10:34:41 -0500
In-Reply-To: <3ea499d5a3564fc7074665962b1a10cccd900e59.1487854674.git.mschiffer@universe-factory.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Feb 2017 13:59:02 +0100, Matthias Schiffer wrote:
> The incorrect check caused an off-by-one error: the maximum VID 0xffffff
> was unusable.
> 
> Fixes: d342894c5d2f ("vxlan: virtual extensible lan")
> Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
> ---
>  drivers/net/vxlan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 556953f53437..f89428fb7389 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2675,7 +2675,7 @@ static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
>  
>  	if (data[IFLA_VXLAN_ID]) {
>  		__u32 id = nla_get_u32(data[IFLA_VXLAN_ID]);
> -		if (id >= VXLAN_VID_MASK)
> +		if (id & ~VXLAN_VID_MASK)
>  			return -ERANGE;
>  	}
>  

"if (id >= VXLAN_N_VID)" would be cleaner and the meaning more obvious.

Thanks,

 Jiri
