From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] Add support for configuring Infiniband GUIDs
Date: Wed, 6 Jul 2016 21:05:26 -0700
Message-ID: <20160706210526.1e6ea9a4@xeon-e3>
References: <1467734018-11119-1-git-send-email-eli@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36125 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750697AbcGGEKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 00:10:51 -0400
Received: by mail-pf0-f174.google.com with SMTP id t190so2372982pfb.3
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 21:10:51 -0700 (PDT)
In-Reply-To: <1467734018-11119-1-git-send-email-eli@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Jul 2016 10:53:38 -0500
Eli Cohen <eli@mellanox.com> wrote:

>  
> +static int extract_guid(__u64 *guid, char *arg)
> +{
> +	__u64 ret;
> +	int g[8];
> +	int err;
> +
> +	err = sscanf(arg, "%02x:%02x:%02x:%02x:%02x:%02x:%02x:%02x",
> +		     g, g + 1, g + 2, g + 3, g + 4, g + 5, g + 6, g + 7);
> +	if (err != 8)
> +		return -1;
> +
> +	ret = ((__u64)(g[0]) << 56) |
> +	      ((__u64)(g[1]) << 48) |
> +	      ((__u64)(g[2]) << 40) |
> +	      ((__u64)(g[3]) << 32) |
> +	      ((__u64)(g[4]) << 24) |
> +	      ((__u64)(g[5]) << 16) |
> +	      ((__u64)(g[6]) << 8) |
> +	      ((__u64)(g[7]));
> +	*guid = ret;
> +
> +	return 0;
> +}

I would like several things changed here.
 1. put this in generic (ie lib/utils.c) so that other places
    can use it. And rename it match other arg parsing code (ie get_guid)
 2. need range checking for each piece the string, and each hex piece must be unsigned int
    suprised gcc format checks didn't bust you on this.  why not %hhx as format specifier
    
 3. arg should be const char *
 4. local variable err is really unnecessary
 5. local variable ret is unnecessary, you could just assign to *guid
 
