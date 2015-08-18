From: Alexey Klimov <klimov.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/5] net: add Hisilicon Network Subsystem hnae framework support
Date: Tue, 18 Aug 2015 03:12:02 +0300
Message-ID: <CALW4P+J8LkLshu5TuRT+8c__KRwJ8XAdMV4yA0KEnrfUg=mNow@mail.gmail.com>
References: <1439548222-231611-1-git-send-email-liguozhu@hisilicon.com>
	<1439548222-231611-3-git-send-email-liguozhu@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, Kenneth Lee <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Yury Norov <yury.norov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1439548222-231611-3-git-send-email-liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kenneth,

just small minor question.

On Fri, Aug 14, 2015 at 1:30 PM, Kenneth Lee <liguozhu-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org> wrote:
> HNAE (Hisilicon Network Acceleration Engine) is a framework to provide a
> unified ring buffer interface for Hisilicon Network Acceleration Engines.
>
> With the interface, upper layer can work as ethernet driver, ODP driver or
> other service driver on purpose.
>
> Signed-off-by: Kenneth Lee <liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Yisen Zhuang <Yisen.Zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/hisilicon/Kconfig      |  33 +-
>  drivers/net/ethernet/hisilicon/Makefile     |   1 +
>  drivers/net/ethernet/hisilicon/hns/Makefile |  15 +
>  drivers/net/ethernet/hisilicon/hns/hnae.c   | 494 +++++++++++++++++++++++
>  drivers/net/ethernet/hisilicon/hns/hnae.h   | 582 ++++++++++++++++++++++++++++
>  5 files changed, 1124 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/net/ethernet/hisilicon/hns/Makefile
>  create mode 100644 drivers/net/ethernet/hisilicon/hns/hnae.c
>  create mode 100644 drivers/net/ethernet/hisilicon/hns/hnae.h
>
> diff --git a/drivers/net/ethernet/hisilicon/Kconfig b/drivers/net/ethernet/hisilicon/Kconfig
> index dead17b..1e4f5a7 100644
> --- a/drivers/net/ethernet/hisilicon/Kconfig
> +++ b/drivers/net/ethernet/hisilicon/Kconfig
> @@ -5,7 +5,7 @@
>  config NET_VENDOR_HISILICON
>         bool "Hisilicon devices"
>         default y
> -       depends on ARM
> +       depends on ARM || ARM64
>         ---help---
>           If you have a network (Ethernet) card belonging to this class, say Y.
>
> @@ -31,4 +31,35 @@ config HIP04_ETH
>           If you wish to compile a kernel for a hardware with hisilicon p04 SoC and
>           want to use the internal ethernet then you should answer Y to this.
>
> +config HNS
> +       tristate "Hisilicon Network Subsystem Support (Framework)"
> +       ---help---
> +         This selects the framework support for Hisilicon Network Subsystem. It
> +         is needed by any driver which provides HNS acceleration engine or make
> +         use of the engine
> +
> +config HNS_DSAF
> +       tristate "Hisilicon HNS DSAF device Support"
> +       select HNS
> +       select HNS_MDIO
> +       ---help---
> +         This selects the DSAF (Distributed System Area Frabric) network
> +         acceleration engine support. The engine is used in Hisilicon P660,
> +         Hi1610 and further ICT SoC
> +
> +config HNS_MDIO
> +       tristate "Hisilicon HNS MDIO device Support"
> +       select MDIO
> +       ---help---
> +         This selects the HNS MDIO support. It is needed by HNS_DSAF to access
> +         the PHY
> +
> +config HNS_ENET
> +       tristate "Hisilicon HNS Ethernet Device Support"
> +       select PHYLIB
> +       select HNS
> +       ---help---
> +         This selects the general ethernet driver for HNS.  This module make
> +         use of any HNS AE driver, such as HNS_DSAF
> +
>  endif # NET_VENDOR_HISILICON
> diff --git a/drivers/net/ethernet/hisilicon/Makefile b/drivers/net/ethernet/hisilicon/Makefile
> index 6c14540..2503a9b 100644
> --- a/drivers/net/ethernet/hisilicon/Makefile
> +++ b/drivers/net/ethernet/hisilicon/Makefile
> @@ -4,3 +4,4 @@
>
>  obj-$(CONFIG_HIX5HD2_GMAC) += hix5hd2_gmac.o
>  obj-$(CONFIG_HIP04_ETH) += hip04_mdio.o hip04_eth.o
> +obj-$(CONFIG_HNS) += hns/
> diff --git a/drivers/net/ethernet/hisilicon/hns/Makefile b/drivers/net/ethernet/hisilicon/hns/Makefile
> new file mode 100644
> index 0000000..6680602
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns/Makefile
> @@ -0,0 +1,15 @@
> +#
> +# Makefile for the HISILICON network device drivers.
> +#
> +
> +obj-$(CONFIG_HNS) += hnae.o
> +
> +obj-$(CONFIG_HNS_DSAF) += hns_dsaf.o
> +hns_dsaf-objs = hns_ae_adapt.o hns_dsaf_gmac.o hns_dsaf_mac.o hns_dsaf_misc.o \
> +       hns_dsaf_main.o hns_dsaf_ppe.o hns_dsaf_rcb.o hns_dsaf_xgmac.o
> +
> +obj-$(CONFIG_HNS_MDIO) += hns_mdio.o
> +hns_mdio-objs = hns_mdio_main.o
> +
> +obj-$(CONFIG_HNS_ENET) += hns_enet_drv.o
> +hns_enet_drv-objs = hns_enet.o hns_ethtool.o
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.c b/drivers/net/ethernet/hisilicon/hns/hnae.c
> new file mode 100644
> index 0000000..fd09768
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.c
> @@ -0,0 +1,494 @@
> +/*
> + * Copyright (c) 2014-2015 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/dma-mapping.h>
> +#include <linux/interrupt.h>
> +#include <linux/skbuff.h>
> +#include <linux/slab.h>
> +
> +#include "hnae.h"
> +
> +#define cls_to_ae_dev(dev) container_of(dev, struct hnae_ae_dev, cls_dev)
> +
> +static struct class *hnae_class;
> +
> +static inline void hnae_list_add(spinlock_t *lock, struct list_head *node,
> +                                struct list_head *head)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(lock, flags);
> +       list_add_tail_rcu(node, head);
> +       spin_unlock_irqrestore(lock, flags);
> +}
> +
> +static inline void hnae_list_del(spinlock_t *lock, struct list_head *node)
> +{
> +       unsigned long flags;
> +
> +       spin_lock_irqsave(lock, flags);
> +       list_del_rcu(node);
> +       spin_unlock_irqrestore(lock, flags);
> +}
> +
> +static int hnae_alloc_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
> +{
> +       unsigned int order = hnae_page_order(ring);
> +       struct page *p = dev_alloc_pages(order);
> +
> +       if (!p)
> +               return -ENOMEM;
> +
> +       cb->priv = p;
> +       cb->page_offset = 0;
> +       cb->reuse_flag = 0;
> +       cb->buf  = page_address(p);
> +       cb->length = hnae_page_size(ring);
> +       cb->type = DESC_TYPE_PAGE;
> +
> +       return 0;
> +}
> +
> +static void hnae_free_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
> +{
> +       if (cb->type == DESC_TYPE_SKB)
> +               dev_kfree_skb_any((struct sk_buff *)cb->priv);
> +       else if (unlikely(is_rx_ring(ring)))
> +               put_page((struct page *)cb->priv);
> +       memset(cb, 0, sizeof(*cb));
> +}
> +
> +static int hnae_map_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
> +{
> +       cb->dma = dma_map_page(ring_to_dev(ring), cb->priv, 0,
> +                              cb->length, ring_to_dma_dir(ring));
> +
> +       if (dma_mapping_error(ring_to_dev(ring), cb->dma))
> +               return -EIO;
> +
> +       return 0;
> +}
> +
> +static void hnae_unmap_buffer(struct hnae_ring *ring, struct hnae_desc_cb *cb)
> +{
> +       if (cb->type == DESC_TYPE_SKB)
> +               dma_unmap_single(ring_to_dev(ring), cb->dma, cb->length,
> +                                ring_to_dma_dir(ring));
> +       else
> +               dma_unmap_page(ring_to_dev(ring), cb->dma, cb->length,
> +                              ring_to_dma_dir(ring));
> +}
> +
> +static struct hnae_buf_ops hnae_bops = {
> +       .alloc_buffer = hnae_alloc_buffer,
> +       .free_buffer = hnae_free_buffer,
> +       .map_buffer = hnae_map_buffer,
> +       .unmap_buffer = hnae_unmap_buffer,
> +};
> +
> +static int __ae_match(struct device *dev, const void *data)
> +{
> +       struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
> +       const char *ae_id = data;
> +
> +       if (!strncmp(ae_id, hdev->name, AE_NAME_SIZE))
> +               return 1;
> +
> +       return 0;
> +}
> +
> +static struct hnae_ae_dev *find_ae(const char *ae_id)
> +{
> +       struct device *dev;
> +
> +       BUG_ON(!ae_id);
> +
> +       dev = class_find_device(hnae_class, NULL, ae_id, __ae_match);
> +
> +       return cls_to_ae_dev(dev);
> +}

Most entries of class_find_device() in kernel that i see perform
if-check for NULL on return value.
What do you think about such option for example:
return dev ? cls_to_ae_dev(dev) : NULL;
?

Is it possible that, someday, your dev will be NULL and creep in
container_of() that doesn't protected from ptr = NULL
and .... (let's go down a little in another function)

> +
> +static void hnae_free_buffers(struct hnae_ring *ring)
> +{
> +       int i;
> +
> +       for (i = 0; i < ring->desc_num; i++)
> +               hnae_free_buffer_detach(ring, i);
> +}
> +
> +/* Allocate memory for raw pkg, and map with dma */
> +static int hnae_alloc_buffers(struct hnae_ring *ring)
> +{
> +       int i, j, ret;
> +
> +       for (i = 0; i < ring->desc_num; i++) {
> +               ret = hnae_alloc_buffer_attach(ring, i);
> +               if (ret)
> +                       goto out_buffer_fail;
> +       }
> +
> +       return 0;
> +
> +out_buffer_fail:
> +       for (j = i - 1; j >= 0; j--)
> +               hnae_free_buffer_detach(ring, j);
> +       return ret;
> +}
> +
> +/* free desc along with its attached buffer */
> +static inline void hnae_free_desc(struct hnae_ring *ring)
> +{
> +       hnae_free_buffers(ring);
> +       dma_unmap_single(ring_to_dev(ring), ring->desc_dma_addr,
> +                        ring->desc_num * sizeof(ring->desc[0]),
> +                        ring_to_dma_dir(ring));
> +       ring->desc_dma_addr = 0;
> +       kfree(ring->desc);
> +       ring->desc = NULL;
> +}
> +
> +/* alloc desc, without buffer attached */
> +static inline int hnae_alloc_desc(struct hnae_ring *ring)
> +{
> +       int size = ring->desc_num * sizeof(ring->desc[0]);
> +
> +       ring->desc = kzalloc(size, GFP_KERNEL);
> +       if (!ring->desc)
> +               return -ENOMEM;
> +
> +       ring->desc_dma_addr = dma_map_single(ring_to_dev(ring),
> +               ring->desc, size, ring_to_dma_dir(ring));
> +       if (dma_mapping_error(ring_to_dev(ring), ring->desc_dma_addr)) {
> +               ring->desc_dma_addr = 0;
> +               kfree(ring->desc);
> +               ring->desc = NULL;
> +               return -ENOMEM;
> +       }
> +
> +       return 0;
> +}
> +
> +/* fini ring, also free the buffer for the ring */
> +static inline void hnae_fini_ring(struct hnae_ring *ring)
> +{
> +       hnae_free_desc(ring);
> +       kfree(ring->desc_cb);
> +       ring->desc_cb = NULL;
> +       ring->next_to_clean = 0;
> +       ring->next_to_use = 0;
> +}
> +
> +/* init ring, and with buffer for rx ring */
> +static inline int hnae_init_ring(struct hnae_queue *q, struct hnae_ring *ring,
> +                                int flags)
> +{
> +       int ret;
> +
> +       if (ring->desc_num <= 0 || ring->buf_size <= 0)
> +               return -EINVAL;
> +
> +       ring->q = q;
> +       ring->flags = flags;
> +       assert(!ring->desc && !ring->desc_cb && !ring->desc_dma_addr);
> +
> +       /* not matter for tx or rx ring, the ntc and ntc start from 0 */
> +       assert(ring->next_to_use == 0);
> +       assert(ring->next_to_clean == 0);
> +
> +       ring->desc_cb = kcalloc(ring->desc_num, sizeof(ring->desc_cb[0]),
> +                       GFP_KERNEL);
> +       if (!ring->desc_cb) {
> +               ret = -ENOMEM;
> +               goto out;
> +       }
> +
> +       ret = hnae_alloc_desc(ring);
> +       if (ret)
> +               goto out_with_desc_cb;
> +
> +       if (is_rx_ring(ring)) {
> +               ret = hnae_alloc_buffers(ring);
> +               if (ret)
> +                       goto out_with_desc;
> +       }
> +
> +       return 0;
> +
> +out_with_desc:
> +       hnae_free_desc(ring);
> +out_with_desc_cb:
> +       kfree(ring->desc_cb);
> +       ring->desc_cb = NULL;
> +out:
> +       return ret;
> +}
> +
> +static inline int hnae_init_queue(struct hnae_handle *h, struct hnae_queue *q,
> +                                 struct hnae_ae_dev *dev)
> +{
> +       int ret;
> +
> +       q->dev = dev;
> +       q->handle = h;
> +
> +       ret = hnae_init_ring(q, &q->tx_ring, q->tx_ring.flags | RINGF_DIR);
> +       if (ret)
> +               goto out;
> +
> +       ret = hnae_init_ring(q, &q->rx_ring, q->rx_ring.flags & ~RINGF_DIR);
> +       if (ret)
> +               goto out_with_tx_ring;
> +
> +       if (dev->ops->init_queue)
> +               dev->ops->init_queue(q);
> +
> +       return 0;
> +
> +out_with_tx_ring:
> +       hnae_fini_ring(&q->tx_ring);
> +out:
> +       return ret;
> +}
> +
> +static inline void hnae_fini_queue(struct hnae_queue *q)
> +{
> +       if (q->dev->ops->fini_queue)
> +               q->dev->ops->fini_queue(q);
> +
> +       hnae_fini_ring(&q->tx_ring);
> +       hnae_fini_ring(&q->rx_ring);
> +}
> +
> +/**
> + * ae_chain - define ae chain head
> + */
> +static RAW_NOTIFIER_HEAD(ae_chain);
> +
> +int hnae_register_notifier(struct notifier_block *nb)
> +{
> +       return raw_notifier_chain_register(&ae_chain, nb);
> +}
> +EXPORT_SYMBOL(hnae_register_notifier);
> +
> +void hnae_unregister_notifier(struct notifier_block *nb)
> +{
> +       if (raw_notifier_chain_unregister(&ae_chain, nb))
> +               dev_err(NULL, "notifier chain unregister fail\n");
> +}
> +EXPORT_SYMBOL(hnae_unregister_notifier);
> +
> +int hnae_reinit_handle(struct hnae_handle *handle)
> +{
> +       int i, j;
> +       int ret;
> +
> +       for (i = 0; i < handle->q_num; i++) /* free ring*/
> +               hnae_fini_queue(handle->qs[i]);
> +
> +       for (i = 0; i < handle->q_num; i++) {/* reinit ring*/
> +               ret = hnae_init_queue(handle, handle->qs[i], handle->dev);
> +               if (ret)
> +                       goto out_when_init_queue;
> +       }
> +       return 0;
> +out_when_init_queue:
> +       for (j = i - 1; j >= 0; j--)
> +               hnae_fini_queue(handle->qs[j]);
> +       return ret;
> +}
> +EXPORT_SYMBOL(hnae_reinit_handle);
> +
> +/* hnae_get_handle - get a handle from the AE
> + * @owner_dev: the dev use this handle
> + * @ae_id: the id of the ae to be used
> + * @ae_opts: the options set for the handle
> + * @bops: the callbacks for buffer management
> + *
> + * return handle ptr or ERR_PTR
> + */
> +struct hnae_handle *hnae_get_handle(struct device *owner_dev,
> +                                   const char *ae_id, const char *ae_opts,
> +                                   struct hnae_buf_ops *bops)
> +{
> +       struct hnae_ae_dev *dev;
> +       struct hnae_handle *handle;
> +       int i, j;
> +       int ret;
> +
> +       dev = find_ae(ae_id);
> +       if (!dev)
> +               return ERR_PTR(-ENODEV);

.. and here you might not receive NULL after container_of() works on
that returned NULL after class_find_device().
I guess that might happen after someone change order of fields in
struct hnae_ae_dev.

I understand that it's unlikely to happen but could you please check or comment?


> +
> +       handle = dev->ops->get_handle(dev, ae_opts);
> +       if (IS_ERR(handle))
> +               return handle;
> +
> +       handle->dev = dev;
> +       handle->owner_dev = owner_dev;
> +       handle->bops = bops ? bops : &hnae_bops;
> +       handle->ae_opts = ae_opts;
> +
> +       for (i = 0; i < handle->q_num; i++) {
> +               ret = hnae_init_queue(handle, handle->qs[i], dev);
> +               if (ret)
> +                       goto out_when_init_queue;
> +       }
> +
> +       __module_get(dev->owner);
> +
> +       hnae_list_add(&dev->lock, &handle->node, &dev->handle_list);
> +
> +       return handle;
> +
> +out_when_init_queue:
> +       for (j = i - 1; j >= 0; j--)
> +               hnae_fini_queue(handle->qs[j]);
> +
> +       return ERR_PTR(-ENOMEM);
> +}
> +EXPORT_SYMBOL(hnae_get_handle);
> +
> +void hnae_put_handle(struct hnae_handle *h)
> +{
> +       struct hnae_ae_dev *dev = h->dev;
> +       int i;
> +
> +       for (i = 0; i < h->q_num; i++)
> +               hnae_fini_queue(h->qs[i]);
> +
> +       hnae_list_del(&dev->lock, &h->node);
> +
> +       if (dev->ops->put_handle)
> +               dev->ops->put_handle(h);
> +
> +       module_put(dev->owner);
> +}
> +EXPORT_SYMBOL(hnae_put_handle);
> +
> +static void __hnae_release(struct device *dev)
> +{
> +}
> +
> +/**
> + * hnae_ae_register - register a AE engine to hnae framework
> + * @hdev: the hnae ae engine device
> + * @owner:  the module who provides this dev
> + * NOTE: the duplicated name will not be checked
> + */
> +int hnae_ae_register(struct hnae_ae_dev *hdev, struct module *owner)
> +{
> +       static atomic_t id = ATOMIC_INIT(-1);
> +       int ret;
> +
> +       if (!hdev->dev)
> +               return -ENODEV;
> +
> +       if (!hdev->ops || !hdev->ops->get_handle ||
> +           !hdev->ops->toggle_ring_irq ||
> +           !hdev->ops->toggle_queue_status ||
> +           !hdev->ops->get_status || !hdev->ops->adjust_link)
> +               return -EINVAL;
> +
> +       hdev->owner = owner;
> +       hdev->id = (int)atomic_inc_return(&id);
> +       hdev->cls_dev.parent = hdev->dev;
> +       hdev->cls_dev.class = hnae_class;
> +       hdev->cls_dev.release = __hnae_release;
> +       dev_set_name(&hdev->cls_dev, "hnae%d", hdev->id);
> +       ret = device_register(&hdev->cls_dev);
> +       if (ret)
> +               return ret;
> +
> +       __module_get(THIS_MODULE);
> +
> +       INIT_LIST_HEAD(&hdev->handle_list);
> +       spin_lock_init(&hdev->lock);
> +
> +       ret = raw_notifier_call_chain(&ae_chain, HNAE_AE_REGISTER, NULL);
> +       if (ret)
> +               dev_dbg(hdev->dev,
> +                       "has not notifier for AE: %s\n", hdev->name);
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(hnae_ae_register);
> +
> +/**
> + * hnae_ae_unregister - unregisters a HNAE AE engine
> + * @cdev: the device to unregister
> + */
> +void hnae_ae_unregister(struct hnae_ae_dev *hdev)
> +{
> +       device_unregister(&hdev->cls_dev);
> +       module_put(THIS_MODULE);
> +}
> +EXPORT_SYMBOL(hnae_ae_unregister);
> +
> +static ssize_t handles_show(struct device *dev,
> +                           struct device_attribute *attr, char *buf)
> +{
> +       ssize_t s = 0;
> +       struct hnae_ae_dev *hdev = cls_to_ae_dev(dev);
> +       struct hnae_handle *h;
> +       int i = 0, j;
> +
> +       list_for_each_entry_rcu(h, &hdev->handle_list, node) {
> +               s += sprintf(buf + s, "%s(%s): ", dev_name(h->owner_dev),
> +                            h->ae_opts);
> +               for (j = 0; j < h->q_num; j++) {
> +                       if (h->qs[i]) {
> +                               s += sprintf(buf + s,
> +                                       "(%llu,%llu; ",
> +                                       h->qs[i]->tx_ring.stats.sw_err_cnt,
> +                                       h->qs[i]->tx_ring.stats.io_err_cnt);
> +                               s += sprintf(buf + s,
> +                                       "%llu,%llu,%llu), ",
> +                                       h->qs[i]->rx_ring.stats.sw_err_cnt,
> +                                       h->qs[i]->rx_ring.stats.io_err_cnt,
> +                                       h->qs[i]->rx_ring.stats.seg_pkt_cnt);
> +                       } else {
> +                               s += sprintf(buf + s, "(null)\n");
> +                       }
> +               }
> +               s += sprintf(buf + s, "\n");
> +       }
> +
> +       return s;
> +}
> +
> +static DEVICE_ATTR_RO(handles);
> +static struct attribute *hnae_class_attrs[] = {
> +       &dev_attr_handles.attr,
> +       NULL,
> +};
> +ATTRIBUTE_GROUPS(hnae_class);
> +
> +static int __init hnae_init(void)
> +{
> +       hnae_class = class_create(THIS_MODULE, "hnae");
> +       if (IS_ERR(hnae_class))
> +               return PTR_ERR(hnae_class);
> +
> +       hnae_class->dev_groups = hnae_class_groups;
> +       return 0;
> +}
> +
> +static void __exit hnae_exit(void)
> +{
> +       class_destroy(hnae_class);
> +}
> +
> +subsys_initcall(hnae_init);
> +module_exit(hnae_exit);
> +
> +MODULE_AUTHOR("Hisilicon, Inc.");
> +MODULE_LICENSE("GPL");
> +MODULE_DESCRIPTION("Hisilicon Network Acceleration Engine Framework");
> +
> +/* vi: set tw=78 noet: */
> diff --git a/drivers/net/ethernet/hisilicon/hns/hnae.h b/drivers/net/ethernet/hisilicon/hns/hnae.h
> new file mode 100644
> index 0000000..e7856cf
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns/hnae.h
> @@ -0,0 +1,582 @@
> +/*
> + * Copyright (c) 2014-2015 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#ifndef __HNAE_H
> +#define __HNAE_H
> +
> +/* Names used in this framework:
> + *      ae handle (handle):
> + *        a set of queues provided by AE
> + *      ring buffer queue (rbq):
> + *        the channel between upper layer and the AE, can do tx and rx
> + *      ring:
> + *        a tx or rx channel within a rbq
> + *      ring description (desc):
> + *        an element in the ring with packet information
> + *      buffer:
> + *        a memory region referred by desc with the full packet payload
> + *
> + * "num" means a static number set as a parameter, "count" mean a dynamic
> + *   number set while running
> + * "cb" means control block
> + */
> +
> +#include <linux/delay.h>
> +#include <linux/device.h>
> +#include <linux/module.h>
> +#include <linux/netdevice.h>
> +#include <linux/notifier.h>
> +#include <linux/types.h>
> +
> +#define HNAE_DRIVER_VERSION "1.1.0"
> +#define HNAE_DRIVER_NAME "hns"
> +#define HNAE_COPYRIGHT "Copyright(c) 2015 Huawei Corporation."
> +#define HNAE_DRIVER_STRING "Hisilicon Network Subsystem Driver"
> +#define HNAE_DEFAULT_DEVICE_DESCR "Hisilicon Network Subsystem"
> +
> +#ifdef DEBUG
> +
> +#ifndef assert
> +#define assert(expr) \
> +do { \
> +       if (!(expr)) { \
> +               pr_err("Assertion failed! %s, %s, %s, line %d\n", \
> +                          #expr, __FILE__, __func__, __LINE__); \
> +       } \
> +} while (0)
> +#endif
> +
> +#else
> +
> +#ifndef assert
> +#define assert(expr)
> +#endif
> +
> +#endif
> +
> +#define AE_NAME_SIZE 16
> +#define AE_OPTS_SIZE 64
> +
> +/* some said the RX and TX RCB format should not be the same in the future. But
> + * it is the same now...
> + */
> +#define RCB_REG_BASEADDR_L         0x00 /* P660 support only 32bit accessing */
> +#define RCB_REG_BASEADDR_H         0x04
> +#define RCB_REG_BD_NUM             0x08
> +#define RCB_REG_BD_LEN             0x0C
> +#define RCB_REG_PKTLINE            0x10
> +#define RCB_REG_TAIL               0x18
> +#define RCB_REG_HEAD               0x1C
> +#define RCB_REG_FBDNUM             0x20
> +#define RCB_REG_OFFSET             0x24 /* pkt num to be handled */
> +#define RCB_REG_PKTNUM_RECORD      0x2C /* total pkt received */
> +
> +#define HNS_RX_HEAD_SIZE 256
> +
> +#define HNAE_AE_REGISTER 0x1
> +
> +#define RCB_RING_NAME_LEN 16
> +
> +enum hnae_led_state {
> +       HNAE_LED_INACTIVE,
> +       HNAE_LED_ACTIVE,
> +       HNAE_LED_ON,
> +       HNAE_LED_OFF
> +};
> +
> +#define HNS_RX_FLAG_VLAN_PRESENT 0x1
> +#define HNS_RX_FLAG_L3ID_IPV4 0x0
> +#define HNS_RX_FLAG_L3ID_IPV6 0x1
> +#define HNS_RX_FLAG_L4ID_UDP 0x0
> +#define HNS_RX_FLAG_L4ID_TCP 0x1
> +
> +#define HNS_TXD_ASID_S 0
> +#define HNS_TXD_ASID_M (0xff << HNS_TXD_ASID_S)
> +#define HNS_TXD_BUFNUM_S 8
> +#define HNS_TXD_BUFNUM_M (0x3 << HNS_TXD_BUFNUM_S)
> +#define HNS_TXD_PORTID_S 10
> +#define HNS_TXD_PORTID_M (0x7 << HNS_TXD_PORTID_S)
> +
> +#define HNS_TXD_RA_B 8
> +#define HNS_TXD_RI_B 9
> +#define HNS_TXD_L4CS_B 10
> +#define HNS_TXD_L3CS_B 11
> +#define HNS_TXD_FE_B 12
> +#define HNS_TXD_VLD_B 13
> +#define HNS_TXD_IPOFFSET_S 14
> +#define HNS_TXD_IPOFFSET_M (0xff << HNS_TXD_IPOFFSET_S)
> +
> +#define HNS_RXD_IPOFFSET_S 0
> +#define HNS_RXD_IPOFFSET_M (0xff << HNS_TXD_IPOFFSET_S)
> +#define HNS_RXD_BUFNUM_S 8
> +#define HNS_RXD_BUFNUM_M (0x3 << HNS_RXD_BUFNUM_S)
> +#define HNS_RXD_PORTID_S 10
> +#define HNS_RXD_PORTID_M (0x7 << HNS_RXD_PORTID_S)
> +#define HNS_RXD_DMAC_S 13
> +#define HNS_RXD_DMAC_M (0x3 << HNS_RXD_DMAC_S)
> +#define HNS_RXD_VLAN_S 15
> +#define HNS_RXD_VLAN_M (0x3 << HNS_RXD_VLAN_S)
> +#define HNS_RXD_L3ID_S 17
> +#define HNS_RXD_L3ID_M (0xf << HNS_RXD_L3ID_S)
> +#define HNS_RXD_L4ID_S 21
> +#define HNS_RXD_L4ID_M (0xf << HNS_RXD_L4ID_S)
> +#define HNS_RXD_FE_B 25
> +#define HNS_RXD_FRAG_B 26
> +#define HNS_RXD_VLD_B 27
> +#define HNS_RXD_L2E_B 28
> +#define HNS_RXD_L3E_B 29
> +#define HNS_RXD_L4E_B 30
> +#define HNS_RXD_DROP_B 31
> +
> +#define HNS_RXD_VLANID_S 8
> +#define HNS_RXD_VLANID_M (0xfff << HNS_RXD_VLANID_S)
> +#define HNS_RXD_CFI_B 20
> +#define HNS_RXD_PRI_S 21
> +#define HNS_RXD_PRI_M (0x7 << HNS_RXD_PRI_S)
> +#define HNS_RXD_ASID_S 24
> +#define HNS_RXD_ASID_M (0xff << HNS_RXD_ASID_S)
> +
> +/* hardware spec ring buffer format */
> +struct __packed hnae_desc {
> +       __le64 addr;
> +       union {
> +               struct {
> +                       __le16 asid_bufnum_pid;
> +                       __le16 send_size;
> +                       __le32 flag_ipoffset;
> +                       __le32 reserved_3[4];
> +               } tx;
> +
> +               struct {
> +                       __le32 ipoff_bnum_pid_flag;
> +                       __le16 pkt_len;
> +                       __le16 size;
> +                       __le32 vlan_pri_asid;
> +                       __le32 reserved_2[3];
> +               } rx;
> +       };
> +};
> +
> +struct hnae_desc_cb {
> +       dma_addr_t dma; /* dma address of this desc */
> +       void *buf;      /* cpu addr for a desc */
> +
> +       /* priv data for the desc, e.g. skb when use with ip stack*/
> +       void *priv;
> +       u16 page_offset;
> +       u16 reuse_flag;
> +
> +       u16 length;     /* length of the buffer */
> +
> +       /* desc type, used by the ring user to mark the type of the priv data */
> +       u16 type;
> +};
> +
> +#define setflags(flags, bits) ((flags) |= (bits))
> +#define unsetflags(flags, bits) ((flags) &= ~(bits))
> +
> +/* hnae_ring->flags fields */
> +#define RINGF_DIR 0x1      /* TX or RX ring, set if TX */
> +#define is_tx_ring(ring) ((ring)->flags & RINGF_DIR)
> +#define is_rx_ring(ring) (!is_tx_ring(ring))
> +#define ring_to_dma_dir(ring) (is_tx_ring(ring) ? \
> +       DMA_TO_DEVICE : DMA_FROM_DEVICE)
> +
> +struct ring_stats {
> +       u64 io_err_cnt;
> +       u64 sw_err_cnt;
> +       u64 seg_pkt_cnt;
> +       u64 reuse_pg_cnt;
> +       u64 err_pkt_len;
> +       u64 non_vld_descs;
> +       u64 err_bd_num;
> +       u64 csum_err;
> +       union {
> +               u64 tx_pkts;
> +               u64 rx_pkts;
> +       } pkts;
> +       union {
> +               u64 tx_bytes;
> +               u64 rx_bytes;
> +       } bytes;
> +       union {
> +               u64 tx_err_cnt;
> +               u64 rx_err_cnt;
> +       } err_cnt;
> +};
> +
> +struct hnae_queue;
> +
> +struct hnae_ring {
> +       u8 __iomem *io_base; /* base io address for the ring */
> +       struct hnae_desc *desc; /* dma map address space */
> +       struct hnae_desc_cb *desc_cb;
> +       struct hnae_queue *q;
> +       int irq;
> +       char ring_name[RCB_RING_NAME_LEN];
> +
> +       /* statistic */
> +       struct ring_stats stats;
> +
> +       dma_addr_t desc_dma_addr;
> +       u32 buf_size;       /* size for hnae_desc->addr, preset by AE */
> +       u16 desc_num;       /* total number of desc */
> +       u16 max_desc_num_per_pkt;
> +       u16 max_raw_data_sz_per_desc;
> +       u16 max_pkt_size;
> +       int next_to_use;    /* idx of next spare desc */
> +
> +       /* idx of lastest sent desc, the ring is empty when equal to
> +        * next_to_use
> +        */
> +       int next_to_clean;
> +
> +       int flags;          /* ring attribute */
> +};
> +
> +#define ring_ptr_move_fw(ring, p) \
> +       ((ring)->p = ((ring)->p + 1) % (ring)->desc_num)
> +#define ring_ptr_move_bw(ring, p) \
> +       ((ring)->p = ((ring)->p - 1 + (ring)->desc_num) % (ring)->desc_num)
> +
> +enum hns_desc_type {
> +       DESC_TYPE_SKB,
> +       DESC_TYPE_PAGE,
> +};
> +
> +#define assert_is_ring_idx(ring, idx) \
> +       assert((idx) >= 0 && (idx) < (ring)->desc_num)
> +
> +/* the distance between [begin, end) in a ring buffer
> + * note: there is a unuse slot between the begin and the end
> + */
> +static inline int ring_dist(struct hnae_ring *ring, int begin, int end)
> +{
> +       assert_is_ring_idx(ring, begin);
> +       assert_is_ring_idx(ring, end);
> +
> +       return (end - begin + ring->desc_num) % ring->desc_num;
> +}
> +
> +static inline int ring_space(struct hnae_ring *ring)
> +{
> +       return ring->desc_num -
> +               ring_dist(ring, ring->next_to_clean, ring->next_to_use) - 1;
> +}
> +
> +static inline int is_ring_empty(struct hnae_ring *ring)
> +{
> +       assert_is_ring_idx(ring, ring->next_to_use);
> +       assert_is_ring_idx(ring, ring->next_to_clean);
> +
> +       return ring->next_to_use == ring->next_to_clean;
> +}
> +
> +#define hnae_buf_size(_ring) ((_ring)->buf_size)
> +#define hnae_page_order(_ring) (get_order(hnae_buf_size(_ring)))
> +#define hnae_page_size(_ring) (PAGE_SIZE << hnae_page_order(_ring))
> +
> +struct hnae_handle;
> +
> +/* allocate and dma map space for hnae desc */
> +struct hnae_buf_ops {
> +       int (*alloc_buffer)(struct hnae_ring *ring, struct hnae_desc_cb *cb);
> +       void (*free_buffer)(struct hnae_ring *ring, struct hnae_desc_cb *cb);
> +       int (*map_buffer)(struct hnae_ring *ring, struct hnae_desc_cb *cb);
> +       void (*unmap_buffer)(struct hnae_ring *ring, struct hnae_desc_cb *cb);
> +};
> +
> +struct hnae_queue {
> +       void __iomem *io_base;
> +       struct hnae_ae_dev *dev;        /* the device who use this queue */
> +       struct hnae_ring rx_ring, tx_ring;
> +       struct hnae_handle *handle;
> +};
> +
> +/*hnae loop mode*/
> +enum hnae_loop {
> +       MAC_LOOP_NONE = 0,
> +       MAC_INTERNALLOOP_MAC,
> +       MAC_INTERNALLOOP_SERDES,
> +       MAC_INTERNALLOOP_PHY,
> +};
> +
> +/*hnae port type*/
> +enum hnae_port_type {
> +       HNAE_PORT_SERVICE = 0,
> +       HNAE_PORT_DEBUG
> +};
> +
> +/* This struct defines the operation on the handle.
> + *
> + * get_handle(): (mandatory)
> + *   Get a handle from AE according to its name and options.
> + *   the AE driver should manage the space used by handle and its queues while
> + *   the HNAE framework will allocate desc and desc_cb for all rings in the
> + *   queues.
> + * put_handle():
> + *   Release the handle.
> + * start():
> + *   Enable the hardware, include all queues
> + * stop():
> + *   Disable the hardware
> + * set_opts(): (mandatory)
> + *   Set options to the AE
> + * get_opts(): (mandatory)
> + *   Get options from the AE
> + * get_status():
> + *   Get the carrier state of the back channel of the handle, 1 for ok, 0 for
> + *   non-ok
> + * toggle_ring_irq(): (mandatory)
> + *   Set the ring irq to be enabled(0) or disable(1)
> + * toggle_queue_status(): (mandatory)
> + *   Set the queue to be enabled(1) or disable(0), this will not change the
> + *   ring irq state
> + * adjust_link()
> + *   adjust link status
> + * set_loopback()
> + *   set loopback
> + * get_ring_bdnum_limit()
> + *   get ring bd number limit
> + * get_pauseparam()
> + *   get tx and rx of pause frame use
> + * set_autoneg()
> + *   set auto autonegotiation of pause frame use
> + * get_autoneg()
> + *   get auto autonegotiation of pause frame use
> + * set_pauseparam()
> + *   set tx and rx of pause frame use
> + * get_coalesce_usecs()
> + *   get usecs to delay a TX interrupt after a packet is sent
> + * get_rx_max_coalesced_frames()
> + *   get Maximum number of packets to be sent before a TX interrupt.
> + * set_coalesce_usecs()
> + *   set usecs to delay a TX interrupt after a packet is sent
> + * set_coalesce_frames()
> + *   set Maximum number of packets to be sent before a TX interrupt.
> + * get_ringnum()
> + *   get RX/TX ring number
> + * get_max_ringnum()
> + *   get RX/TX ring maximum number
> + * get_mac_addr()
> + *   get mac address
> + * set_mac_addr()
> + *   set mac address
> + * set_mc_addr()
> + *   set multicast mode
> + * set_mtu()
> + *   set mtu
> + * update_stats()
> + *   update Old network device statistics
> + * get_ethtool_stats()
> + *   get ethtool network device statistics
> + * get_strings()
> + *   get a set of strings that describe the requested objects
> + * get_sset_count()
> + *   get number of strings that @get_strings will write
> + * update_led_status()
> + *   update the led status
> + * set_led_id()
> + *   set led id
> + * get_regs()
> + *   get regs dump
> + * get_regs_len()
> + *   get the len of the regs dump
> + */
> +struct hnae_ae_ops {
> +       struct hnae_handle *(*get_handle)(struct hnae_ae_dev *dev,
> +                                         const char *opts);
> +       void (*put_handle)(struct hnae_handle *handle);
> +       void (*init_queue)(struct hnae_queue *q);
> +       void (*fini_queue)(struct hnae_queue *q);
> +       int (*start)(struct hnae_handle *handle);
> +       void (*stop)(struct hnae_handle *handle);
> +       void (*reset)(struct hnae_handle *handle);
> +       int (*set_opts)(struct hnae_handle *handle, int type, void *opts);
> +       int (*get_opts)(struct hnae_handle *handle, int type, void **opts);
> +       int (*get_status)(struct hnae_handle *handle);
> +       int (*get_info)(struct hnae_handle *handle,
> +                       u8 *auto_neg, u16 *speed, u8 *duplex);
> +       int (*set_info)(struct hnae_handle *handle,
> +                       u8 auto_neg, u16 speed, u8 duplex);
> +       void (*toggle_ring_irq)(struct hnae_ring *ring, u32 val);
> +       void (*toggle_queue_status)(struct hnae_queue *queue, u32 val);
> +       void (*adjust_link)(struct hnae_handle *handle, int speed, int duplex);
> +       int (*set_loopback)(struct hnae_handle *handle,
> +                           enum hnae_loop loop_mode, int en);
> +       void (*get_ring_bdnum_limit)(struct hnae_queue *queue,
> +                                    u32 *uplimit, u32 *lowlimit);
> +       void (*get_pauseparam)(struct hnae_handle *handle,
> +                              u32 *auto_neg, u32 *rx_en, u32 *tx_en);
> +       int (*set_autoneg)(struct hnae_handle *handle, u8 enable);
> +       int (*get_autoneg)(struct hnae_handle *handle);
> +       void (*set_pauseparam)(struct hnae_handle *handle,
> +                              u32 rx_en, u32 tx_en);
> +       void (*get_coalesce_usecs)(struct hnae_handle *handle,
> +                                  u32 *tx_usecs, u32 *rx_usecs);
> +       void (*get_rx_max_coalesced_frames)(struct hnae_handle *handle,
> +                                           u32 *tx_frames, u32 *rx_frames);
> +       void (*set_coalesce_usecs)(struct hnae_handle *handle, u32 timeout);
> +       int (*set_coalesce_frames)(struct hnae_handle *handle,
> +                                  u32 coalesce_frames);
> +       void (*get_ringnum)(struct hnae_handle *handle, u32 *ringnum);
> +       void (*get_max_ringnum)(struct hnae_handle *handle, u32 *max_ringnum);
> +       int (*get_mac_addr)(struct hnae_handle *handle, void **p);
> +       int (*set_mac_addr)(struct hnae_handle *handle, void *p);
> +       int (*set_mc_addr)(struct hnae_handle *handle, void *addr);
> +       int (*set_mtu)(struct hnae_handle *handle, int new_mtu);
> +       void (*update_stats)(struct hnae_handle *handle,
> +                            struct net_device_stats *net_stats);
> +       void (*get_stats)(struct hnae_handle *handle, u64 *data);
> +       void (*get_strings)(struct hnae_handle *handle,
> +                           u32 stringset, u8 *data);
> +       int (*get_sset_count)(struct hnae_handle *handle, int stringset);
> +       void (*update_led_status)(struct hnae_handle *handle);
> +       int (*set_led_id)(struct hnae_handle *handle,
> +                         enum hnae_led_state status);
> +       void (*get_regs)(struct hnae_handle *handle, void *data);
> +       int (*get_regs_len)(struct hnae_handle *handle);
> +};
> +
> +struct hnae_ae_dev {
> +       struct device cls_dev; /* the class dev */
> +       struct device *dev; /* the presented dev */
> +       struct hnae_ae_ops *ops;
> +       struct list_head node;
> +       struct module *owner; /* the module who provides this dev */
> +       int id;
> +       char name[AE_NAME_SIZE];
> +       struct list_head handle_list;
> +       spinlock_t lock; /* lock to protect the handle_list */
> +};
> +
> +struct hnae_handle {
> +       struct device *owner_dev; /* the device which make use of this handle */
> +       struct hnae_ae_dev *dev;  /* the device who provides this handle */
> +       struct device_node *phy_node;
> +       phy_interface_t phy_if;
> +       u32 if_support;
> +       int q_num;
> +       const char *ae_opts;
> +       enum hnae_port_type port_type;
> +       struct list_head node;    /* list to hnae_ae_dev->handle_list */
> +       struct hnae_buf_ops *bops; /* operation for the buffer */
> +       struct net_device_stats net_stats;
> +       struct hnae_queue **qs;  /* array base of all queues */
> +};
> +
> +#define ring_to_dev(ring) ((ring)->q->dev->dev)
> +
> +struct hnae_handle *hnae_get_handle(struct device *owner_dev, const char *ae_id,
> +                                   const char *ae_opts,
> +                                   struct hnae_buf_ops *bops);
> +void hnae_put_handle(struct hnae_handle *handle);
> +int hnae_ae_register(struct hnae_ae_dev *dev, struct module *owner);
> +void hnae_ae_unregister(struct hnae_ae_dev *dev);
> +
> +int hnae_register_notifier(struct notifier_block *nb);
> +void hnae_unregister_notifier(struct notifier_block *nb);
> +int hnae_reinit_handle(struct hnae_handle *handle);
> +
> +#define hnae_queue_xmit(q, buf_num) writel_relaxed(buf_num, \
> +       (q)->tx_ring.io_base + RCB_REG_TAIL)
> +
> +#ifndef assert
> +#define assert(cond)
> +#endif
> +
> +static inline int hnae_reserve_buffer_map(struct hnae_ring *ring,
> +                                         struct hnae_desc_cb *cb)
> +{
> +       struct hnae_buf_ops *bops = ring->q->handle->bops;
> +       int ret;
> +
> +       ret = bops->alloc_buffer(ring, cb);
> +       if (ret)
> +               goto out;
> +
> +       ret = bops->map_buffer(ring, cb);
> +       if (ret)
> +               goto out_with_buf;
> +
> +       return 0;
> +
> +out_with_buf:
> +       bops->free_buffer(ring, cb);
> +out:
> +       return ret;
> +}
> +
> +static inline int hnae_alloc_buffer_attach(struct hnae_ring *ring, int i)
> +{
> +       int ret = hnae_reserve_buffer_map(ring, &ring->desc_cb[i]);
> +
> +       if (ret)
> +               return ret;
> +
> +       ring->desc[i].addr = (__le64)ring->desc_cb[i].dma;
> +
> +       return 0;
> +}
> +
> +static inline void hnae_buffer_detach(struct hnae_ring *ring, int i)
> +{
> +       ring->q->handle->bops->unmap_buffer(ring, &ring->desc_cb[i]);
> +       ring->desc[i].addr = 0;
> +}
> +
> +static inline void hnae_free_buffer_detach(struct hnae_ring *ring, int i)
> +{
> +       struct hnae_buf_ops *bops = ring->q->handle->bops;
> +       struct hnae_desc_cb *cb = &ring->desc_cb[i];
> +
> +       if (!ring->desc_cb[i].dma)
> +               return;
> +
> +       hnae_buffer_detach(ring, i);
> +       bops->free_buffer(ring, cb);
> +}
> +
> +/* detach a in-used buffer and replace with a reserved one  */
> +static inline void hnae_replace_buffer(struct hnae_ring *ring, int i,
> +                                      struct hnae_desc_cb *res_cb)
> +{
> +       struct hnae_buf_ops *bops = ring->q->handle->bops;
> +       struct hnae_desc_cb tmp_cb = ring->desc_cb[i];
> +
> +       bops->unmap_buffer(ring, &ring->desc_cb[i]);
> +       ring->desc_cb[i] = *res_cb;
> +       *res_cb = tmp_cb;
> +       ring->desc[i].addr = (__le64)ring->desc_cb[i].dma;
> +       ring->desc[i].rx.ipoff_bnum_pid_flag = 0;
> +}
> +
> +static inline void hnae_reuse_buffer(struct hnae_ring *ring, int i)
> +{
> +       ring->desc_cb[i].reuse_flag = 0;
> +       ring->desc[i].addr = (__le64)(ring->desc_cb[i].dma
> +               + ring->desc_cb[i].page_offset);
> +       ring->desc[i].rx.ipoff_bnum_pid_flag = 0;
> +}
> +
> +#define hnae_set_field(origin, mask, shift, val) \
> +       do { \
> +               (origin) &= (~(mask)); \
> +               (origin) |= ((val) << (shift)) & (mask); \
> +       } while (0)
> +
> +#define hnae_set_bit(origin, shift, val) \
> +       hnae_set_field((origin), (0x1 << (shift)), (shift), (val))
> +
> +#define hnae_get_field(origin, mask, shift) (((origin) & (mask)) >> (shift))
> +
> +#define hnae_get_bit(origin, shift) \
> +       hnae_get_field((origin), (0x1 << (shift)), (shift))
> +
> +#endif
> --
> 1.9.1
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Best regards, Klimov Alexey
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
