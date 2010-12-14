From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/2] workqueue: convert cancel_rearming_delayed_work[queue]()
 users to cancel_delayed_work_sync()
Date: Tue, 14 Dec 2010 16:21:17 +0100
Message-ID: <4D078B6D.5060202@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org, benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org, mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cbou-JGs/UdohzUI@public.gmane.org,
	dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, aelder-sJ/iWh9BUns@public.gmane.org,
	xfs-masters-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

cancel_rearming_delayed_work[queue]() has been superceded by
cancel_delayed_work_sync() quite some time ago.  Convert all the
in-kernel users.  The conversions are completely equivalent and
trivial.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Cc: Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>
Cc: Mauro Carvalho Chehab <mchehab-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Anton Vorontsov <cbou-JGs/UdohzUI@public.gmane.org>
Cc: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Cc: Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>
Cc: Alex Elder <aelder-sJ/iWh9BUns@public.gmane.org>
Cc: xfs-masters-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org
Cc: Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Pekka Enberg <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
These two patches convert all cancel_rearming users and deprecate the
two long obsolete functions.  Unless someone objects, I'll push these
two through the workqueue tree in the next merge window.  The next
patch will mark the two functions __deprecated and schedule for
removal during 2.6.39 cycle.

Thank you.

 drivers/ata/libata-core.c                  |    2 +-
 drivers/ata/libata-sff.c                   |    2 +-
 drivers/macintosh/rack-meter.c             |    4 ++--
 drivers/media/dvb/dvb-usb/dvb-usb-remote.c |    2 +-
 drivers/media/video/em28xx/em28xx-input.c  |    2 +-
 drivers/net/chelsio/my3126.c               |    2 +-
 drivers/net/ibm_newemac/core.c             |    4 ++--
 drivers/net/wireless/zd1211rw/zd_mac.c     |    3 +--
 drivers/power/ds2760_battery.c             |    6 ++----
 drivers/power/intel_mid_battery.c          |    6 ++----
 drivers/staging/pohmelfs/inode.c           |    4 ++--
 drivers/usb/atm/cxacru.c                   |    2 +-
 drivers/video/fb_defio.c                   |    2 +-
 drivers/video/omap/lcd_mipid.c             |    2 +-
 fs/nfsd/nfs4state.c                        |    2 +-
 fs/xfs/xfs_mru_cache.c                     |    2 +-
 mm/slab.c                                  |    2 +-
 mm/vmstat.c                                |    2 +-
 net/atm/lec.c                              |    2 +-
 net/core/netpoll.c                         |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c             |    2 +-
 net/sunrpc/xprtsock.c                      |    2 +-
 22 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/drivers/ata/libata-core.c b/drivers/ata/libata-core.c
index 7f77c67..6669b44 100644
--- a/drivers/ata/libata-core.c
+++ b/drivers/ata/libata-core.c
@@ -6122,7 +6122,7 @@ static void ata_port_detach(struct ata_port *ap)
 	/* it better be dead now */
 	WARN_ON(!(ap->pflags & ATA_PFLAG_UNLOADED));

