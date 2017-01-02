From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 02/12] Common functions and definitions
Date: Mon, 2 Jan 2017 12:00:31 -0800
Message-ID: <20170102120031.32785d94@xeon-e3>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
        <67f8be9c3f6a4fede2eefaa4a3c45f9dbaf9b411.1482844668.git.vomlehn@texas.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35273 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933445AbdABUAk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 15:00:40 -0500
Received: by mail-pg0-f49.google.com with SMTP id i5so141697462pgh.2
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 12:00:39 -0800 (PST)
In-Reply-To: <67f8be9c3f6a4fede2eefaa4a3c45f9dbaf9b411.1482844668.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> +#define AQ_OBJ_SET(_OBJ_, _F_) \
> +{ unsigned long flags_old, flags_new; atomic_t *flags = &(_OBJ_)->flags; \
> +do { \
> +	flags_old = atomic_read(flags); \
> +	flags_new = flags_old | (_F_); \
> +} while (atomic_cmpxchg(flags, \
> +	flags_old, flags_new) != flags_old); }
> +
> +#define AQ_OBJ_CLR(_OBJ_, _F_) \
> +{ unsigned long flags_old, flags_new; atomic_t *flags = &(_OBJ_)->flags; \
> +do { \
> +	flags_old = atomic_read(flags); \
> +	flags_new = flags_old & ~(_F_); \
> +} while (atomic_cmpxchg(flags, \
> +	flags_old, flags_new) != flags_old); }
> +

These are way to complex to be macros. Can't the same logic be done
as inline functions.
