From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fib_rules: add route suppression based on ifgroup
Date: Thu, 01 Aug 2013 09:06:34 -0700
Message-ID: <1375373194.10515.158.camel@edumazet-glaptop>
References: <20130801151809.GB21970@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:51967 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470Ab3HAQGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 12:06:39 -0400
Received: by mail-pb0-f44.google.com with SMTP id xa7so2253640pbc.3
        for <netdev@vger.kernel.org>; Thu, 01 Aug 2013 09:06:38 -0700 (PDT)
In-Reply-To: <20130801151809.GB21970@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 17:18 +0200, Stefan Tomanek wrote:
> This change adds the ability to suppress a routing decision based upon the
> interface group the selected interface belongs to.
> 
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
> ---
>  include/net/fib_rules.h        |    2 ++
>  include/uapi/linux/fib_rules.h |    2 +-
>  net/core/fib_rules.c           |   10 ++++++++++
>  net/ipv4/fib_rules.c           |   23 +++++++++++++++++------
>  net/ipv6/fib6_rules.c          |   16 +++++++++++++---
>  5 files changed, 43 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/fib_rules.h b/include/net/fib_rules.h
> index 2f286dc..4d32ecc 100644
> --- a/include/net/fib_rules.h
> +++ b/include/net/fib_rules.h
> @@ -19,6 +19,7 @@ struct fib_rule {
>  	u32			flags;
>  	u32			table;
>  	u8			table_prefixlen_min;
> +	int			suppress_ifgroup;
>  	u8			action;
>  	u32			target;
>  	struct fib_rule __rcu	*ctarget;

Why adding holes in this structure ?
