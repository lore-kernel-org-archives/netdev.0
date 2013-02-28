From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net/rds: using strlcpy instead of strncpy
Date: Thu, 28 Feb 2013 09:36:48 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B716D@saturn3.aculab.com>
References: <512F1534.9020404@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 8BIT
To: "Chen Gang" <gang.chen@asianux.com>,
	<venkat.x.venkatsubra@oracle.com>,
	"David Miller" <davem@davemloft.net>, <rds-devel@oss.oracle.com>,
	"netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53682 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751159Ab3B1Jmv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 04:42:51 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11372-08 for <netdev@vger.kernel.org>;
 Thu, 28 Feb 2013 09:42:47 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <512F1534.9020404@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>   when src strlen is sizeof(ctr.name) - 1, the dest str is not '\0' end.
>   better use strlcpy instead.
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  net/rds/stats.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/rds/stats.c b/net/rds/stats.c
> index 7be790d..b9ac1df 100644
> --- a/net/rds/stats.c
> +++ b/net/rds/stats.c
> @@ -86,7 +86,7 @@ void rds_stats_info_copy(struct rds_info_iterator *iter,
> 
>  	for (i = 0; i < nr; i++) {
>  		BUG_ON(strlen(names[i]) >= sizeof(ctr.name));
> -		strncpy(ctr.name, names[i], sizeof(ctr.name) - 1);
> +		strlcpy(ctr.name, names[i], sizeof(ctr.name));
>  		ctr.value = values[i];
> 

If the target buffer ends up being copied to userspace that
might lead to random kernel memory being leaked.

	David
