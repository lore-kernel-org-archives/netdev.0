From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2 1/2] ss: Fix compiler errors of unused
 return-values
Date: Mon, 22 Jul 2013 08:38:59 -0700
Message-ID: <1374507539.4990.17.camel@edumazet-glaptop>
References: <1374350298-1177-1-git-send-email-christoph.paasch@uclouvain.be>
	 <1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:65296 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252Ab3GVPjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 11:39:10 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so7184565pbc.35
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 08:39:10 -0700 (PDT)
In-Reply-To: <1374350298-1177-2-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-07-20 at 21:58 +0200, Christoph Paasch wrote:
> Many errors when compiling with gcc 4.7.3 about unused return-values
> upon the calls to fgets and fscanf:
> 

> For the calls to fscanf we can't really do anything about it, and just
> do an empty if-statement to make the compiler happy.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  misc/ss.c | 30 +++++++++++++++++++++---------
>  1 file changed, 21 insertions(+), 9 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index c0369f1..0f71108 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -302,7 +302,7 @@ static void user_ent_hash_build(void)
>  
>  				snprintf(tmp, sizeof(tmp), "%s/%d/stat", root, pid);
>  				if ((fp = fopen(tmp, "r")) != NULL) {
> -					fscanf(fp, "%*d (%[^)])", process);
> +					if (fscanf(fp, "%*d (%[^)])", process) == EOF);

This is really ugly :(
