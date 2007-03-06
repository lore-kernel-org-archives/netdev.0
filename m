From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 15:19:20 +0100
Message-ID: <200703061519.20346.dada1@cosmosbay.com>
References: <20070223170527.4ca695b2@freekitty> <20070305155714.3abe1b5e@freekitty> <20070306133404.GA864@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:39327 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965051AbXCFOTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 09:19:22 -0500
In-Reply-To: <20070306133404.GA864@one.firstfloor.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 06 March 2007 14:34, Andi Kleen wrote:

> -	return x;
> +	int s;
> +	u32 y;
> +	u64 b;
> +	u64 bs;
> +
> +	y = 0;
> +	for (s = 63; s >= 0; s -= 3) {
> +		y = 2 * y;
> +		b = 3 * y * (y+1) + 1;
> +		bs = b << s;
> +		if (x >= bs && (b == (bs>>s))) {  /* avoid overflow */
> +			x -= bs;
> +			y++;
> +		}
> +	}
> +	return y;
>  }
>

Andi

<rant>
Let me see... You throw code like that and expect someone to actually 
understand it in one year, and be able to correct a bug ?
</rant>

Please add something, an URL or even better a nice explanation, per favor...

Thank you
