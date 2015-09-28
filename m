From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 15/23] usb-gadget/f_phonet: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 13:59:03 +0200
Message-ID: <56092B87.5010002@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-16-git-send-email-hch@lst.de>
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
In-reply-to: <1443189000-13398-16-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

> ---
>   drivers/usb/gadget/function/f_phonet.c | 25 ++++---------------------
>   1 file changed, 4 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_phonet.c b/drivers/usb/gadget/function/f_phonet.c
> index c0c3ef2..c029ef6 100644
> --- a/drivers/usb/gadget/function/f_phonet.c
> +++ b/drivers/usb/gadget/function/f_phonet.c
> @@ -589,21 +589,6 @@ static inline struct f_phonet_opts *to_f_phonet_opts(struct config_item *item)
>   			func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_phonet_opts);
> -static ssize_t f_phonet_attr_show(struct config_item *item,
> -				struct configfs_attribute *attr,
> -				char *page)
> -{
> -	struct f_phonet_opts *opts = to_f_phonet_opts(item);
> -	struct f_phonet_opts_attribute *f_phonet_opts_attr =
> -		container_of(attr, struct f_phonet_opts_attribute, attr);
> -	ssize_t ret = 0;
> -
> -	if (f_phonet_opts_attr->show)
> -		ret = f_phonet_opts_attr->show(opts, page);
> -	return ret;
> -}
> -
>   static void phonet_attr_release(struct config_item *item)
>   {
>   	struct f_phonet_opts *opts = to_f_phonet_opts(item);
> @@ -613,19 +598,17 @@ static void phonet_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations phonet_item_ops = {
>   	.release		= phonet_attr_release,
> -	.show_attribute		= f_phonet_attr_show,
>   };
>
> -static ssize_t f_phonet_ifname_show(struct f_phonet_opts *opts, char *page)
> +static ssize_t f_phonet_ifname_show(struct config_item *item, char *page)
>   {
> -	return gether_get_ifname(opts->net, page, PAGE_SIZE);
> +	return gether_get_ifname(to_f_phonet_opts(item)->net, page, PAGE_SIZE);
>   }
>
> -static struct f_phonet_opts_attribute f_phonet_ifname =
> -	__CONFIGFS_ATTR_RO(ifname, f_phonet_ifname_show);
> +CONFIGFS_ATTR_RO(f_phonet_, ifname);
>
>   static struct configfs_attribute *phonet_attrs[] = {
> -	&f_phonet_ifname.attr,
> +	&f_phonet_attr_ifname,
>   	NULL,
>   };
>
>
