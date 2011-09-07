From: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
Subject: Re: [patch 2/2] 9p: change an int to unsigned int
Date: Wed, 07 Sep 2011 08:33:08 -0700
Message-ID: <4E678EB4.6020002@linux.vnet.ibm.com>
References: <20110826165740.GF3775@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
	"M. Mohan Kumar" <mohan@in.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53234 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756547Ab1IGQJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Sep 2011 12:09:40 -0400
In-Reply-To: <20110826165740.GF3775@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/26/2011 09:57 AM, Dan Carpenter wrote:
> The size of things should be unsigned because negative sizes are
> silly.  My concern is the the limit checks don't take negative values
> into consideration in p9_client_create()
> 	if (clnt->msize>  clnt->trans_mod->maxsize)
> 		clnt->msize = clnt->trans_mod->maxsize;
> and in p9_tag_alloc()
> 	int alloc_msize = min(c->msize, max_size);
>
> I don't know if this is exported to user space?  Hopefully it's not
> too late to change this.
It is not exported to user space but the other way is true;
  msize can be populate from mount option. It should be fine.
>
> Signed-off-by: Dan Carpenter<error27@gmail.com>
Reviewed-by: Venkateswararao Jujjuri <jvrao@linux.vnet.ibm.com>
>
> diff --git a/include/net/9p/client.h b/include/net/9p/client.h
> index 55ce72c..d479d7d 100644
> --- a/include/net/9p/client.h
> +++ b/include/net/9p/client.h
> @@ -151,7 +151,7 @@ struct p9_req_t {
>
>   struct p9_client {
>   	spinlock_t lock; /* protect client structure */
> -	int msize;
> +	unsigned int msize;
>   	unsigned char proto_version;
>   	struct p9_trans_module *trans_mod;
>   	enum p9_trans_status status;
