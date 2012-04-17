From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/ipv4:Remove two memleak reports by
 kmemeleak_not_leak
Date: Tue, 17 Apr 2012 07:18:50 +0200
Message-ID: <1334639930.2472.4.camel@edumazet-glaptop>
References: <201204170941274843290@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: majianpeng <majianpeng@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35006 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265Ab2DQFSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 01:18:55 -0400
Received: by wibhj6 with SMTP id hj6so145144wib.1
        for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 22:18:54 -0700 (PDT)
In-Reply-To: <201204170941274843290@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-17 at 09:41 +0800, majianpeng wrote:
> From 582ed93b990e88110287ed0388bcb9057b1b8591 Mon Sep 17 00:00:00 2001
> From: majianpeng <majianpeng@gmail.com>
> Date: Tue, 17 Apr 2012 09:36:26 +0800
> Subject: [PATCH] net/ipv4:Remove two memleak reports by kmemeleak_not_leak.
> 
> 
> Signed-off-by: majianpeng <majianpeng@gmail.com>
> ---
>  net/ipv4/route.c |    8 ++++++--
>  1 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 167ea10..1984c82 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -3504,7 +3504,11 @@ int __init ip_rt_init(void)
>   * this nonsense will go away.
>   */
>  void __init ip_static_sysctl_init(void)
> -{
> -	register_sysctl_paths(ipv4_path, ipv4_skeleton);
> +{
> +	struct ctl_table_header *ctl_header;
> +
> +	ctl_header = register_sysctl_paths(ipv4_path, ipv4_skeleton);
> +	if (ctl_header)
> +		kmemleak_not_leak(ctl_header);
>  }
>  #endif

No need for this temp var and conditional.

Just :

	kmemleak_not_leak(register_sysctl_paths(ipv4_path, ipv4_skeleton));
