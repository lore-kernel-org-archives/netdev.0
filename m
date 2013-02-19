From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/3] net: dev: fix build failed when procfs is disabled
Date: Tue, 19 Feb 2013 20:02:51 +0800
Message-ID: <512369EB.7090209@gmail.com>
References: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com> <1361270592-19492-2-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33613 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659Ab3BSMC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 07:02:58 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so3371658pad.24
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 04:02:57 -0800 (PST)
In-Reply-To: <1361270592-19492-2-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 06:43 PM, Gao feng wrote:
> commit 900ff8c6321418dafa03c22e215cb9646a2541b9
> "net: move procfs code to net/core/net-procfs.c"
> missed define dev_mcast_init when CONFIG_PROC
> isn't configured.
>
> Cc: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>   include/linux/netdevice.h | 2 ++
>   1 file changed, 2 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f111b4f..91f6c7b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2693,8 +2693,10 @@ extern void		net_disable_timestamp(void);
>
>   #ifdef CONFIG_PROC_FS
>   extern int __init dev_proc_init(void);
> +extern void __init dev_mcast_init(void);
>   #else
>   #define dev_proc_init() 0
> +#define dev_mcast_init() {}
>   #endif
>
>   extern int netdev_class_create_file(struct class_attribute *class_attr);
>

Thanks for catching this!

I forgot to test !CONFIG_PROC_FS case again after grabbing the mcast piece.

I have a better fix, which moves dev_mcast_init() to dev_proc_init(), 
will post it right now.
