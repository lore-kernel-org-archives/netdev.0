From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] vxlan: Use RCU apis to access sk_user_data.
Date: Tue, 24 Sep 2013 09:16:06 -0700
Message-ID: <1380039366.3165.92.camel@edumazet-glaptop>
References: <1380038979-24035-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:56650 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096Ab3IXQQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:16:09 -0400
Received: by mail-pd0-f173.google.com with SMTP id p10so4802067pdj.32
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:16:08 -0700 (PDT)
In-Reply-To: <1380038979-24035-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 09:09 -0700, Pravin B Shelar wrote:
> Use of RCU api makes vxlan code easier to understand.  It also
> fixes bug due to missing ACCESS_ONCE() on sk_user_data dereference.
> In rare case without ACCESS_ONCE() compiler might omit vs on
> sk_user_data dereference. Compiler can use vs as alias for
> sk->sk_user_data, resulting in multiple sk_user_data dereference
> in rcu read context which could change.
> 
> CC: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> v2:
> Use RCU_INIT_POINTER
> ---
>  drivers/net/vxlan.c |   11 ++++-------
>  include/net/sock.h  |    2 ++
>  2 files changed, 6 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index d1292fe..1fae0d6 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1,4 +1,4 @@
> -/*
> + /*
>   * VXLAN: Virtual eXtensible Local Area Network
>   *


extra space ?
