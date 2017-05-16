From: Stefano Stabellini <sstabellini@kernel.org>
Subject: Re: [PATCH] xen/9pfs: fix return value check in
 xen_9pfs_front_probe()
Date: Tue, 16 May 2017 11:35:02 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1705161134500.4103@sstabellini-ThinkPad-X260>
References: <20170516142247.12301-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Latchesar Ionkov <lucho@ionkov.net>,
        Stefano Stabellini <sstabellini@kernel.org>,
        Juergen Gross <jgross@suse.com>,
        Wei Yongjun <weiyongjun1@huawei.com>,
        v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:33060 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751931AbdEPSfE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 16 May 2017 14:35:04 -0400
In-Reply-To: <20170516142247.12301-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 May 2017, Wei Yongjun wrote:
> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> In case of error, the function xenbus_read() returns ERR_PTR() and never
> returns NULL. The NULL test in the return value check should be replaced
> with IS_ERR().
> 
> Fixes: 71ebd71921e4 ("xen/9pfs: connect to the backend")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Reviewed-by: Stefano Stabellini <sstabellini@kernel.org>

Thank you!

> ---
>  net/9p/trans_xen.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/9p/trans_xen.c b/net/9p/trans_xen.c
> index 71e8564..83fe487 100644
> --- a/net/9p/trans_xen.c
> +++ b/net/9p/trans_xen.c
> @@ -454,8 +454,8 @@ static int xen_9pfs_front_probe(struct xenbus_device *dev,
>  			goto error_xenbus;
>  	}
>  	priv->tag = xenbus_read(xbt, dev->nodename, "tag", NULL);
> -	if (!priv->tag) {
> -		ret = -EINVAL;
> +	if (IS_ERR(priv->tag)) {
> +		ret = PTR_ERR(priv->tag);
>  		goto error_xenbus;
>  	}
>  	ret = xenbus_transaction_end(xbt, 0);
> 
