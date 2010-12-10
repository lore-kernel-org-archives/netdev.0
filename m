From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: add dynamic index and name hashes
Date: Fri, 10 Dec 2010 08:20:40 -0800
Message-ID: <20101210082040.230a2832@nehalam>
References: <1291993164-8793-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45357 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756379Ab0LJQUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 11:20:42 -0500
In-Reply-To: <1291993164-8793-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Dec 2010 16:59:24 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> The hashes sizes start with 16 entries and grow up to 2^20
> entries. The hashes double when the entries in the LL map is greater
> then the hash size.
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---
>  lib/ll_map.c |  125 +++++++++++++++++++++++++++++++++++++++++++++++----------
>  1 files changed, 103 insertions(+), 22 deletions(-)
> 
> diff --git a/lib/ll_map.c b/lib/ll_map.c
> index b8b49aa..9831322 100644
> --- a/lib/ll_map.c
> +++ b/lib/ll_map.c
> @@ -26,7 +26,8 @@ extern unsigned int if_nametoindex (const char *);
>  
>  struct idxmap
>  {
> -	struct idxmap * next;
> +	struct idxmap *idx_next;
> +	struct idxmap *name_next;
>  	unsigned	index;
>  	int		type;
>  	int		alen;
> @@ -35,31 +36,100 @@ struct idxmap
>  	char		name[16];
>  };
>  
> -static struct idxmap *idxmap[16];

This is user space, and memory space is realtively cheap. Why not just
make initial idxmap much bigger and be done with it.


-- 
