From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] filter: Optimize instruction revalidation code.
Date: Tue, 16 Nov 2010 16:11:43 +0300
Message-ID: <4CE2830F.5060907@msgid.tls.msk.ru>
References: <1695276347-1289413089-cardhu_decombobulator_blackberry.rim.net-434693855-@bda083.bisx.prod.on.blackberry>	<20101110.102129.112602843.davem@davemloft.net>	<1289414024.2469.20.camel@edumazet-laptop>	<20101110.103807.39173013.davem@davemloft.net> <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	drosenberg@vsecurity.com, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:56305 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934459Ab0KPNLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Nov 2010 08:11:45 -0500
In-Reply-To: <201011162208.BHC17628.SVtFMJOOLFQFOH@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

16.11.2010 16:08, Tetsuo Handa wrote:
[]
>  net/core/filter.c |  214 ++++++++++++++++-------------------------------------
>  1 files changed, 65 insertions(+), 149 deletions(-)
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 23e9b2a..85be3d8 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -383,7 +383,57 @@ EXPORT_SYMBOL(sk_run_filter);
>   */
>  int sk_chk_filter(struct sock_filter *filter, int flen)
>  {
> -	struct sock_filter *ftest;
> +	/*
> +	 * Valid instructions are initialized to non-0.
> +	 * Invalid instructions are initialized to 0.
> +	 */
> +	static u16 codes[] = {
> +		[BPF_ALU|BPF_ADD|BPF_K]  = BPF_S_ALU_ADD_K + 1,

How about using some "const" there?  :)

/mjt
