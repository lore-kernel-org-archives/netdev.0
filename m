From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 10/23] usb-gadget/f_sourcesink: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 13:51:56 +0200
Message-ID: <560929DC.2030907@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-11-git-send-email-hch@lst.de>
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
Received: from mailout2.w1.samsung.com ([210.118.77.12]:37460 "EHLO
	mailout2.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932771AbbI1LwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 07:52:00 -0400
In-reply-to: <1443189000-13398-11-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,

The same remark as for f_loopback (__CONFIGFS_ATTR location vs
CONFIGFS_ATTR location after applying)

If addressed

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>


W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   drivers/usb/gadget/function/f_sourcesink.c | 88 ++++++++++++------------------
>   1 file changed, 36 insertions(+), 52 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_sourcesink.c b/drivers/usb/gadget/function/f_sourcesink.c
> index cbfaf86..e5288c7 100644
> --- a/drivers/usb/gadget/function/f_sourcesink.c
> +++ b/drivers/usb/gadget/function/f_sourcesink.c
> @@ -898,9 +898,6 @@ static inline struct f_ss_opts *to_f_ss_opts(struct config_item *item)
>   			    func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_ss_opts);
> -CONFIGFS_ATTR_OPS(f_ss_opts);
> -
>   static void ss_attr_release(struct config_item *item)
>   {
>   	struct f_ss_opts *ss_opts = to_f_ss_opts(item);
> @@ -910,12 +907,11 @@ static void ss_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations ss_item_ops = {
>   	.release		= ss_attr_release,
> -	.show_attribute		= f_ss_opts_attr_show,
> -	.store_attribute	= f_ss_opts_attr_store,
>   };
>
> -static ssize_t f_ss_opts_pattern_show(struct f_ss_opts *opts, char *page)
> +static ssize_t f_ss_opts_pattern_show(struct config_item *item, char *page)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -925,9 +921,10 @@ static ssize_t f_ss_opts_pattern_show(struct f_ss_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_ss_opts_pattern_store(struct f_ss_opts *opts,
> +static ssize_t f_ss_opts_pattern_store(struct config_item *item,
>   				       const char *page, size_t len)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int ret;
>   	u8 num;
>
> @@ -953,13 +950,9 @@ end:
>   	return ret;
>   }
>
> -static struct f_ss_opts_attribute f_ss_opts_pattern =
> -	__CONFIGFS_ATTR(pattern, S_IRUGO | S_IWUSR,
> -			f_ss_opts_pattern_show,
> -			f_ss_opts_pattern_store);
> -
> -static ssize_t f_ss_opts_isoc_interval_show(struct f_ss_opts *opts, char *page)
> +static ssize_t f_ss_opts_isoc_interval_show(struct config_item *item, char *page)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -969,9 +962,10 @@ static ssize_t f_ss_opts_isoc_interval_show(struct f_ss_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_ss_opts_isoc_interval_store(struct f_ss_opts *opts,
> +static ssize_t f_ss_opts_isoc_interval_store(struct config_item *item,
>   				       const char *page, size_t len)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int ret;
>   	u8 num;
>
> @@ -997,13 +991,9 @@ end:
>   	return ret;
>   }
>
> -static struct f_ss_opts_attribute f_ss_opts_isoc_interval =
> -	__CONFIGFS_ATTR(isoc_interval, S_IRUGO | S_IWUSR,
> -			f_ss_opts_isoc_interval_show,
> -			f_ss_opts_isoc_interval_store);
> -
> -static ssize_t f_ss_opts_isoc_maxpacket_show(struct f_ss_opts *opts, char *page)
> +static ssize_t f_ss_opts_isoc_maxpacket_show(struct config_item *item, char *page)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -1013,9 +1003,10 @@ static ssize_t f_ss_opts_isoc_maxpacket_show(struct f_ss_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_ss_opts_isoc_maxpacket_store(struct f_ss_opts *opts,
> +static ssize_t f_ss_opts_isoc_maxpacket_store(struct config_item *item,
>   				       const char *page, size_t len)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int ret;
>   	u16 num;
>
> @@ -1041,13 +1032,9 @@ end:
>   	return ret;
>   }
>
> -static struct f_ss_opts_attribute f_ss_opts_isoc_maxpacket =
> -	__CONFIGFS_ATTR(isoc_maxpacket, S_IRUGO | S_IWUSR,
> -			f_ss_opts_isoc_maxpacket_show,
> -			f_ss_opts_isoc_maxpacket_store);
> -
> -static ssize_t f_ss_opts_isoc_mult_show(struct f_ss_opts *opts, char *page)
> +static ssize_t f_ss_opts_isoc_mult_show(struct config_item *item, char *page)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -1057,9 +1044,10 @@ static ssize_t f_ss_opts_isoc_mult_show(struct f_ss_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_ss_opts_isoc_mult_store(struct f_ss_opts *opts,
> +static ssize_t f_ss_opts_isoc_mult_store(struct config_item *item,
>   				       const char *page, size_t len)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int ret;
>   	u8 num;
>
> @@ -1085,13 +1073,9 @@ end:
>   	return ret;
>   }
>
> -static struct f_ss_opts_attribute f_ss_opts_isoc_mult =
> -	__CONFIGFS_ATTR(isoc_mult, S_IRUGO | S_IWUSR,
> -			f_ss_opts_isoc_mult_show,
> -			f_ss_opts_isoc_mult_store);
> -
> -static ssize_t f_ss_opts_isoc_maxburst_show(struct f_ss_opts *opts, char *page)
> +static ssize_t f_ss_opts_isoc_maxburst_show(struct config_item *item, char *page)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -1101,9 +1085,10 @@ static ssize_t f_ss_opts_isoc_maxburst_show(struct f_ss_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_ss_opts_isoc_maxburst_store(struct f_ss_opts *opts,
> +static ssize_t f_ss_opts_isoc_maxburst_store(struct config_item *item,
>   				       const char *page, size_t len)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int ret;
>   	u8 num;
>
> @@ -1129,13 +1114,9 @@ end:
>   	return ret;
>   }
>
> -static struct f_ss_opts_attribute f_ss_opts_isoc_maxburst =
> -	__CONFIGFS_ATTR(isoc_maxburst, S_IRUGO | S_IWUSR,
> -			f_ss_opts_isoc_maxburst_show,
> -			f_ss_opts_isoc_maxburst_store);
> -
> -static ssize_t f_ss_opts_bulk_buflen_show(struct f_ss_opts *opts, char *page)
> +static ssize_t f_ss_opts_bulk_buflen_show(struct config_item *item, char *page)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -1145,9 +1126,10 @@ static ssize_t f_ss_opts_bulk_buflen_show(struct f_ss_opts *opts, char *page)
>   	return result;
>   }
>
> -static ssize_t f_ss_opts_bulk_buflen_store(struct f_ss_opts *opts,
> +static ssize_t f_ss_opts_bulk_buflen_store(struct config_item *item,
>   					   const char *page, size_t len)
>   {
> +	struct f_ss_opts *opts = to_f_ss_opts(item);
>   	int ret;
>   	u32 num;
>
> @@ -1168,18 +1150,20 @@ end:
>   	return ret;
>   }
>
> -static struct f_ss_opts_attribute f_ss_opts_bulk_buflen =
> -	__CONFIGFS_ATTR(buflen, S_IRUGO | S_IWUSR,
> -			f_ss_opts_bulk_buflen_show,
> -			f_ss_opts_bulk_buflen_store);
> +CONFIGFS_ATTR(f_ss_opts_, pattern);
> +CONFIGFS_ATTR(f_ss_opts_, isoc_interval);
> +CONFIGFS_ATTR(f_ss_opts_, isoc_maxpacket);
> +CONFIGFS_ATTR(f_ss_opts_, isoc_mult);
> +CONFIGFS_ATTR(f_ss_opts_, isoc_maxburst);
> +CONFIGFS_ATTR(f_ss_opts_, bulk_buflen);
>
>   static struct configfs_attribute *ss_attrs[] = {
> -	&f_ss_opts_pattern.attr,
> -	&f_ss_opts_isoc_interval.attr,
> -	&f_ss_opts_isoc_maxpacket.attr,
> -	&f_ss_opts_isoc_mult.attr,
> -	&f_ss_opts_isoc_maxburst.attr,
> -	&f_ss_opts_bulk_buflen.attr,
> +	&f_ss_opts_attr_pattern,
> +	&f_ss_opts_attr_isoc_interval,
> +	&f_ss_opts_attr_isoc_maxpacket,
> +	&f_ss_opts_attr_isoc_mult,
> +	&f_ss_opts_attr_isoc_maxburst,
> +	&f_ss_opts_attr_bulk_buflen,
>   	NULL,
>   };
>
>
