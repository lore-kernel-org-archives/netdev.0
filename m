From: =?ISO-8859-1?Q?Geyslan_Greg=F3rio_Bem?= <geyslan@gmail.com>
Subject: Re: [PATCH] net/hsr: Fix possible leak in 'hsr_get_node_status()'
Date: Thu, 14 Nov 2013 18:29:02 -0200
Message-ID: <CAGG-pUSYRXFyKW_nocM8eitrbdt4YfyMfMq4hN5472bdPUZ7fQ@mail.gmail.com>
References: <1384456378-29970-1-git-send-email-geyslan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Arvid Brodin <arvid.brodin@xdin.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: =?ISO-8859-1?Q?Geyslan_Greg=F3rio_Bem?= <geyslan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:42634 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756980Ab3KNU3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 15:29:03 -0500
In-Reply-To: <1384456378-29970-1-git-send-email-geyslan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/11/14 Geyslan G. Bem <geyslan@gmail.com>:
> If 'hsr_get_node_data()' returns error, going directly to 'fail' label
> doesn't free the memory pointed by 'skb_out'.
>
> Signed-off-by: Geyslan G. Bem <geyslan@gmail.com>
> ---
>  net/hsr/hsr_netlink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
> index 4e66bf6..aef8429 100644
> --- a/net/hsr/hsr_netlink.c
> +++ b/net/hsr/hsr_netlink.c
> @@ -249,7 +249,7 @@ static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_info *info)
>                         &hsr_node_if2_age,
>                         &hsr_node_if2_seq);
>         if (res < 0)
> -               goto fail;
> +               goto nla_put_failure;
>
>         res = nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN,
>                                         nla_data(info->attrs[HSR_A_NODE_ADDR]));
> --
> 1.8.4.2
>

It's a Coverity catch: CID 1128855.

-- 
Regards,

Geyslan G. Bem
hackingbits.com
