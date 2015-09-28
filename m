From: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Subject: Re: [PATCH 16/23] usb-gadget/f_serial: use per-attribute show and
 store methods
Date: Mon, 28 Sep 2015 13:59:21 +0200
Message-ID: <56092B99.60501@samsung.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
 <1443189000-13398-17-git-send-email-hch@lst.de>
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
In-reply-to: <1443189000-13398-17-git-send-email-hch@lst.de>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 25.09.2015 o 15:49, Christoph Hellwig pisze:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: Andrzej Pietrasiewicz <andrzej.p@samsung.com>

> ---
>   drivers/usb/gadget/function/f_serial.c | 26 ++++----------------------
>   1 file changed, 4 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/usb/gadget/function/f_serial.c b/drivers/usb/gadget/function/f_serial.c
> index 1d162e2..ec837f4 100644
> --- a/drivers/usb/gadget/function/f_serial.c
> +++ b/drivers/usb/gadget/function/f_serial.c
> @@ -266,22 +266,6 @@ static inline struct f_serial_opts *to_f_serial_opts(struct config_item *item)
>   			    func_inst.group);
>   }
>
> -CONFIGFS_ATTR_STRUCT(f_serial_opts);
> -static ssize_t f_serial_attr_show(struct config_item *item,
> -				  struct configfs_attribute *attr,
> -				  char *page)
> -{
> -	struct f_serial_opts *opts = to_f_serial_opts(item);
> -	struct f_serial_opts_attribute *f_serial_opts_attr =
> -		container_of(attr, struct f_serial_opts_attribute, attr);
> -	ssize_t ret = 0;
> -
> -	if (f_serial_opts_attr->show)
> -		ret = f_serial_opts_attr->show(opts, page);
> -
> -	return ret;
> -}
> -
>   static void serial_attr_release(struct config_item *item)
>   {
>   	struct f_serial_opts *opts = to_f_serial_opts(item);
> @@ -291,19 +275,17 @@ static void serial_attr_release(struct config_item *item)
>
>   static struct configfs_item_operations serial_item_ops = {
>   	.release	= serial_attr_release,
> -	.show_attribute = f_serial_attr_show,
>   };
>
> -static ssize_t f_serial_port_num_show(struct f_serial_opts *opts, char *page)
> +static ssize_t f_serial_port_num_show(struct config_item *item, char *page)
>   {
> -	return sprintf(page, "%u\n", opts->port_num);
> +	return sprintf(page, "%u\n", to_f_serial_opts(item)->port_num);
>   }
>
> -static struct f_serial_opts_attribute f_serial_port_num =
> -	__CONFIGFS_ATTR_RO(port_num, f_serial_port_num_show);
> +CONFIGFS_ATTR_RO(f_serial_, port_num);
>
>   static struct configfs_attribute *acm_attrs[] = {
> -	&f_serial_port_num.attr,
> +	&f_serial_attr_port_num,
>   	NULL,
>   };
>
>
