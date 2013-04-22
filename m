From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Net: rxrpc: signed and unsigned issue, need type cast
 for n_elem.
Date: Mon, 22 Apr 2013 20:34:41 +0100
Message-ID: <1366659281.4016.7.camel@bwh-desktop.uk.solarflarecom.com>
References: <51750FC0.8000603@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Serge Hallyn <serge.hallyn@canonical.com>,
	netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:26261 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754786Ab3DVTeq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 15:34:46 -0400
In-Reply-To: <51750FC0.8000603@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-22 at 18:24 +0800, Chen Gang wrote:
> n_elem is unsigned int which never < 0.
>   but it seems, we realy need check it whether < 0.
>   so need a type cast for it.
> 
>   find it by EXTRA_CFLAGS=-W
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> ---
>  net/rxrpc/ar-key.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
> index 7633a75..ba0b722 100644
> --- a/net/rxrpc/ar-key.c
> +++ b/net/rxrpc/ar-key.c
> @@ -346,7 +346,7 @@ static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
>  
>  	n_elem = ntohl(*xdr++);
>  	toklen -= 4;
> -	if (n_elem < 0 || n_elem > max_n_elem)
> +	if ((int)n_elem < 0 || n_elem > max_n_elem)

(int)n_elem < 0 is equivalent to n_elem >= 0x80000000, and if that is
true then n_elem > max_n_elem (because max_n_elem <= 0xff).

Ben.

>  		return -EINVAL;
>  	*_n_elem = n_elem;
>  	if (n_elem > 0) {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
