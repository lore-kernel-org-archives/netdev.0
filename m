From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net] net: fix double free issue of skbuff
Date: Mon, 29 Feb 2016 15:58:21 +0300
Message-ID: <56D4406D.5060303@cogentembedded.com>
References: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Zhang Shengju <zhangshengju@cmss.chinamobile.com>,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36823 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcB2M6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 07:58:33 -0500
Received: by mail-lb0-f180.google.com with SMTP id x1so79241655lbj.3
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 04:58:32 -0800 (PST)
In-Reply-To: <1456748573-21586-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 2/29/2016 3:22 PM, Zhang Shengju wrote:

> If skb_reorder_vlan_header() failed, skb is freed and NULL is returned.
> Then at skb_vlan_untag(), it will free skbuff again which cause double
> free.
>
> This patch removes kfree_skb() call in function skb_reorder_vlan_header().
>
> Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> ---
>   net/core/skbuff.c | 1 -
>   1 file changed, 1 deletion(-)
>
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 488566b..1312d4b 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -4350,7 +4350,6 @@ EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
>   static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
>   {
>   	if (skb_cow(skb, skb_headroom(skb)) < 0) {
> -		kfree_skb(skb);
>   		return NULL;
>   	}

    You now need to remove {}.

MBR, Sergei
