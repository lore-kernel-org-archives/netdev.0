From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 09/23] usb-gadget/f_printer: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 13:50:53 +0200
Message-ID: <5609299D.7090302@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-10-git-send-email-hch@lst.de>
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
Return-path: <target-devel-owner@vger.kernel.org>
In-reply-to: <1443189000-13398-10-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Christoph,

The same remark as for f_loopback (__CONFIGFS_ATTR location vs
CONFIGFS_ATTR location after applying)

If addressed

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>   drivers/usb/gadget/function/f_printer.c | 31 ++++++++++++-------------------
>   1 file changed, 12 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_printer.c b/drivers/usb/gadget/function/f_printer.c
> index 8e2b6be..29c90d5 100644
> --- a/drivers/usb/gadget/function/f_printer.c
> +++ b/drivers/usb/gadget/function/f_printer.c
> @@ -1148,9 +1148,6 @@ static inline struct f_printer_opts
>   			    func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_printer_opts);
> -CONFIGFS_ATTR_OPS(f_printer_opts);
> -
>   static void printer_attr_release(struct config_item *item)
>   {
>   	struct f_printer_opts *opts = to_f_printer_opts(item);
> @@ -1160,13 +1157,12 @@ static void printer_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations printer_item_ops = {
>   	.release	= printer_attr_release,
> -	.show_attribute	= f_printer_opts_attr_show,
> -	.store_attribute = f_printer_opts_attr_store,
>   };
>
> -static ssize_t f_printer_opts_pnp_string_show(struct f_printer_opts *opts,
> +static ssize_t f_printer_opts_pnp_string_show(struct config_item *item,
>   					      char *page)
>   {
> +	struct f_printer_opts *opts = to_f_printer_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -1176,9 +1172,10 @@ static ssize_t f_printer_opts_pnp_string_show(struct f_printer_opts *opts,
>   	return result;
>   }
>
> -static ssize_t f_printer_opts_pnp_string_store(struct f_printer_opts *opts,
> +static ssize_t f_printer_opts_pnp_string_store(struct config_item *item,
>   					       const char *page, size_t len)
>   {
> +	struct f_printer_opts *opts = to_f_printer_opts(item);
>   	int result, l;
>
>   	mutex_lock(&opts->lock);
> @@ -1191,14 +1188,10 @@ static ssize_t f_printer_opts_pnp_string_store(struct f_printer_opts *opts,
>   	return result;
>   }
>
> -static struct f_printer_opts_attribute f_printer_opts_pnp_string =
> -	__CONFIGFS_ATTR(pnp_string, S_IRUGO | S_IWUSR,
> -			f_printer_opts_pnp_string_show,
> -			f_printer_opts_pnp_string_store);
> -
> -static ssize_t f_printer_opts_q_len_show(struct f_printer_opts *opts,
> +static ssize_t f_printer_opts_q_len_show(struct config_item *item,
>   					 char *page)
>   {
> +	struct f_printer_opts *opts = to_f_printer_opts(item);
>   	int result;
>
>   	mutex_lock(&opts->lock);
> @@ -1208,9 +1201,10 @@ static ssize_t f_printer_opts_q_len_show(struct f_printer_opts *opts,
>   	return result;
>   }
>
> -static ssize_t f_printer_opts_q_len_store(struct f_printer_opts *opts,
> +static ssize_t f_printer_opts_q_len_store(struct config_item *item,
>   					  const char *page, size_t len)
>   {
> +	struct f_printer_opts *opts = to_f_printer_opts(item);
>   	int ret;
>   	u16 num;
>
> @@ -1231,13 +1225,12 @@ end:
>   	return ret;
>   }
>
> -static struct f_printer_opts_attribute f_printer_opts_q_len =
> -	__CONFIGFS_ATTR(q_len, S_IRUGO | S_IWUSR, f_printer_opts_q_len_show,
> -			f_printer_opts_q_len_store);
> +CONFIGFS_ATTR(f_printer_opts_, pnp_string);
> +CONFIGFS_ATTR(f_printer_opts_, q_len);
>
>   static struct configfs_attribute *printer_attrs[] = {
> -	&f_printer_opts_pnp_string.attr,
> -	&f_printer_opts_q_len.attr,
> +	&f_printer_opts_attr_pnp_string,
> +	&f_printer_opts_attr_q_len,
>   	NULL,
>   };
>
>
