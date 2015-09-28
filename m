From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 07/23] usb-gadget/f_loopback: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 13:46:57 +0200
Message-ID: <560928B1.1000605@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-8-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.w1.samsung.com ([210.118.77.13]:52942 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932771AbbI1LrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 07:47:01 -0400
In-reply-to: <1443189000-13398-8-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,

Please see comments inline.

With the issue addressed you can add

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   drivers/usb/gadget/function/f_loopback.c | 32 ++++++++++++--------------------
>   1 file changed, 12 insertions(+), 20 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_loopback.c b/drivers/usb/gadget/function/f_loopback.c
> index 6e2fe63..d4ef421 100644
> --- a/drivers/usb/gadget/function/f_loopback.c
> +++ b/drivers/usb/gadget/function/f_loopback.c
> @@ -413,9 +413,6 @@ static inline struct f_lb_opts *to_f_lb_opts(struct config_item *item)
>   			    func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_lb_opts);
> -CONFIGFS_ATTR_OPS(f_lb_opts);
> -
>   static void lb_attr_release(struct config_item *item)
>   {
>   	struct f_lb_opts *lb_opts = to_f_lb_opts(item);
> @@ -425,12 +422,11 @@ static void lb_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations lb_item_ops = {
>   	.release		= lb_attr_release,
> -	.show_attribute		= f_lb_opts_attr_show,
> -	.store_attribute	= f_lb_opts_attr_store,
>   };
>
> -static ssize_t f_lb_opts_qlen_show(struct f_lb_opts *opts, char *page)
> +static ssize_t f_lb_opts_qlen_show(struct config_item *item, char *page)
>   {
> +	struct f_lb_opts *opts = to_f_lb_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -440,9 +436,10 @@ static ssize_t f_lb_opts_qlen_show(struct f_lb_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_lb_opts_qlen_store(struct f_lb_opts *opts,
> +static ssize_t f_lb_opts_qlen_store(struct config_item *item,
>   				    const char *page, size_t len)
>   {
> +	struct f_lb_opts *opts = to_f_lb_opts(item);
>   	int ret;
>   	u32 num;
>
> @@ -463,13 +460,9 @@ end:
>   	return ret;
>   }
>
> -static struct f_lb_opts_attribute f_lb_opts_qlen =
> -	__CONFIGFS_ATTR(qlen, S_IRUGO | S_IWUSR,
> -			f_lb_opts_qlen_show,
> -			f_lb_opts_qlen_store);
> -
In my opinion the below line belongs here:

+CONFIGFS_ATTR(f_lb_opts_, qlen);

> -static ssize_t f_lb_opts_bulk_buflen_show(struct f_lb_opts *opts, char *page)
> +static ssize_t f_lb_opts_bulk_buflen_show(struct config_item *item, char *page)
>   {
> +	struct f_lb_opts *opts = to_f_lb_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -479,9 +472,10 @@ static ssize_t f_lb_opts_bulk_buflen_show(struct f_lb_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_lb_opts_bulk_buflen_store(struct f_lb_opts *opts,
> +static ssize_t f_lb_opts_bulk_buflen_store(struct config_item *item,
>   				    const char *page, size_t len)
>   {
> +	struct f_lb_opts *opts = to_f_lb_opts(item);
>   	int ret;
>   	u32 num;
>
> @@ -502,14 +496,12 @@ end:
>   	return ret;
>   }
>
> -static struct f_lb_opts_attribute f_lb_opts_bulk_buflen =
> -	__CONFIGFS_ATTR(buflen, S_IRUGO | S_IWUSR,
> -			f_lb_opts_bulk_buflen_show,
> -			f_lb_opts_bulk_buflen_store);
> +CONFIGFS_ATTR(f_lb_opts_, qlen);
> +CONFIGFS_ATTR(f_lb_opts_, bulk_buflen);

Why group CONFIGFS_ATTR invocations if in the original code their
corresponding __CONFIGFS_ATTR invocations were where they were?


>
>   static struct configfs_attribute *lb_attrs[] = {
> -	&f_lb_opts_qlen.attr,
> -	&f_lb_opts_bulk_buflen.attr,
> +	&f_lb_opts_attr_qlen,
> +	&f_lb_opts_attr_bulk_buflen,
>   	NULL,
>   };
>
>
