From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCHv2] af_llc: fix types on llc_ui_wait_for_conn
Date: Tue, 16 Feb 2016 12:04:15 +0900
Message-ID: <20160216030412.GA18469@vergenet.net>
References: <20160215194129.18888.95792.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Alan <gnomes@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35221 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572AbcBPDEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 22:04:30 -0500
Received: by mail-pa0-f42.google.com with SMTP id ho8so96217881pac.2
        for <netdev@vger.kernel.org>; Mon, 15 Feb 2016 19:04:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160215194129.18888.95792.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2016 at 07:41:51PM +0000, Alan wrote:
> The timeout is a long, we return it truncated if it is huge. Basically
> harmless as the only caller does a boolean check, but tidy it up anyway.

If the only caller performs a boolean check then perhaps
it would be best if the function's return type was bool.

> (64bit build tested this time. Thank you 0day)
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>
> ---
>  net/llc/af_llc.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
> index 8dab4e5..b3c52e3 100644
> --- a/net/llc/af_llc.c
> +++ b/net/llc/af_llc.c
> @@ -38,7 +38,7 @@ static u16 llc_ui_sap_link_no_max[256];
>  static struct sockaddr_llc llc_ui_addrnull;
>  static const struct proto_ops llc_ui_ops;
>  
> -static int llc_ui_wait_for_conn(struct sock *sk, long timeout);
> +static long llc_ui_wait_for_conn(struct sock *sk, long timeout);
>  static int llc_ui_wait_for_disc(struct sock *sk, long timeout);
>  static int llc_ui_wait_for_busy_core(struct sock *sk, long timeout);
>  
> @@ -551,7 +551,7 @@ static int llc_ui_wait_for_disc(struct sock *sk, long timeout)
>  	return rc;
>  }
>  
> -static int llc_ui_wait_for_conn(struct sock *sk, long timeout)
> +static long llc_ui_wait_for_conn(struct sock *sk, long timeout)
>  {
>  	DEFINE_WAIT(wait);
>  
> 
