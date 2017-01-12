From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH] tc: m_xt: Fix segfault with iptables-1.6.0
Date: Thu, 12 Jan 2017 11:34:49 -0800
Message-ID: <20170112113449.581e2219@xeon-e3>
References: <20170112142249.13041-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:34473 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdALUgB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 15:36:01 -0500
Received: by mail-pf0-f171.google.com with SMTP id 127so18178639pfg.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 12:36:01 -0800 (PST)
In-Reply-To: <20170112142249.13041-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jan 2017 15:22:49 +0100
Phil Sutter <phil@nwl.cc> wrote:

> Said iptables version introduced struct xtables_globals field
> 'compat_rev', a function pointer. Initializing it is mandatory as
> libxtables calls it without existence check.
> 
> Without this, tc segfaults when using the xt action like so:
> 
> | tc filter add dev d0 parent ffff: u32 match u32 0 0 \
> |	action xt -j MARK --set-mark 20
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  tc/m_xt.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/tc/m_xt.c b/tc/m_xt.c
> index dbb54981462ee..57ed40d7aa3a8 100644
> --- a/tc/m_xt.c
> +++ b/tc/m_xt.c
> @@ -77,6 +77,9 @@ static struct xtables_globals tcipt_globals = {
>  	.orig_opts = original_opts,
>  	.opts = original_opts,
>  	.exit_err = NULL,
> +#if (XTABLES_VERSION_CODE >= 11)
> +	.compat_rev = xtables_compatible_revision,
> +#endif
>  };
>  
>  /*

Ah the xtables API is not really an application friendly API by
any stretch of the imagination

Parenthesis not really necessary there.
