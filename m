From: "Subrata Modak" <tosubrata-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [git patches] net driver fixes for .25
Date: Sat, 12 Apr 2008 23:13:52 +0530
Message-ID: <bb33bcf20804121043u6bde459yf135b777383961cc@mail.gmail.com>
References: <20080412093012.GA24827@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0586685653=="
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	ltp-list <ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: "Jeff Garzik" <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20080412093012.GA24827-oTNwCEtKUwI/11+TDStg7g@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ltp-list>
List-Post: <mailto:ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: ltp-list-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

--===============0586685653==
Content-Type: multipart/alternative;
	boundary="----=_Part_12382_21456601.1208022232664"

------=_Part_12382_21456601.1208022232664
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Jeff,

Would you consider contributing your net driver test cases to LTP:

http://ltp.cvs.sourceforge.net/ltp/ltp/testcases/kernel/device-drivers/

Regards--
Subrata

On Sat, Apr 12, 2008 at 3:00 PM, Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org> wrote:

>
> Please pull from 'upstream-davem' branch of
> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
> upstream-davem
>
> to receive the following updates:
>
>  drivers/net/ehea/ehea.h            |    3 +-
>  drivers/net/ehea/ehea_main.c       |   24 +++++++++++++++-
>  drivers/net/forcedeth.c            |   26 ++++++++++++++++-
>  drivers/net/fs_enet/fs_enet-main.c |    3 +-
>  drivers/net/macb.c                 |   14 +++++----
>  drivers/net/sc92031.c              |    1 +
>  drivers/net/sky2.c                 |    1 +
>  drivers/net/smc91x.c               |    2 +
>  drivers/net/ucc_geth.c             |   53
> ++++++++++++++++++++---------------
>  drivers/net/wan/Kconfig            |    6 +++-
>  10 files changed, 97 insertions(+), 36 deletions(-)
>
> Atsushi Nemoto (2):
>      macb: Call phy_disconnect on removing
>      macb: Use semicolon instead of comma for statement
>
> Ayaz Abdulla (1):
>      forcedeth: mac address fix
>
> Joakim Tjernlund (1):
>      ucc_geth: fix non-functional fixed phy support
>
> Krzysztof Halasa (1):
>      Mark generic HDLC + PPP as broken.
>
> Laurent Pinchart (1):
>      fs_enet: Don't call NAPI functions when NAPI is not used.
>
> Sonic Zhang (1):
>      smc91x driver: fix bug: print warning only in interrupt mode
>
> Stephen Hemminger (2):
>      sky2: missing chip name for Yukon Supreme
>      sc92031: sysfs link missing
>
> Thomas Klein (1):
>      ehea: Fix DLPAR memory add support
>
> diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
> index 93b7fb2..a8d3280 100644
> --- a/drivers/net/ehea/ehea.h
> +++ b/drivers/net/ehea/ehea.h
> @@ -40,7 +40,7 @@
>  #include <asm/io.h>
>
>  #define DRV_NAME       "ehea"
> -#define DRV_VERSION    "EHEA_0089"
> +#define DRV_VERSION    "EHEA_0090"
>
>  /* eHEA capability flags */
>  #define DLPAR_PORT_ADD_REM 1
> @@ -371,6 +371,7 @@ struct ehea_port_res {
>        struct ehea_q_skb_arr rq2_skba;
>        struct ehea_q_skb_arr rq3_skba;
>        struct ehea_q_skb_arr sq_skba;
> +       int sq_skba_size;
>        spinlock_t netif_queue;
>        int queue_stopped;
>        int swqe_refill_th;
> diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
> index 07c742d..f460b62 100644
> --- a/drivers/net/ehea/ehea_main.c
> +++ b/drivers/net/ehea/ehea_main.c
> @@ -349,7 +349,8 @@ static void ehea_refill_rq1(struct ehea_port_res *pr,
> int index, int nr_of_wqes)
>        pr->rq1_skba.os_skbs = 0;
>
>        if (unlikely(test_bit(__EHEA_STOP_XFER, &ehea_driver_flags))) {
> -               pr->rq1_skba.index = index;
> +               if (nr_of_wqes > 0)
> +                       pr->rq1_skba.index = index;
>                pr->rq1_skba.os_skbs = fill_wqes;
>                return;
>        }
> @@ -1464,7 +1465,9 @@ static int ehea_init_port_res(struct ehea_port
> *port, struct ehea_port_res *pr,
>                          init_attr->act_nr_rwqes_rq2,
>                          init_attr->act_nr_rwqes_rq3);
>
> -       ret = ehea_init_q_skba(&pr->sq_skba, init_attr->act_nr_send_wqes +
> 1);
> +       pr->sq_skba_size = init_attr->act_nr_send_wqes + 1;
> +
> +       ret = ehea_init_q_skba(&pr->sq_skba, pr->sq_skba_size);
>        ret |= ehea_init_q_skba(&pr->rq1_skba, init_attr->act_nr_rwqes_rq1
> + 1);
>        ret |= ehea_init_q_skba(&pr->rq2_skba, init_attr->act_nr_rwqes_rq2
> + 1);
>        ret |= ehea_init_q_skba(&pr->rq3_skba, init_attr->act_nr_rwqes_rq3
> + 1);
> @@ -2621,6 +2624,22 @@ void ehea_purge_sq(struct ehea_qp *orig_qp)
>        }
>  }
>
> +void ehea_flush_sq(struct ehea_port *port)
> +{
> +       int i;
> +
> +       for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
> +               struct ehea_port_res *pr = &port->port_res[i];
> +               int swqe_max = pr->sq_skba_size - 2 - pr->swqe_ll_count;
> +               int k = 0;
> +               while (atomic_read(&pr->swqe_avail) < swqe_max) {
> +                       msleep(5);
> +                       if (++k == 20)
> +                               break;
> +               }
> +       }
> +}
> +
>  int ehea_stop_qps(struct net_device *dev)
>  {
>        struct ehea_port *port = netdev_priv(dev);
> @@ -2845,6 +2864,7 @@ static void ehea_rereg_mrs(struct work_struct *work)
>                                        if (dev->flags & IFF_UP) {
>                                                down(&port->port_lock);
>                                                netif_stop_queue(dev);
> +                                               ehea_flush_sq(port);
>                                                ret = ehea_stop_qps(dev);
>                                                if (ret) {
>
>  up(&port->port_lock);
> diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> index 419f533..9f088a4 100644
> --- a/drivers/net/forcedeth.c
> +++ b/drivers/net/forcedeth.c
> @@ -5316,8 +5316,7 @@ static int __devinit nv_probe(struct pci_dev
> *pci_dev, const struct pci_device_i
>
>        /* check the workaround bit for correct mac address order */
>        txreg = readl(base + NvRegTransmitPoll);
> -       if ((txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||
> -           (id->driver_data & DEV_HAS_CORRECT_MACADDR)) {
> +       if (id->driver_data & DEV_HAS_CORRECT_MACADDR) {
>                /* mac address is already in correct order */
>                dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
>                dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
> @@ -5325,6 +5324,22 @@ static int __devinit nv_probe(struct pci_dev
> *pci_dev, const struct pci_device_i
>                dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
>                dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
>                dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
> +       } else if (txreg & NVREG_TRANSMITPOLL_MAC_ADDR_REV) {
> +               /* mac address is already in correct order */
> +               dev->dev_addr[0] = (np->orig_mac[0] >>  0) & 0xff;
> +               dev->dev_addr[1] = (np->orig_mac[0] >>  8) & 0xff;
> +               dev->dev_addr[2] = (np->orig_mac[0] >> 16) & 0xff;
> +               dev->dev_addr[3] = (np->orig_mac[0] >> 24) & 0xff;
> +               dev->dev_addr[4] = (np->orig_mac[1] >>  0) & 0xff;
> +               dev->dev_addr[5] = (np->orig_mac[1] >>  8) & 0xff;
> +               /*
> +                * Set orig mac address back to the reversed version.
> +                * This flag will be cleared during low power transition.
> +                * Therefore, we should always put back the reversed
> address.
> +                */
> +               np->orig_mac[0] = (dev->dev_addr[5] << 0) +
> (dev->dev_addr[4] << 8) +
> +                       (dev->dev_addr[3] << 16) + (dev->dev_addr[2] <<
> 24);
> +               np->orig_mac[1] = (dev->dev_addr[1] << 0) +
> (dev->dev_addr[0] << 8);
>        } else {
>                /* need to reverse mac address to correct order */
>                dev->dev_addr[0] = (np->orig_mac[1] >>  8) & 0xff;
> @@ -5595,7 +5610,9 @@ out:
>  static int nv_resume(struct pci_dev *pdev)
>  {
>        struct net_device *dev = pci_get_drvdata(pdev);
> +       u8 __iomem *base = get_hwbase(dev);
>        int rc = 0;
> +       u32 txreg;
>
>        if (!netif_running(dev))
>                goto out;
> @@ -5606,6 +5623,11 @@ static int nv_resume(struct pci_dev *pdev)
>        pci_restore_state(pdev);
>        pci_enable_wake(pdev, PCI_D0, 0);
>
> +       /* restore mac address reverse flag */
> +       txreg = readl(base + NvRegTransmitPoll);
> +       txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
> +       writel(txreg, base + NvRegTransmitPoll);
> +
>        rc = nv_open(dev);
>  out:
>        return rc;
> diff --git a/drivers/net/fs_enet/fs_enet-main.c
> b/drivers/net/fs_enet/fs_enet-main.c
> index af869cf..940e204 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -835,7 +835,8 @@ static int fs_enet_close(struct net_device *dev)
>
>        netif_stop_queue(dev);
>        netif_carrier_off(dev);
> -       napi_disable(&fep->napi);
> +       if (fep->fpi->use_napi)
> +               napi_disable(&fep->napi);
>        phy_stop(fep->phydev);
>
>        spin_lock_irqsave(&fep->lock, flags);
> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
> index 1d210ed..489c7c3 100644
> --- a/drivers/net/macb.c
> +++ b/drivers/net/macb.c
> @@ -242,12 +242,12 @@ static int macb_mii_init(struct macb *bp)
>        /* Enable managment port */
>        macb_writel(bp, NCR, MACB_BIT(MPE));
>
> -       bp->mii_bus.name = "MACB_mii_bus",
> -       bp->mii_bus.read = &macb_mdio_read,
> -       bp->mii_bus.write = &macb_mdio_write,
> -       bp->mii_bus.reset = &macb_mdio_reset,
> -       bp->mii_bus.id = bp->pdev->id,
> -       bp->mii_bus.priv = bp,
> +       bp->mii_bus.name = "MACB_mii_bus";
> +       bp->mii_bus.read = &macb_mdio_read;
> +       bp->mii_bus.write = &macb_mdio_write;
> +       bp->mii_bus.reset = &macb_mdio_reset;
> +       bp->mii_bus.id = bp->pdev->id;
> +       bp->mii_bus.priv = bp;
>        bp->mii_bus.dev = &bp->dev->dev;
>        pdata = bp->pdev->dev.platform_data;
>
> @@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device
> *pdev)
>
>        if (dev) {
>                bp = netdev_priv(dev);
> +               if (bp->phy_dev)
> +                       phy_disconnect(bp->phy_dev);
>                mdiobus_unregister(&bp->mii_bus);
>                kfree(bp->mii_bus.irq);
>                unregister_netdev(dev);
> diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
> index 37b4239..15fcee5 100644
> --- a/drivers/net/sc92031.c
> +++ b/drivers/net/sc92031.c
> @@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struct pci_dev
> *pdev,
>        }
>
>        pci_set_drvdata(pdev, dev);
> +       SET_NETDEV_DEV(dev, &pdev->dev);
>
>  #if SC92031_USE_BAR == 0
>        dev->mem_start = pci_resource_start(pdev, SC92031_USE_BAR);
> diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
> index 853bce0..f226bca 100644
> --- a/drivers/net/sky2.c
> +++ b/drivers/net/sky2.c
> @@ -154,6 +154,7 @@ static const char *yukon2_name[] = {
>        "EC",           /* 0xb6 */
>        "FE",           /* 0xb7 */
>        "FE+",          /* 0xb8 */
> +       "Supreme",      /* 0xb9 */
>  };
>
>  static void sky2_set_multicast(struct net_device *dev);
> diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
> index 4020e9e..63a54e2 100644
> --- a/drivers/net/smc91x.c
> +++ b/drivers/net/smc91x.c
> @@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq, void
> *dev_id)
>        SMC_SET_INT_MASK(mask);
>        spin_unlock(&lp->lock);
>
> +#ifndef CONFIG_NET_POLL_CONTROLLER
>        if (timeout == MAX_IRQ_LOOPS)
>                PRINTK("%s: spurious interrupt (mask = 0x%02x)\n",
>                       dev->name, mask);
> +#endif
>        DBG(3, "%s: Interrupt done (%d loops)\n",
>               dev->name, MAX_IRQ_LOOPS - timeout);
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 8cc3166..0ee4c16 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3833,6 +3833,7 @@ static int ucc_geth_probe(struct of_device* ofdev,
> const struct of_device_id *ma
>        struct device_node *phy;
>        int err, ucc_num, max_speed = 0;
>        const phandle *ph;
> +       const u32 *fixed_link;
>        const unsigned int *prop;
>        const char *sprop;
>        const void *mac_addr;
> @@ -3923,18 +3924,38 @@ static int ucc_geth_probe(struct of_device* ofdev,
> const struct of_device_id *ma
>
>        ug_info->uf_info.regs = res.start;
>        ug_info->uf_info.irq = irq_of_parse_and_map(np, 0);
> +       fixed_link = of_get_property(np, "fixed-link", NULL);
> +       if (fixed_link) {
> +               ug_info->mdio_bus = 0;
> +               ug_info->phy_address = fixed_link[0];
> +               phy = NULL;
> +       } else {
> +               ph = of_get_property(np, "phy-handle", NULL);
> +               phy = of_find_node_by_phandle(*ph);
>
> -       ph = of_get_property(np, "phy-handle", NULL);
> -       phy = of_find_node_by_phandle(*ph);
> +               if (phy == NULL)
> +                       return -ENODEV;
>
> -       if (phy == NULL)
> -               return -ENODEV;
> +               /* set the PHY address */
> +               prop = of_get_property(phy, "reg", NULL);
> +               if (prop == NULL)
> +                       return -1;
> +               ug_info->phy_address = *prop;
> +
> +               /* Set the bus id */
> +               mdio = of_get_parent(phy);
> +
> +               if (mdio == NULL)
> +                       return -1;
>
> -       /* set the PHY address */
> -       prop = of_get_property(phy, "reg", NULL);
> -       if (prop == NULL)
> -               return -1;
> -       ug_info->phy_address = *prop;
> +               err = of_address_to_resource(mdio, 0, &res);
> +               of_node_put(mdio);
> +
> +               if (err)
> +                       return -1;
> +
> +               ug_info->mdio_bus = res.start;
> +       }
>
>        /* get the phy interface type, or default to MII */
>        prop = of_get_property(np, "phy-connection-type", NULL);
> @@ -3979,20 +4000,6 @@ static int ucc_geth_probe(struct of_device* ofdev,
> const struct of_device_id *ma
>                ug_info->numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;
>        }
>
> -       /* Set the bus id */
> -       mdio = of_get_parent(phy);
> -
> -       if (mdio == NULL)
> -               return -1;
> -
> -       err = of_address_to_resource(mdio, 0, &res);
> -       of_node_put(mdio);
> -
> -       if (err)
> -               return -1;
> -
> -       ug_info->mdio_bus = res.start;
> -
>        if (netif_msg_probe(&debug))
>                printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
>                        ug_info->uf_info.ucc_num + 1,
> ug_info->uf_info.regs,
> diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig
> index a3df09e..8005dd1 100644
> --- a/drivers/net/wan/Kconfig
> +++ b/drivers/net/wan/Kconfig
> @@ -150,9 +150,13 @@ config HDLC_FR
>
>  config HDLC_PPP
>        tristate "Synchronous Point-to-Point Protocol (PPP) support"
> -       depends on HDLC
> +       depends on HDLC && BROKEN
>        help
>          Generic HDLC driver supporting PPP over WAN connections.
> +         This module is currently broken and will cause a kernel panic
> +         when a device configured in PPP mode is activated.
> +
> +         It will be replaced by new PPP implementation in Linux 2.6.26.
>
>          If unsure, say N.
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>



-- 
Regards & Thanks--
Subrata

------=_Part_12382_21456601.1208022232664
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Jeff,<br><br>Would you consider contributing your net driver test cases to LTP:<br><br><a href="http://ltp.cvs.sourceforge.net/ltp/ltp/testcases/kernel/device-drivers/">http://ltp.cvs.sourceforge.net/ltp/ltp/testcases/kernel/device-drivers/</a><br>
<br>Regards--<br>Subrata<br><br><div class="gmail_quote">On Sat, Apr 12, 2008 at 3:00 PM, Jeff Garzik &lt;<a href="mailto:jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org">jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org</a>&gt; wrote:<br><blockquote class="gmail_quote" style="border-left: 1px solid rgb(204, 204, 204); margin: 0pt 0pt 0pt 0.8ex; padding-left: 1ex;">
<br>
Please pull from &#39;upstream-davem&#39; branch of<br>
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem<br>
<br>
to receive the following updates:<br>
<br>
&nbsp;drivers/net/ehea/ehea.h &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp;3 +-<br>
&nbsp;drivers/net/ehea/ehea_main.c &nbsp; &nbsp; &nbsp; | &nbsp; 24 +++++++++++++++-<br>
&nbsp;drivers/net/forcedeth.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; 26 ++++++++++++++++-<br>
&nbsp;drivers/net/fs_enet/fs_enet-main.c | &nbsp; &nbsp;3 +-<br>
&nbsp;drivers/net/macb.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; 14 +++++----<br>
&nbsp;drivers/net/sc92031.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp;1 +<br>
&nbsp;drivers/net/sky2.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp;1 +<br>
&nbsp;drivers/net/smc91x.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; &nbsp;2 +<br>
&nbsp;drivers/net/ucc_geth.c &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | &nbsp; 53 ++++++++++++++++++++---------------<br>
&nbsp;drivers/net/wan/Kconfig &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;| &nbsp; &nbsp;6 +++-<br>
&nbsp;10 files changed, 97 insertions(+), 36 deletions(-)<br>
<br>
Atsushi Nemoto (2):<br>
 &nbsp; &nbsp; &nbsp;macb: Call phy_disconnect on removing<br>
 &nbsp; &nbsp; &nbsp;macb: Use semicolon instead of comma for statement<br>
<br>
Ayaz Abdulla (1):<br>
 &nbsp; &nbsp; &nbsp;forcedeth: mac address fix<br>
<br>
Joakim Tjernlund (1):<br>
 &nbsp; &nbsp; &nbsp;ucc_geth: fix non-functional fixed phy support<br>
<br>
Krzysztof Halasa (1):<br>
 &nbsp; &nbsp; &nbsp;Mark generic HDLC + PPP as broken.<br>
<br>
Laurent Pinchart (1):<br>
 &nbsp; &nbsp; &nbsp;fs_enet: Don&#39;t call NAPI functions when NAPI is not used.<br>
<br>
Sonic Zhang (1):<br>
 &nbsp; &nbsp; &nbsp;smc91x driver: fix bug: print warning only in interrupt mode<br>
<br>
Stephen Hemminger (2):<br>
 &nbsp; &nbsp; &nbsp;sky2: missing chip name for Yukon Supreme<br>
 &nbsp; &nbsp; &nbsp;sc92031: sysfs link missing<br>
<br>
Thomas Klein (1):<br>
 &nbsp; &nbsp; &nbsp;ehea: Fix DLPAR memory add support<br>
<br>
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h<br>
index 93b7fb2..a8d3280 100644<br>
--- a/drivers/net/ehea/ehea.h<br>
+++ b/drivers/net/ehea/ehea.h<br>
@@ -40,7 +40,7 @@<br>
&nbsp;#include &lt;asm/io.h&gt;<br>
<br>
&nbsp;#define DRV_NAME &nbsp; &nbsp; &nbsp; &quot;ehea&quot;<br>
-#define DRV_VERSION &nbsp; &nbsp;&quot;EHEA_0089&quot;<br>
+#define DRV_VERSION &nbsp; &nbsp;&quot;EHEA_0090&quot;<br>
<br>
&nbsp;/* eHEA capability flags */<br>
&nbsp;#define DLPAR_PORT_ADD_REM 1<br>
@@ -371,6 +371,7 @@ struct ehea_port_res {<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct ehea_q_skb_arr rq2_skba;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct ehea_q_skb_arr rq3_skba;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct ehea_q_skb_arr sq_skba;<br>
+ &nbsp; &nbsp; &nbsp; int sq_skba_size;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;spinlock_t netif_queue;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;int queue_stopped;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;int swqe_refill_th;<br>
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c<br>
index 07c742d..f460b62 100644<br>
--- a/drivers/net/ehea/ehea_main.c<br>
+++ b/drivers/net/ehea/ehea_main.c<br>
@@ -349,7 +349,8 @@ static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)<br>
 &nbsp; &nbsp; &nbsp; &nbsp;pr-&gt;rq1_skba.os_skbs = 0;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (unlikely(test_bit(__EHEA_STOP_XFER, &amp;ehea_driver_flags))) {<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pr-&gt;rq1_skba.index = index;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (nr_of_wqes &gt; 0)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; pr-&gt;rq1_skba.index = index;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;pr-&gt;rq1_skba.os_skbs = fill_wqes;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;return;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
@@ -1464,7 +1465,9 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;init_attr-&gt;act_nr_rwqes_rq2,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;init_attr-&gt;act_nr_rwqes_rq3);<br>
<br>
- &nbsp; &nbsp; &nbsp; ret = ehea_init_q_skba(&amp;pr-&gt;sq_skba, init_attr-&gt;act_nr_send_wqes + 1);<br>
+ &nbsp; &nbsp; &nbsp; pr-&gt;sq_skba_size = init_attr-&gt;act_nr_send_wqes + 1;<br>
+<br>
+ &nbsp; &nbsp; &nbsp; ret = ehea_init_q_skba(&amp;pr-&gt;sq_skba, pr-&gt;sq_skba_size);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;ret |= ehea_init_q_skba(&amp;pr-&gt;rq1_skba, init_attr-&gt;act_nr_rwqes_rq1 + 1);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;ret |= ehea_init_q_skba(&amp;pr-&gt;rq2_skba, init_attr-&gt;act_nr_rwqes_rq2 + 1);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;ret |= ehea_init_q_skba(&amp;pr-&gt;rq3_skba, init_attr-&gt;act_nr_rwqes_rq3 + 1);<br>
@@ -2621,6 +2624,22 @@ void ehea_purge_sq(struct ehea_qp *orig_qp)<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
&nbsp;}<br>
<br>
+void ehea_flush_sq(struct ehea_port *port)<br>
+{<br>
+ &nbsp; &nbsp; &nbsp; int i;<br>
+<br>
+ &nbsp; &nbsp; &nbsp; for (i = 0; i &lt; port-&gt;num_def_qps + port-&gt;num_add_tx_qps; i++) {<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; struct ehea_port_res *pr = &amp;port-&gt;port_res[i];<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; int swqe_max = pr-&gt;sq_skba_size - 2 - pr-&gt;swqe_ll_count;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; int k = 0;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; while (atomic_read(&amp;pr-&gt;swqe_avail) &lt; swqe_max) {<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; msleep(5);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (++k == 20)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; break;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; }<br>
+ &nbsp; &nbsp; &nbsp; }<br>
+}<br>
+<br>
&nbsp;int ehea_stop_qps(struct net_device *dev)<br>
&nbsp;{<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct ehea_port *port = netdev_priv(dev);<br>
@@ -2845,6 +2864,7 @@ static void ehea_rereg_mrs(struct work_struct *work)<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;if (dev-&gt;flags &amp; IFF_UP) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;down(&amp;port-&gt;port_lock);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;netif_stop_queue(dev);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ehea_flush_sq(port);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ret = ehea_stop_qps(dev);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;if (ret) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;up(&amp;port-&gt;port_lock);<br>
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c<br>
index 419f533..9f088a4 100644<br>
--- a/drivers/net/forcedeth.c<br>
+++ b/drivers/net/forcedeth.c<br>
@@ -5316,8 +5316,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;/* check the workaround bit for correct mac address order */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;txreg = readl(base + NvRegTransmitPoll);<br>
- &nbsp; &nbsp; &nbsp; if ((txreg &amp; NVREG_TRANSMITPOLL_MAC_ADDR_REV) ||<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; (id-&gt;driver_data &amp; DEV_HAS_CORRECT_MACADDR)) {<br>
+ &nbsp; &nbsp; &nbsp; if (id-&gt;driver_data &amp; DEV_HAS_CORRECT_MACADDR) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;/* mac address is already in correct order */<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;dev_addr[0] = (np-&gt;orig_mac[0] &gt;&gt; &nbsp;0) &amp; 0xff;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;dev_addr[1] = (np-&gt;orig_mac[0] &gt;&gt; &nbsp;8) &amp; 0xff;<br>
@@ -5325,6 +5324,22 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;dev_addr[3] = (np-&gt;orig_mac[0] &gt;&gt; 24) &amp; 0xff;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;dev_addr[4] = (np-&gt;orig_mac[1] &gt;&gt; &nbsp;0) &amp; 0xff;<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;dev_addr[5] = (np-&gt;orig_mac[1] &gt;&gt; &nbsp;8) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; } else if (txreg &amp; NVREG_TRANSMITPOLL_MAC_ADDR_REV) {<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* mac address is already in correct order */<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;dev_addr[0] = (np-&gt;orig_mac[0] &gt;&gt; &nbsp;0) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;dev_addr[1] = (np-&gt;orig_mac[0] &gt;&gt; &nbsp;8) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;dev_addr[2] = (np-&gt;orig_mac[0] &gt;&gt; 16) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;dev_addr[3] = (np-&gt;orig_mac[0] &gt;&gt; 24) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;dev_addr[4] = (np-&gt;orig_mac[1] &gt;&gt; &nbsp;0) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;dev_addr[5] = (np-&gt;orig_mac[1] &gt;&gt; &nbsp;8) &amp; 0xff;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /*<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* Set orig mac address back to the reversed version.<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* This flag will be cleared during low power transition.<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;* Therefore, we should always put back the reversed address.<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;*/<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; np-&gt;orig_mac[0] = (dev-&gt;dev_addr[5] &lt;&lt; 0) + (dev-&gt;dev_addr[4] &lt;&lt; 8) +<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; (dev-&gt;dev_addr[3] &lt;&lt; 16) + (dev-&gt;dev_addr[2] &lt;&lt; 24);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; np-&gt;orig_mac[1] = (dev-&gt;dev_addr[1] &lt;&lt; 0) + (dev-&gt;dev_addr[0] &lt;&lt; 8);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;} else {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;/* need to reverse mac address to correct order */<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;dev_addr[0] = (np-&gt;orig_mac[1] &gt;&gt; &nbsp;8) &amp; 0xff;<br>
@@ -5595,7 +5610,9 @@ out:<br>
&nbsp;static int nv_resume(struct pci_dev *pdev)<br>
&nbsp;{<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct net_device *dev = pci_get_drvdata(pdev);<br>
+ &nbsp; &nbsp; &nbsp; u8 __iomem *base = get_hwbase(dev);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;int rc = 0;<br>
+ &nbsp; &nbsp; &nbsp; u32 txreg;<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (!netif_running(dev))<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;goto out;<br>
@@ -5606,6 +5623,11 @@ static int nv_resume(struct pci_dev *pdev)<br>
 &nbsp; &nbsp; &nbsp; &nbsp;pci_restore_state(pdev);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;pci_enable_wake(pdev, PCI_D0, 0);<br>
<br>
+ &nbsp; &nbsp; &nbsp; /* restore mac address reverse flag */<br>
+ &nbsp; &nbsp; &nbsp; txreg = readl(base + NvRegTransmitPoll);<br>
+ &nbsp; &nbsp; &nbsp; txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;<br>
+ &nbsp; &nbsp; &nbsp; writel(txreg, base + NvRegTransmitPoll);<br>
+<br>
 &nbsp; &nbsp; &nbsp; &nbsp;rc = nv_open(dev);<br>
&nbsp;out:<br>
 &nbsp; &nbsp; &nbsp; &nbsp;return rc;<br>
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c<br>
index af869cf..940e204 100644<br>
--- a/drivers/net/fs_enet/fs_enet-main.c<br>
+++ b/drivers/net/fs_enet/fs_enet-main.c<br>
@@ -835,7 +835,8 @@ static int fs_enet_close(struct net_device *dev)<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;netif_stop_queue(dev);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;netif_carrier_off(dev);<br>
- &nbsp; &nbsp; &nbsp; napi_disable(&amp;fep-&gt;napi);<br>
+ &nbsp; &nbsp; &nbsp; if (fep-&gt;fpi-&gt;use_napi)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; napi_disable(&amp;fep-&gt;napi);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;phy_stop(fep-&gt;phydev);<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;spin_lock_irqsave(&amp;fep-&gt;lock, flags);<br>
diff --git a/drivers/net/macb.c b/drivers/net/macb.c<br>
index 1d210ed..489c7c3 100644<br>
--- a/drivers/net/macb.c<br>
+++ b/drivers/net/macb.c<br>
@@ -242,12 +242,12 @@ static int macb_mii_init(struct macb *bp)<br>
 &nbsp; &nbsp; &nbsp; &nbsp;/* Enable managment port */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;macb_writel(bp, NCR, MACB_BIT(MPE));<br>
<br>
- &nbsp; &nbsp; &nbsp; bp-&gt;<a href="http://mii_bus.name" target="_blank">mii_bus.name</a> = &quot;MACB_mii_bus&quot;,<br>
- &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.read = &amp;macb_mdio_read,<br>
- &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.write = &amp;macb_mdio_write,<br>
- &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.reset = &amp;macb_mdio_reset,<br>
- &nbsp; &nbsp; &nbsp; bp-&gt;<a href="http://mii_bus.id" target="_blank">mii_bus.id</a> = bp-&gt;pdev-&gt;id,<br>
- &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.priv = bp,<br>
+ &nbsp; &nbsp; &nbsp; bp-&gt;<a href="http://mii_bus.name" target="_blank">mii_bus.name</a> = &quot;MACB_mii_bus&quot;;<br>
+ &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.read = &amp;macb_mdio_read;<br>
+ &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.write = &amp;macb_mdio_write;<br>
+ &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.reset = &amp;macb_mdio_reset;<br>
+ &nbsp; &nbsp; &nbsp; bp-&gt;<a href="http://mii_bus.id" target="_blank">mii_bus.id</a> = bp-&gt;pdev-&gt;id;<br>
+ &nbsp; &nbsp; &nbsp; bp-&gt;mii_bus.priv = bp;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;bp-&gt;mii_bus.dev = &amp;bp-&gt;dev-&gt;dev;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;pdata = bp-&gt;pdev-&gt;dev.platform_data;<br>
<br>
@@ -1257,6 +1257,8 @@ static int __exit macb_remove(struct platform_device *pdev)<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (dev) {<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;bp = netdev_priv(dev);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (bp-&gt;phy_dev)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; phy_disconnect(bp-&gt;phy_dev);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;mdiobus_unregister(&amp;bp-&gt;mii_bus);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;kfree(bp-&gt;mii_bus.irq);<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;unregister_netdev(dev);<br>
diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c<br>
index 37b4239..15fcee5 100644<br>
--- a/drivers/net/sc92031.c<br>
+++ b/drivers/net/sc92031.c<br>
@@ -1446,6 +1446,7 @@ static int __devinit sc92031_probe(struct pci_dev *pdev,<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;pci_set_drvdata(pdev, dev);<br>
+ &nbsp; &nbsp; &nbsp; SET_NETDEV_DEV(dev, &amp;pdev-&gt;dev);<br>
<br>
&nbsp;#if SC92031_USE_BAR == 0<br>
 &nbsp; &nbsp; &nbsp; &nbsp;dev-&gt;mem_start = pci_resource_start(pdev, SC92031_USE_BAR);<br>
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c<br>
index 853bce0..f226bca 100644<br>
--- a/drivers/net/sky2.c<br>
+++ b/drivers/net/sky2.c<br>
@@ -154,6 +154,7 @@ static const char *yukon2_name[] = {<br>
 &nbsp; &nbsp; &nbsp; &nbsp;&quot;EC&quot;, &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* 0xb6 */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;&quot;FE&quot;, &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* 0xb7 */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;&quot;FE+&quot;, &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;/* 0xb8 */<br>
+ &nbsp; &nbsp; &nbsp; &quot;Supreme&quot;, &nbsp; &nbsp; &nbsp;/* 0xb9 */<br>
&nbsp;};<br>
<br>
&nbsp;static void sky2_set_multicast(struct net_device *dev);<br>
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c<br>
index 4020e9e..63a54e2 100644<br>
--- a/drivers/net/smc91x.c<br>
+++ b/drivers/net/smc91x.c<br>
@@ -1326,9 +1326,11 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)<br>
 &nbsp; &nbsp; &nbsp; &nbsp;SMC_SET_INT_MASK(mask);<br>
 &nbsp; &nbsp; &nbsp; &nbsp;spin_unlock(&amp;lp-&gt;lock);<br>
<br>
+#ifndef CONFIG_NET_POLL_CONTROLLER<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (timeout == MAX_IRQ_LOOPS)<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;PRINTK(&quot;%s: spurious interrupt (mask = 0x%02x)\n&quot;,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;name, mask);<br>
+#endif<br>
 &nbsp; &nbsp; &nbsp; &nbsp;DBG(3, &quot;%s: Interrupt done (%d loops)\n&quot;,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; dev-&gt;name, MAX_IRQ_LOOPS - timeout);<br>
<br>
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c<br>
index 8cc3166..0ee4c16 100644<br>
--- a/drivers/net/ucc_geth.c<br>
+++ b/drivers/net/ucc_geth.c<br>
@@ -3833,6 +3833,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma<br>
 &nbsp; &nbsp; &nbsp; &nbsp;struct device_node *phy;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;int err, ucc_num, max_speed = 0;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;const phandle *ph;<br>
+ &nbsp; &nbsp; &nbsp; const u32 *fixed_link;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;const unsigned int *prop;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;const char *sprop;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;const void *mac_addr;<br>
@@ -3923,18 +3924,38 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;ug_info-&gt;uf_info.regs = res.start;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;ug_info-&gt;uf_info.irq = irq_of_parse_and_map(np, 0);<br>
+ &nbsp; &nbsp; &nbsp; fixed_link = of_get_property(np, &quot;fixed-link&quot;, NULL);<br>
+ &nbsp; &nbsp; &nbsp; if (fixed_link) {<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ug_info-&gt;mdio_bus = 0;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ug_info-&gt;phy_address = fixed_link[0];<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; phy = NULL;<br>
+ &nbsp; &nbsp; &nbsp; } else {<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ph = of_get_property(np, &quot;phy-handle&quot;, NULL);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; phy = of_find_node_by_phandle(*ph);<br>
<br>
- &nbsp; &nbsp; &nbsp; ph = of_get_property(np, &quot;phy-handle&quot;, NULL);<br>
- &nbsp; &nbsp; &nbsp; phy = of_find_node_by_phandle(*ph);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (phy == NULL)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -ENODEV;<br>
<br>
- &nbsp; &nbsp; &nbsp; if (phy == NULL)<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -ENODEV;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* set the PHY address */<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; prop = of_get_property(phy, &quot;reg&quot;, NULL);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (prop == NULL)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -1;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ug_info-&gt;phy_address = *prop;<br>
+<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; /* Set the bus id */<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; mdio = of_get_parent(phy);<br>
+<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (mdio == NULL)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -1;<br>
<br>
- &nbsp; &nbsp; &nbsp; /* set the PHY address */<br>
- &nbsp; &nbsp; &nbsp; prop = of_get_property(phy, &quot;reg&quot;, NULL);<br>
- &nbsp; &nbsp; &nbsp; if (prop == NULL)<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -1;<br>
- &nbsp; &nbsp; &nbsp; ug_info-&gt;phy_address = *prop;<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; err = of_address_to_resource(mdio, 0, &amp;res);<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; of_node_put(mdio);<br>
+<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; if (err)<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -1;<br>
+<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; ug_info-&gt;mdio_bus = res.start;<br>
+ &nbsp; &nbsp; &nbsp; }<br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp;/* get the phy interface type, or default to MII */<br>
 &nbsp; &nbsp; &nbsp; &nbsp;prop = of_get_property(np, &quot;phy-connection-type&quot;, NULL);<br>
@@ -3979,20 +4000,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ug_info-&gt;numThreadsRx = UCC_GETH_NUM_OF_THREADS_4;<br>
 &nbsp; &nbsp; &nbsp; &nbsp;}<br>
<br>
- &nbsp; &nbsp; &nbsp; /* Set the bus id */<br>
- &nbsp; &nbsp; &nbsp; mdio = of_get_parent(phy);<br>
-<br>
- &nbsp; &nbsp; &nbsp; if (mdio == NULL)<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -1;<br>
-<br>
- &nbsp; &nbsp; &nbsp; err = of_address_to_resource(mdio, 0, &amp;res);<br>
- &nbsp; &nbsp; &nbsp; of_node_put(mdio);<br>
-<br>
- &nbsp; &nbsp; &nbsp; if (err)<br>
- &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; return -1;<br>
-<br>
- &nbsp; &nbsp; &nbsp; ug_info-&gt;mdio_bus = res.start;<br>
-<br>
 &nbsp; &nbsp; &nbsp; &nbsp;if (netif_msg_probe(&amp;debug))<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;printk(KERN_INFO &quot;ucc_geth: UCC%1d at 0x%8x (irq = %d) \n&quot;,<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;ug_info-&gt;uf_info.ucc_num + 1, ug_info-&gt;uf_info.regs,<br>
diff --git a/drivers/net/wan/Kconfig b/drivers/net/wan/Kconfig<br>
index a3df09e..8005dd1 100644<br>
--- a/drivers/net/wan/Kconfig<br>
+++ b/drivers/net/wan/Kconfig<br>
@@ -150,9 +150,13 @@ config HDLC_FR<br>
<br>
&nbsp;config HDLC_PPP<br>
 &nbsp; &nbsp; &nbsp; &nbsp;tristate &quot;Synchronous Point-to-Point Protocol (PPP) support&quot;<br>
- &nbsp; &nbsp; &nbsp; depends on HDLC<br>
+ &nbsp; &nbsp; &nbsp; depends on HDLC &amp;&amp; BROKEN<br>
 &nbsp; &nbsp; &nbsp; &nbsp;help<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;Generic HDLC driver supporting PPP over WAN connections.<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; This module is currently broken and will cause a kernel panic<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; when a device configured in PPP mode is activated.<br>
+<br>
+ &nbsp; &nbsp; &nbsp; &nbsp; It will be replaced by new PPP implementation in Linux <a href="http://2.6.26." target="_blank">2.6.26.</a><br>
<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;If unsure, say N.<br>
<font color="#888888"><br>
--<br>
To unsubscribe from this list: send the line &quot;unsubscribe linux-kernel&quot; in<br>
the body of a message to <a href="mailto:majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org">majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a><br>
More majordomo info at &nbsp;<a href="http://vger.kernel.org/majordomo-info.html" target="_blank">http://vger.kernel.org/majordomo-info.html</a><br>
Please read the FAQ at &nbsp;<a href="http://www.tux.org/lkml/" target="_blank">http://www.tux.org/lkml/</a><br>
</font></blockquote></div><br><br clear="all"><br>-- <br>Regards &amp; Thanks--<br>Subrata

------=_Part_12382_21456601.1208022232664--


--===============0586685653==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
--===============0586685653==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ltp-list mailing list
Ltp-list-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
https://lists.sourceforge.net/lists/listinfo/ltp-list

--===============0586685653==--
