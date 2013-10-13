From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Sun, 13 Oct 2013 13:46:01 -0700
Message-ID: <525B0689.4070109@gmail.com>
References: <1380140209-24587-1-git-send-email-nhorman@tuxdriver.com> <1381517037-26007-1-git-send-email-nhorman@tuxdriver.com> <1381517037-26007-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f47.google.com ([209.85.219.47]:49930 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755160Ab3JMUqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Oct 2013 16:46:22 -0400
Received: by mail-oa0-f47.google.com with SMTP id i1so3945115oag.20
        for <netdev@vger.kernel.org>; Sun, 13 Oct 2013 13:46:22 -0700 (PDT)
In-Reply-To: <1381517037-26007-2-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/2013 11:43 AM, Neil Horman wrote:
> Add a operations structure that allows a network interface to export the fact
> that it supports package forwarding in hardware between physical interfaces and
> other mac layer devices assigned to it (such as macvlans).  this operaions
> structure can be used by virtual mac devices to bypass software switching so
> that forwarding can be done in hardware more efficiently.
>
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: john.fastabend@gmail.com
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---

[...]

>
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 2ddb48d..1710fdb 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -426,9 +426,9 @@ struct sk_buff {
>   	char			cb[48] __aligned(8);
>
>   	unsigned long		_skb_refdst;
> -#ifdef CONFIG_XFRM
> +

Is this a hold-over from the previous patches? 'sp' isn't touched
anywhere else so put the ifdef/endif back.

>   	struct	sec_path	*sp;
> -#endif
> +
>   	unsigned int		len,
>   				data_len;
>   	__u16			mac_len,
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 5c713f2..ecad8c2 100644

-- 
John Fastabend         Intel Corporation
