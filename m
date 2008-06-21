From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/8] textsearch: fix Boyer-Moore algorithm for case insensitive
 searching
Date: Sat, 21 Jun 2008 10:25:08 +0200
Message-ID: <485CBAE4.4030307@trash.net>
References: <> <1214034845-1316-1-git-send-email-joonwpark81@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1214034845-1316-1-git-send-email-joonwpark81@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joonwoo Park wrote:
> @@ -75,7 +77,9 @@ static unsigned int bm_find(struct ts_config *conf, struct ts_state *state)
>  			DEBUGP("Searching in position %d (%c)\n", 
>  				shift, text[shift]);
>  			for (i = 0; i < bm->patlen; i++) 
> -			     if (text[shift-i] != bm->pattern[bm->patlen-1-i])
> +				if ((icase ? toupper(text[shift-i])
> +				    : text[shift-i])
> +					!= bm->pattern[bm->patlen-1-i])
>  				     goto next;
>  
>  			/* London calling... */
> @@ -111,14 +115,18 @@ static int subpattern(u8 *pattern, int i, int j, int g)
>  	return ret;
>  }
>  
> -static void compute_prefix_tbl(struct ts_bm *bm)
> +static void compute_prefix_tbl(struct ts_bm *bm, u8 icase)
>  {
>  	int i, j, g;
>  
>  	for (i = 0; i < ASIZE; i++)
>  		bm->bad_shift[i] = bm->patlen;
> -	for (i = 0; i < bm->patlen - 1; i++)
> +	for (i = 0; i < bm->patlen - 1; i++) {
>  		bm->bad_shift[bm->pattern[i]] = bm->patlen - 1 - i;
> +		if (icase)
> +			bm->bad_shift[tolower(bm->pattern[i])]
> +			    = bm->patlen - 1 - i;
> +	}

You use toupper() above and tolower() here, is that correct?
