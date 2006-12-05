From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] allow ip_tables.h to be used from userspace
Date: Tue, 05 Dec 2006 19:38:21 +0100
Message-ID: <4575BC9D.8070900@trash.net>
References: <20061205102927.4f1ef22f@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43292 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968587AbWLESi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 13:38:28 -0500
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061205102927.4f1ef22f@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The xtables version of ip_tables.h was no longer usable (in sanitized form)
> by iproute2 and other applications because sparse annotations had crept
> in.
> 
> @@ -194,7 +194,7 @@ struct ipt_replace
>  	/* Number of counters (must be equal to current number of entries). */
>  	unsigned int num_counters;
>  	/* The old entries' counters. */
> -	struct xt_counters __user *counters;
> +	struct xt_counters *counters;

# Eliminate the contents of (and inclusions of) compiler.h


HDRSED  := sed  -e "s/ inline / __inline__ /g" \
                -e "s/[[:space:]]__user[[:space:]]\+/ /g" \
                -e "s/(__user[[:space:]]\+/ (/g" \

I think this regex should be fixed instead to get rid of it
while sanitizing (Makefile.headersinst).

