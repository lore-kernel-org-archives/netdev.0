From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sat, 24 Jan 2004 19:59:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040124195951.A1304@electric-eye.fr.zoreil.com>
References: <4012A738.2060009@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.tosatti@cyclades.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>,
        Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Content-Disposition: inline
In-Reply-To: <4012A738.2060009@gmx.net>; from c-d.hailfinger.kernel.2004@gmx.net on Sat, Jan 24, 2004 at 06:11:20PM +0100
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net> :
[current version of forcedeth]

+static int __devinit probe_nic(struct pci_dev *pci_dev, const struct pci_device_id *id)
+{
[...]
+       dev = alloc_etherdev(sizeof(struct fe_priv));
+       np = get_nvpriv(dev);
+       err = -ENOMEM;
+       if (!dev)
+               goto out;

-> get_npriv() can still dereference a NULL pointer.

[...]
+       err = pci_request_regions(pci_dev, dev->name);
+       if (err < 0)
+               goto out_disable;
[...]
+       if (i == DEVICE_COUNT_RESOURCE) {
+               printk(KERN_INFO "forcedeth: Couldn't find register window for device %s.\n",
+                                       pci_name(pci_dev));
+               goto out_relreg;
[...]
+       if (!dev->base_addr)
+               goto out_disable;
                     ^^^^^^^^^^^
-> shouldn't it be out_relreg ?

--
Ueimor
