From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 1/2] gen_stats.c: Duplicate xstats buffer for later
 use
Date: Thu, 8 Jan 2015 12:26:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CAC359A@AcuExch.aculab.com>
References: <20150108103518.GA7214@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: 'Ignacy Gawedzki' <ignacy.gawedzki@green-communications.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:51778 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579AbbAHM1Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 07:27:24 -0500
In-Reply-To: <20150108103518.GA7214@zenon.in.qult.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ignacy Gawedzki
> The gnet_stats_copy_app() function gets called, more often than not, with its
> second argument a pointer to an automatic variable in the caller's stack.
> Therefore, to avoid copying garbage afterwards when calling
> gnet_stats_finish_copy(), this data is better copied to a dynamically allocated
> memory that gets freed after use.
> 
> Signed-off-by: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
> ---
>  net/core/gen_stats.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/net/core/gen_stats.c b/net/core/gen_stats.c
> index 0c08062..5770a0e 100644
> --- a/net/core/gen_stats.c
> +++ b/net/core/gen_stats.c
> @@ -305,7 +305,10 @@ int
>  gnet_stats_copy_app(struct gnet_dump *d, void *st, int len)
>  {
>  	if (d->compat_xstats) {
> -		d->xstats = st;
> +		d->xstats = kmalloc(len, GFP_KERNEL);
> +		if (!d->xstats)
> +			goto kmalloc_failure;
> +		memcpy(d->xstats, st, len);
>  		d->xstats_len = len;

Looking at this again, isn't the purpose of the 'void *st' to pass
down a temporary buffer that is 'big enough' ?

	David
