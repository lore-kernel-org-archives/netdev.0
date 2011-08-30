From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch 2/2] 9p: change an int to unsigned int
Date: Tue, 30 Aug 2011 13:08:28 +0530
Message-ID: <87vctfs617.fsf@skywalker.in.ibm.com>
References: <20110826165740.GF3775@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	"Venkateswararao Jujjuri \(JV\)" <jvrao@linux.vnet.ibm.com>,
	"M. Mohan Kumar" <mohan@in.ibm.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"open list\:NETWORKING \[GENERAL\]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>,
	Eric Van Hensbergen <ericvh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44259 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423Ab1H3Hiw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 03:38:52 -0400
In-Reply-To: <20110826165740.GF3775@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2011 19:57:40 +0300, Dan Carpenter <error27@gmail.com> wrote:
> The size of things should be unsigned because negative sizes are
> silly.  My concern is the the limit checks don't take negative values
> into consideration in p9_client_create()
> 	if (clnt->msize > clnt->trans_mod->maxsize)
> 		clnt->msize = clnt->trans_mod->maxsize;
> and in p9_tag_alloc()
> 	int alloc_msize = min(c->msize, max_size);
> 
> I don't know if this is exported to user space?  Hopefully it's not
> too late to change this.

The change is also needed to make sure large msize value (429496729) works
Without the change it cause a server crash with Qemu 9p server.

> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/include/net/9p/client.h b/include/net/9p/client.h
> index 55ce72c..d479d7d 100644
> --- a/include/net/9p/client.h
> +++ b/include/net/9p/client.h
> @@ -151,7 +151,7 @@ struct p9_req_t {
> 
>  struct p9_client {
>  	spinlock_t lock; /* protect client structure */
> -	int msize;
> +	unsigned int msize;
>  	unsigned char proto_version;
>  	struct p9_trans_module *trans_mod;
>  	enum p9_trans_status status;

I applied this with comment update to 
git://git.kernel.org/pub/scm/linux/kernel/git/kvaneesh/v9fs.git for-upstream-next-merge

-aneesh
