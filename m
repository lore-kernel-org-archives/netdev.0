From: Joonwoo Park <joonwpark81@gmail.com>
Subject: Re: [PATCH 2.6.24] fib_trie: apply fixes from fib_hash
Date: Sat, 26 Jan 2008 14:18:15 +0900
Message-ID: <20080126051815.GA17278@ehus.geninetworks.com>
References: <Pine.LNX.4.58.0801260427400.12635@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Robert Olsson <robert.olsson@data.slu.se>,
	netdev@vger.kernel.org, Joonwoo Park <joonwpark81@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jarek Poplawski <jarkao2@gmail.com>, schwab@suse.de
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.190]:46397 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751532AbYAZFSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 00:18:18 -0500
Received: by rv-out-0910.google.com with SMTP id k20so998187rvb.1
        for <netdev@vger.kernel.org>; Fri, 25 Jan 2008 21:18:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0801260427400.12635@u.domain.uli>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 26, 2008 at 04:40:30AM +0200, Julian Anastasov wrote:
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>
> ---
> 
> 	Not tested, someone please check the findings
> 
> --- linux-2.6.24/net/ipv4/fib_trie.c_orig	2008-01-25 10:45:06.000000000 +0200
> +
>  		if (cfg->fc_nlflags & NLM_F_REPLACE) {
>  			struct fib_info *fi_drop;
>  			u8 state;
>  
> -			if (fi->fib_treeref > 1)
> +			fa = fa_first;
> +			if (fa_match && fa != fa_match)
>  				goto out;
> -

Isn't it possible to do this (fib_hash too)?
			if (fa_match) {
				if (fa != fa_match)
					return 0;
				goto out;
			}

Thanks,
Joonwoo
