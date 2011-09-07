From: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
Subject: Re: [patch 1/2] 9p: move dereference after NULL check
Date: Wed, 07 Sep 2011 08:31:16 -0700
Message-ID: <4E678E44.1020204@linux.vnet.ibm.com>
References: <20110826165559.GE3775@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	"M. Mohan Kumar" <mohan@in.ibm.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53243 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755665Ab1IGQJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:09:42 -0400
In-Reply-To: <20110826165559.GE3775@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2011 09:55 AM, Dan Carpenter wrote:
> We dereferenced "req->tc" and "req->rc" before checking for NULL.
>
> Signed-off-by: Dan Carpenter<error27@gmail.com>
Reviewed-by: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
>
> diff --git a/net/9p/client.c b/net/9p/client.c
> index 3f8c046..b0bcace 100644
> --- a/net/9p/client.c
> +++ b/net/9p/client.c
> @@ -248,10 +248,8 @@ static struct p9_req_t *p9_tag_alloc(struct p9_client *c, u16 tag, int max_size)
>   		init_waitqueue_head(req->wq);
>   		req->tc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
>   				  GFP_NOFS);
> -		req->tc->capacity = alloc_msize;
>   		req->rc = kmalloc(sizeof(struct p9_fcall) + alloc_msize,
>   				  GFP_NOFS);
> -		req->rc->capacity = alloc_msize;
>   		if ((!req->tc) || (!req->rc)) {
>   			printk(KERN_ERR "Couldn't grow tag array\n");
>   			kfree(req->tc);
> @@ -261,6 +259,8 @@ static struct p9_req_t *p9_tag_alloc(struct p9_client *c, u16 tag, int max_size)
>   			req->wq = NULL;
>   			return ERR_PTR(-ENOMEM);
>   		}
> +		req->tc->capacity = alloc_msize;
> +		req->rc->capacity = alloc_msize;
>   		req->tc->sdata = (char *) req->tc + sizeof(struct p9_fcall);
>   		req->rc->sdata = (char *) req->rc + sizeof(struct p9_fcall);
>   	}
