From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute PATCH v3 2/7] xfrm_state: Make sure alg_name is
 NULL-terminated
Date: Mon, 21 Aug 2017 17:28:20 -0700
Message-ID: <20170821172541.6eb3e60c@xeon-e3>
References: <20170821132341.23118-1-phil@nwl.cc>
        <20170821132341.23118-3-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:38119 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754015AbdHVA21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 20:28:27 -0400
Received: by mail-pg0-f45.google.com with SMTP id m133so26460084pga.5
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 17:28:27 -0700 (PDT)
In-Reply-To: <20170821132341.23118-3-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Aug 2017 15:23:36 +0200
Phil Sutter <phil@nwl.cc> wrote:

> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/xfrm_state.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
> index e11c93bf1c3b5..7c0389038986e 100644
> --- a/ip/xfrm_state.c
> +++ b/ip/xfrm_state.c
> @@ -125,7 +125,8 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
>  	fprintf(stderr, "warning: ALGO-NAME/ALGO-KEYMAT values will be sent to the kernel promiscuously! (verifying them isn't implemented yet)\n");
>  #endif
>  
> -	strncpy(alg->alg_name, name, sizeof(alg->alg_name));
> +	strncpy(alg->alg_name, name, sizeof(alg->alg_name) - 1);
> +	alg->alg_name[sizeof(alg->alg_name) - 1] = '\0';
>  
>  	if (slen > 2 && strncmp(key, "0x", 2) == 0) {
>  		/* split two chars "0x" from the top */

You are fixing enough of these null terminated string issues, that maybe
introducing strlcpy() would make sense. Either in utils (or -lbsd).