-	cancel_rearming_delayed_work(&ap->hotplug_task);
+	cancel_delayed_work_sync(&ap->hotplug_task);

  skip_eh:
 	if (ap->pmp_link) {
diff --git a/drivers/ata/libata-sff.c b/drivers/ata/libata-sff.c
index d05387d..8660a70 100644
--- a/drivers/ata/libata-sff.c
+++ b/drivers/ata/libata-sff.c
@@ -1320,7 +1320,7 @@ void ata_sff_flush_pio_task(struct ata_port *ap)
 {
 	DPRINTK("ENTER\n");

-	cancel_rearming_delayed_work(&ap->sff_pio_task);
+	cancel_delayed_work_sync(&ap->sff_pio_task);
 	ap->hsm_task_state = HSM_ST_IDLE;

 	if (ata_msg_ctl(ap))
diff --git a/drivers/macintosh/rack-meter.c b/drivers/macintosh/rack-meter.c
index 53cce3a..39f660b 100644
--- a/drivers/macintosh/rack-meter.c
+++ b/drivers/macintosh/rack-meter.c
@@ -285,8 +285,8 @@ static void __devinit rackmeter_init_cpu_sniffer(struct rackmeter *rm)

 static void __devexit rackmeter_stop_cpu_sniffer(struct rackmeter *rm)
 {
-	cancel_rearming_delayed_work(&rm->cpu[0].sniffer);
-	cancel_rearming_delayed_work(&rm->cpu[1].sniffer);
+	cancel_delayed_work_sync(&rm->cpu[0].sniffer);
+	cancel_delayed_work_sync(&rm->cpu[1].sniffer);
 }

 static int __devinit rackmeter_setup(struct rackmeter *rm)
diff --git a/drivers/media/dvb/dvb-usb/dvb-usb-remote.c b/drivers/media/dvb/dvb-usb/dvb-usb-remote.c
index b579fed..0831469 100644
--- a/drivers/media/dvb/dvb-usb/dvb-usb-remote.c
+++ b/drivers/media/dvb/dvb-usb/dvb-usb-remote.c
@@ -298,7 +298,7 @@ int dvb_usb_remote_init(struct dvb_usb_device *d)
 int dvb_usb_remote_exit(struct dvb_usb_device *d)
 {
 	if (d->state & DVB_USB_STATE_REMOTE) {
-		cancel_rearming_delayed_work(&d->rc_query_work);
+		cancel_delayed_work_sync(&d->rc_query_work);
 		flush_scheduled_work();
 		if (d->props.rc.mode == DVB_RC_LEGACY)
 			input_unregister_device(d->rc_input_dev);
diff --git a/drivers/media/video/em28xx/em28xx-input.c b/drivers/media/video/em28xx/em28xx-input.c
index 6759cd5..99403c7 100644
--- a/drivers/media/video/em28xx/em28xx-input.c
+++ b/drivers/media/video/em28xx/em28xx-input.c
@@ -557,7 +557,7 @@ void em28xx_deregister_snapshot_button(struct em28xx *dev)
 {
 	if (dev->sbutton_input_dev != NULL) {
 		em28xx_info("Deregistering snapshot button\n");
-		cancel_rearming_delayed_work(&dev->sbutton_query_work);
+		cancel_delayed_work_sync(&dev->sbutton_query_work);
 		input_unregister_device(dev->sbutton_input_dev);
 		dev->sbutton_input_dev = NULL;
 	}
diff --git a/drivers/net/chelsio/my3126.c b/drivers/net/chelsio/my3126.c
index 4c60285..a683fd3 100644
--- a/drivers/net/chelsio/my3126.c
+++ b/drivers/net/chelsio/my3126.c
@@ -22,7 +22,7 @@ static int my3126_interrupt_enable(struct cphy *cphy)

 static int my3126_interrupt_disable(struct cphy *cphy)
 {
-	cancel_rearming_delayed_work(&cphy->phy_update);
+	cancel_delayed_work_sync(&cphy->phy_update);
 	return 0;
 }

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index 06bb9b7..e209efa 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1279,7 +1279,7 @@ static void emac_force_link_update(struct emac_instance *dev)
 	netif_carrier_off(dev->ndev);
 	smp_rmb();
 	if (dev->link_polling) {
-		cancel_rearming_delayed_work(&dev->link_work);
+		cancel_delayed_work_sync(&dev->link_work);
 		if (dev->link_polling)
 			schedule_delayed_work(&dev->link_work,  PHY_POLL_LINK_OFF);
 	}
@@ -1294,7 +1294,7 @@ static int emac_close(struct net_device *ndev)

 	if (dev->phy.address >= 0) {
 		dev->link_polling = 0;
-		cancel_rearming_delayed_work(&dev->link_work);
+		cancel_delayed_work_sync(&dev->link_work);
 	}
 	mutex_lock(&dev->link_lock);
 	emac_netif_stop(dev);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 43307bd..6107304 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -1207,7 +1207,6 @@ static void housekeeping_enable(struct zd_mac *mac)
 static void housekeeping_disable(struct zd_mac *mac)
 {
 	dev_dbg_f(zd_mac_dev(mac), "\n");
-	cancel_rearming_delayed_workqueue(zd_workqueue,
-		&mac->housekeeping.link_led_work);
+	cancel_delayed_work_sync(&mac->housekeeping.link_led_work);
 	zd_chip_control_leds(&mac->chip, ZD_LED_OFF);
 }
diff --git a/drivers/power/ds2760_battery.c b/drivers/power/ds2760_battery.c
index b3c01c1..e7f8978 100644
--- a/drivers/power/ds2760_battery.c
+++ b/drivers/power/ds2760_battery.c
@@ -580,10 +580,8 @@ static int ds2760_battery_remove(struct platform_device *pdev)
 {
 	struct ds2760_device_info *di = platform_get_drvdata(pdev);

-	cancel_rearming_delayed_workqueue(di->monitor_wqueue,
-					  &di->monitor_work);
-	cancel_rearming_delayed_workqueue(di->monitor_wqueue,
-					  &di->set_charged_work);
+	cancel_delayed_work_sync(&di->monitor_work);
+	cancel_delayed_work_sync(&di->set_charged_work);
 	destroy_workqueue(di->monitor_wqueue);
 	power_supply_unregister(&di->bat);
 	kfree(di);
diff --git a/drivers/power/intel_mid_battery.c b/drivers/power/intel_mid_battery.c
index 2a10cd3..36cf402 100644
--- a/drivers/power/intel_mid_battery.c
+++ b/drivers/power/intel_mid_battery.c
@@ -730,8 +730,7 @@ static __devinit int probe(int irq, struct device *dev)
 power_reg_failed_1:
 	power_supply_unregister(&pbi->batt);
 power_reg_failed:
-	cancel_rearming_delayed_workqueue(pbi->monitor_wqueue,
-						&pbi->monitor_battery);
+	cancel_delayed_work_sync(&pbi->monitor_battery);
 requestirq_failed:
 	destroy_workqueue(pbi->monitor_wqueue);
 wqueue_failed:
@@ -760,8 +759,7 @@ static int __devexit platform_pmic_battery_remove(struct platform_device *pdev)
 	struct pmic_power_module_info *pbi = dev_get_drvdata(&pdev->dev);

 	free_irq(pbi->irq, pbi);
-	cancel_rearming_delayed_workqueue(pbi->monitor_wqueue,
-					&pbi->monitor_battery);
+	cancel_delayed_work_sync(&pbi->monitor_battery);
 	destroy_workqueue(pbi->monitor_wqueue);

 	power_supply_unregister(&pbi->usb);
diff --git a/drivers/staging/pohmelfs/inode.c b/drivers/staging/pohmelfs/inode.c
index 61685cc..d4a1f20 100644
--- a/drivers/staging/pohmelfs/inode.c
+++ b/drivers/staging/pohmelfs/inode.c
@@ -1318,8 +1318,8 @@ static void pohmelfs_put_super(struct super_block *sb)
 	}

 	psb->trans_scan_timeout = psb->drop_scan_timeout = 0;
-	cancel_rearming_delayed_work(&psb->dwork);
-	cancel_rearming_delayed_work(&psb->drop_dwork);
+	cancel_delayed_work_sync(&psb->dwork);
+	cancel_delayed_work_sync(&psb->drop_dwork);
 	flush_scheduled_work();

 	dprintk("%s: stopped workqueues.\n", __func__);
diff --git a/drivers/usb/atm/cxacru.c b/drivers/usb/atm/cxacru.c
index f383cb4..a845f8b 100644
--- a/drivers/usb/atm/cxacru.c
+++ b/drivers/usb/atm/cxacru.c
@@ -1247,7 +1247,7 @@ static void cxacru_unbind(struct usbatm_data *usbatm_instance,
 	mutex_unlock(&instance->poll_state_serialize);

 	if (is_polling)
-		cancel_rearming_delayed_work(&instance->poll_work);
+		cancel_delayed_work_sync(&instance->poll_work);

 	usb_kill_urb(instance->snd_urb);
 	usb_kill_urb(instance->rcv_urb);
diff --git a/drivers/video/fb_defio.c b/drivers/video/fb_defio.c
index 6b93ef9..8040001 100644
--- a/drivers/video/fb_defio.c
+++ b/drivers/video/fb_defio.c
@@ -75,7 +75,7 @@ int fb_deferred_io_fsync(struct file *file, int datasync)
 		return 0;

 	/* Kill off the delayed work */
-	cancel_rearming_delayed_work(&info->deferred_work);
+	cancel_delayed_work_sync(&info->deferred_work);

 	/* Run it immediately */
 	return schedule_delayed_work(&info->deferred_work, 0);
diff --git a/drivers/video/omap/lcd_mipid.c b/drivers/video/omap/lcd_mipid.c
index 64dcc74..90e3bdd 100644
--- a/drivers/video/omap/lcd_mipid.c
+++ b/drivers/video/omap/lcd_mipid.c
@@ -396,7 +396,7 @@ static void mipid_esd_start_check(struct mipid_device *md)
 static void mipid_esd_stop_check(struct mipid_device *md)
 {
 	if (md->esd_check != NULL)
-		cancel_rearming_delayed_workqueue(md->esd_wq, &md->esd_work);
+		cancel_delayed_work_sync(&md->esd_work);
 }

 static void mipid_esd_work(struct work_struct *work)
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 116cab9..fbd18c3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4336,7 +4336,7 @@ __nfs4_state_shutdown(void)
 void
 nfs4_state_shutdown(void)
 {
-	cancel_rearming_delayed_workqueue(laundry_wq, &laundromat_work);
+	cancel_delayed_work_sync(&laundromat_work);
 	destroy_workqueue(laundry_wq);
 	locks_end_grace(&nfsd4_manager);
 	nfs4_lock_state();
diff --git a/fs/xfs/xfs_mru_cache.c b/fs/xfs/xfs_mru_cache.c
index 45ce15d..edfa178 100644
--- a/fs/xfs/xfs_mru_cache.c
+++ b/fs/xfs/xfs_mru_cache.c
@@ -408,7 +408,7 @@ xfs_mru_cache_flush(
 	spin_lock(&mru->lock);
 	if (mru->queued) {
 		spin_unlock(&mru->lock);
-		cancel_rearming_delayed_workqueue(xfs_mru_reap_wq, &mru->work);
+		cancel_delayed_work_sync(&mru->work);
 		spin_lock(&mru->lock);
 	}

diff --git a/mm/slab.c b/mm/slab.c
index b1e40da..dc98386 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1293,7 +1293,7 @@ static int __cpuinit cpuup_callback(struct notifier_block *nfb,
 		 * anything expensive but will only modify reap_work
 		 * and reschedule the timer.
 		*/
-		cancel_rearming_delayed_work(&per_cpu(slab_reap_work, cpu));
+		cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
 		/* Now the cache_reaper is guaranteed to be not running. */
 		per_cpu(slab_reap_work, cpu).work.func = NULL;
   		break;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 8f62f17..33c33e7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1033,7 +1033,7 @@ static int __cpuinit vmstat_cpuup_callback(struct notifier_block *nfb,
 		break;
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
-		cancel_rearming_delayed_work(&per_cpu(vmstat_work, cpu));
+		cancel_delayed_work_sync(&per_cpu(vmstat_work, cpu));
 		per_cpu(vmstat_work, cpu).work.func = NULL;
 		break;
 	case CPU_DOWN_FAILED:
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 181d70c..96a4a4b 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1608,7 +1608,7 @@ static void lec_arp_destroy(struct lec_priv *priv)
 	struct lec_arp_table *entry;
 	int i;

-	cancel_rearming_delayed_work(&priv->lec_arp_work);
+	cancel_delayed_work_sync(&priv->lec_arp_work);

 	/*
 	 * Remove all entries
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4e98ffa..d291094 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -925,7 +925,7 @@ void __netpoll_cleanup(struct netpoll *np)

 		skb_queue_purge(&npinfo->arp_tx);
 		skb_queue_purge(&npinfo->txq);
-		cancel_rearming_delayed_work(&npinfo->tx_work);
+		cancel_delayed_work_sync(&npinfo->tx_work);

 		/* clean after last, unfinished work */
 		__skb_queue_purge(&npinfo->txq);
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 5f5daa3..96334e0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3432,7 +3432,7 @@ void ip_vs_control_cleanup(void)
 {
 	EnterFunction(2);
 	ip_vs_trash_cleanup();
-	cancel_rearming_delayed_work(&defense_work);
+	cancel_delayed_work_sync(&defense_work);
 	cancel_work_sync(&defense_work.work);
 	ip_vs_kill_estimator(&ip_vs_stats);
 	unregister_sysctl_table(sysctl_header);
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dfcab5a..96549df 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -770,7 +770,7 @@ static void xs_destroy(struct rpc_xprt *xprt)

 	dprintk("RPC:       xs_destroy xprt %p\n", xprt);

-	cancel_rearming_delayed_work(&transport->connect_worker);
+	cancel_delayed_work_sync(&transport->connect_worker);

 	xs_close(xprt);
 	xs_free_peer_addresses(xprt);
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
