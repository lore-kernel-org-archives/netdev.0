From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 12/23] usb-gadget/f_ac1: use per-attribute show and store
 methods
Date: Mon, 28 Sep 2015 13:56:11 +0200
Message-ID: <56092ADB.9010905@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-13-git-send-email-hch@lst.de>
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
Received: from mailout3.w1.samsung.com ([210.118.77.13]:53495 "EHLO
	mailout3.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014AbbI1L4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 07:56:15 -0400
In-reply-to: <1443189000-13398-13-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,

The commit title should be ".... usb-gadget/f_uac1 ..."
instead of ".... f_ac1 ..."

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   drivers/usb/gadget/function/f_uac1.c | 39 +++++++++++++++---------------------
>   1 file changed, 16 insertions(+), 23 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_uac1.c b/drivers/usb/gadget/function/f_uac1.c
> index 7856b33..ad01032 100644
> --- a/drivers/usb/gadget/function/f_uac1.c
> +++ b/drivers/usb/gadget/function/f_uac1.c
> @@ -773,9 +773,6 @@ static inline struct f_uac1_opts *to_f_uac1_opts(struct config_item *item)
>   			    func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_uac1_opts);
> -CONFIGFS_ATTR_OPS(f_uac1_opts);
> -
>   static void f_uac1_attr_release(struct config_item *item)
>   {
>   	struct f_uac1_opts *opts = to_f_uac1_opts(item);
> @@ -785,14 +782,13 @@ static void f_uac1_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations f_uac1_item_ops = {
>   	.release	= f_uac1_attr_release,
> -	.show_attribute	= f_uac1_opts_attr_show,
> -	.store_attribute = f_uac1_opts_attr_store,
>   };
>
>   #define UAC1_INT_ATTRIBUTE(name)					\
> -static ssize_t f_uac1_opts_##name##_show(struct f_uac1_opts *opts,	\
> +static ssize_t f_uac1_opts_##name##_show(struct config_item *item,	\
>   					 char *page)			\
>   {									\
> +	struct f_uac1_opts *opts = to_f_uac1_opts(item);		\
>   	int result;							\
>   									\
>   	mutex_lock(&opts->lock);					\
> @@ -802,9 +798,10 @@ static ssize_t f_uac1_opts_##name##_show(struct f_uac1_opts *opts,	\
>   	return result;							\
>   }									\
>   									\
> -static ssize_t f_uac1_opts_##name##_store(struct f_uac1_opts *opts,	\
> +static ssize_t f_uac1_opts_##name##_store(struct config_item *item,		\
>   					  const char *page, size_t len)	\
>   {									\
> +	struct f_uac1_opts *opts = to_f_uac1_opts(item);		\
>   	int ret;							\
>   	u32 num;							\
>   									\
> @@ -826,19 +823,17 @@ end:									\
>   	return ret;							\
>   }									\
>   									\
> -static struct f_uac1_opts_attribute f_uac1_opts_##name =		\
> -	__CONFIGFS_ATTR(name, S_IRUGO | S_IWUSR,			\
> -			f_uac1_opts_##name##_show,			\
> -			f_uac1_opts_##name##_store)
> +CONFIGFS_ATTR(f_uac1_opts_, name)
>
>   UAC1_INT_ATTRIBUTE(req_buf_size);
>   UAC1_INT_ATTRIBUTE(req_count);
>   UAC1_INT_ATTRIBUTE(audio_buf_size);
>
>   #define UAC1_STR_ATTRIBUTE(name)					\
> -static ssize_t f_uac1_opts_##name##_show(struct f_uac1_opts *opts,	\
> +static ssize_t f_uac1_opts_##name##_show(struct config_item *item,	\
>   					 char *page)			\
>   {									\
> +	struct f_uac1_opts *opts = to_f_uac1_opts(item);		\
>   	int result;							\
>   									\
>   	mutex_lock(&opts->lock);					\
> @@ -848,9 +843,10 @@ static ssize_t f_uac1_opts_##name##_show(struct f_uac1_opts *opts,	\
>   	return result;							\
>   }									\
>   									\
> -static ssize_t f_uac1_opts_##name##_store(struct f_uac1_opts *opts,	\
> +static ssize_t f_uac1_opts_##name##_store(struct config_item *item,	\
>   					  const char *page, size_t len)	\
>   {									\
> +	struct f_uac1_opts *opts = to_f_uac1_opts(item);		\
>   	int ret = -EBUSY;						\
>   	char *tmp;							\
>   									\
> @@ -874,22 +870,19 @@ end:									\
>   	return ret;							\
>   }									\
>   									\
> -static struct f_uac1_opts_attribute f_uac1_opts_##name =		\
> -	__CONFIGFS_ATTR(name, S_IRUGO | S_IWUSR,			\
> -			f_uac1_opts_##name##_show,			\
> -			f_uac1_opts_##name##_store)
> +CONFIGFS_ATTR(f_uac1_opts_, name)
>
>   UAC1_STR_ATTRIBUTE(fn_play);
>   UAC1_STR_ATTRIBUTE(fn_cap);
>   UAC1_STR_ATTRIBUTE(fn_cntl);
>
>   static struct configfs_attribute *f_uac1_attrs[] = {
> -	&f_uac1_opts_req_buf_size.attr,
> -	&f_uac1_opts_req_count.attr,
> -	&f_uac1_opts_audio_buf_size.attr,
> -	&f_uac1_opts_fn_play.attr,
> -	&f_uac1_opts_fn_cap.attr,
> -	&f_uac1_opts_fn_cntl.attr,
> +	&f_uac1_opts_attr_req_buf_size,
> +	&f_uac1_opts_attr_req_count,
> +	&f_uac1_opts_attr_audio_buf_size,
> +	&f_uac1_opts_attr_fn_play,
> +	&f_uac1_opts_attr_fn_cap,
> +	&f_uac1_opts_attr_fn_cntl,
>   	NULL,
>   };
>
>
