From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [patch] sock_diag: off by one checks
Date: Thu, 08 Dec 2011 13:07:55 +0400
Message-ID: <4EE07E6B.5050608@parallels.com>
References: <20111208064938.GB16735@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:22497 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1LHJIK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 04:08:10 -0500
In-Reply-To: <20111208064938.GB16735@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/2011 10:49 AM, Dan Carpenter wrote:
> These tests are off by one because sock_diag_handlers[] only has AF_MAX
> elements.

Oops :(

> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

> diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
> index fbaf01c..9c27bcd 100644
> --- a/net/core/sock_diag.c
> +++ b/net/core/sock_diag.c
> @@ -32,7 +32,7 @@ int sock_diag_register(struct sock_diag_handler *hndl)
>  {
>  	int err = 0;
>  
> -	if (hndl->family > AF_MAX)
> +	if (hndl->family >= AF_MAX)
>  		return -EINVAL;
>  
>  	mutex_lock(&sock_diag_table_mutex);
> @@ -50,7 +50,7 @@ void sock_diag_unregister(struct sock_diag_handler *hnld)
>  {
>  	int family = hnld->family;
>  
> -	if (family > AF_MAX)
> +	if (family >= AF_MAX)
>  		return;
>  
>  	mutex_lock(&sock_diag_table_mutex);
> 
