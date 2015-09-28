From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 13/23] usb-gadget/f_uac2: use per-attribute show and store
 methods
Date: Mon, 28 Sep 2015 13:56:57 +0200
Message-ID: <56092B09.9000007@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-14-git-send-email-hch@lst.de>
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
Received: from mailout1.w1.samsung.com ([210.118.77.11]:44018 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756999AbbI1L5A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 07:57:00 -0400
In-reply-to: <1443189000-13398-14-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

> ---
>   drivers/usb/gadget/function/f_uac2.c | 28 +++++++++++-----------------
>   1 file changed, 11 insertions(+), 17 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_uac2.c b/drivers/usb/gadget/function/f_uac2.c
> index f8de7ea..0a5a1e1 100644
> --- a/drivers/usb/gadget/function/f_uac2.c
> +++ b/drivers/usb/gadget/function/f_uac2.c
> @@ -1445,9 +1445,6 @@ static inline struct f_uac2_opts *to_f_uac2_opts(struct config_item *item)
>   			    func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_uac2_opts);
> -CONFIGFS_ATTR_OPS(f_uac2_opts);
> -
>   static void f_uac2_attr_release(struct config_item *item)
>   {
>   	struct f_uac2_opts *opts = to_f_uac2_opts(item);
> @@ -1457,14 +1454,13 @@ static void f_uac2_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations f_uac2_item_ops = {
>   	.release	= f_uac2_attr_release,
> -	.show_attribute	= f_uac2_opts_attr_show,
> -	.store_attribute = f_uac2_opts_attr_store,
>   };
>
>   #define UAC2_ATTRIBUTE(name)						\
> -static ssize_t f_uac2_opts_##name##_show(struct f_uac2_opts *opts,	\
> +static ssize_t f_uac2_opts_##name##_show(struct config_item *item,	\
>   					 char *page)			\
>   {									\
> +	struct f_uac2_opts *opts = to_f_uac2_opts(item);		\
>   	int result;							\
>   									\
>   	mutex_lock(&opts->lock);					\
> @@ -1474,9 +1470,10 @@ static ssize_t f_uac2_opts_##name##_show(struct f_uac2_opts *opts,	\
>   	return result;							\
>   }									\
>   									\
> -static ssize_t f_uac2_opts_##name##_store(struct f_uac2_opts *opts,	\
> +static ssize_t f_uac2_opts_##name##_store(struct config_item *item,	\
>   					  const char *page, size_t len)	\
>   {									\
> +	struct f_uac2_opts *opts = to_f_uac2_opts(item);		\
>   	int ret;							\
>   	u32 num;							\
>   									\
> @@ -1498,10 +1495,7 @@ end:									\
>   	return ret;							\
>   }									\
>   									\
> -static struct f_uac2_opts_attribute f_uac2_opts_##name =		\
> -	__CONFIGFS_ATTR(name, S_IRUGO | S_IWUSR,			\
> -			f_uac2_opts_##name##_show,			\
> -			f_uac2_opts_##name##_store)
> +CONFIGFS_ATTR(f_uac2_opts_, name)
>
>   UAC2_ATTRIBUTE(p_chmask);
>   UAC2_ATTRIBUTE(p_srate);
> @@ -1511,12 +1505,12 @@ UAC2_ATTRIBUTE(c_srate);
>   UAC2_ATTRIBUTE(c_ssize);
>
>   static struct configfs_attribute *f_uac2_attrs[] = {
> -	&f_uac2_opts_p_chmask.attr,
> -	&f_uac2_opts_p_srate.attr,
> -	&f_uac2_opts_p_ssize.attr,
> -	&f_uac2_opts_c_chmask.attr,
> -	&f_uac2_opts_c_srate.attr,
> -	&f_uac2_opts_c_ssize.attr,
> +	&f_uac2_opts_attr_p_chmask,
> +	&f_uac2_opts_attr_p_srate,
> +	&f_uac2_opts_attr_p_ssize,
> +	&f_uac2_opts_attr_c_chmask,
> +	&f_uac2_opts_attr_c_srate,
> +	&f_uac2_opts_attr_c_ssize,
>   	NULL,
>   };
>
>
