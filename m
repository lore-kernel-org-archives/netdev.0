From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [RFC][PATCH] Fix another namespace issue with devices assigned
 to  classes
Date: Tue, 08 Jun 2010 13:55:27 +0200
Message-ID: <1275998127.1899.38.camel@yio.site>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
	 <1275506732.3915.41.camel@jlt3.sipsolutions.net>
	 <m16321t4ke.fsf@fess.ebiederm.org> <m17hmhrl6v.fsf_-_@fess.ebiederm.org>
	 <1275634452.5189.1.camel@jlt3.sipsolutions.net>
	 <AANLkTingSwM7e8ldyT1FplF5WCHBsCBCwNkb5ZPHe6hB@mail.gmail.com>
	 <1275640113.9953.8.camel@jlt3.sipsolutions.net>
	 <AANLkTin6ub4k4QYSMnGLRw7lxQaz23Xmo2GQC1RrUf-X@mail.gmail.com>
	 <1275829701.3615.54.camel@jlt3.sipsolutions.net>
	 <AANLkTinUAR2gkY7ipgXKy-pMHcmLuouEeyXxnP97U_7N@mail.gmail.com>
	 <1275903773.29978.1.camel@jlt3.sipsolutions.net>
	 <AANLkTin_qjU0-xXfMDYeYWRd0BmvT4OIdK4S_GQ3ZYUi@mail.gmail.com>
	 <1275905686.29978.3.camel@jlt3.sipsolutions.net>
	 <AANLkTikMDvpEzrtFVue8gStudKONxuQmVx9B2w1JM1vO@mail.gmail.com>
	 <1275910905.29978.7.camel@jlt3.sipsolutions.net>
	 <1275913563.1823.1.camel@yio.site>
	 <1275914205.29978.10.camel@jlt3.sipsolutions.net>
	 <AANLkTilqB2sAyfBTLhYT_a2_TySGay4FFG6SGJUZ1o_4@mail.gmail.com>
	 <1275989260.3706.115.camel@jlt3.sipsolutions.net>
	 <AANLkTinMauFsJTKS3eT-pT44KQ8PSf3HJLS8CZIeHmxP@mail.gmail.com>
	 <1275990325.3706.116.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44200 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477Ab0FHL41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 07:56:27 -0400
Received: by fxm8 with SMTP id 8so2807941fxm.19
        for <netdev@vger.kernel.org>; Tue, 08 Jun 2010 04:56:26 -0700 (PDT)
In-Reply-To: <1275990325.3706.116.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-06-08 at 11:45 +0200, Johannes Berg wrote:
> On Tue, 2010-06-08 at 11:30 +0200, Kay Sievers wrote:
> > On Tue, Jun 8, 2010 at 11:27, Johannes Berg <johannes@sipsolutions.net> wrote:
> > > On Mon, 2010-06-07 at 14:54 +0200, Kay Sievers wrote:
> > >
> > >> > I see you remove the driver. Does this mean that in sysfs these devices
> > >> > wouldn't have a driver symlink? ISTR that we needed that for userspace,
> > >> > but I'm not entirely sure, and I don't have all the relevant userspace
> > >> > in my test setup.
> > >>
> > >> Yeah, if you need the driver, you need to use bus device, as you do
> > >> now. The driver needs to be registered with the core, and the probe
> > >> function needs to tell to bind to the devices while registered. You
> > >> can not manually assign this.
> > >
> > > So I spoke to Jouni and he says that he doesn't remember needing the
> > > driver, so I guess we don't care. Can I get you to submit that patch
> > > properly? Send it to linux-wireless@vger.kernel.org please.
> > 
> > Sure, you mean the patch that changes the hwsim code, or the one I
> > talked about to properly create a virtual bus parent?
> 
> The hwsim one you pasted earlier.

Ok, this needs testing.

Please let me know, if that works for you so far.

Thanks,
Kay


From: Kay Sievers <kay.sievers@vrfy.org>
Subject: mac80211_hwsim - convert class devices to bus devices

Class devices must never have child devices of a different class,
so use bus devices.

Embed the 'struct device' into mac80211_hwsim_data, to do proper
ressource lifetime management at device release time.

Registers a driver, to binds devices to the bus.

Use a virtual root as the parent in /sys/devices/.

Puts the monitor device under the virtual parent.

This creates the following devices (udevadm monitor):
  /module/mac80211_hwsim (module)
  /bus/mac80211_hwsim (bus)
  /bus/mac80211_hwsim/drivers/mac80211_hwsim (drivers)
  /devices/mac80211_hwsim/hwsim0 (mac80211_hwsim)
  /devices/mac80211_hwsim/hwsim0/ieee80211/phy17 (ieee80211)
  /devices/mac80211_hwsim/hwsim0/ieee80211/phy17/rfkill19 (rfkill)
  /devices/mac80211_hwsim/hwsim0/net/wlan9 (net)
  /devices/mac80211_hwsim/hwsim0/net/wlan9/queues/rx-0 (queues)
  /devices/mac80211_hwsim/hwsim0/net/wlan9/queues/rx-1 (queues)
  /devices/mac80211_hwsim/hwsim0/net/wlan9/queues/rx-2 (queues)
  /devices/mac80211_hwsim/hwsim0/net/wlan9/queues/rx-3 (queues)
  /devices/mac80211_hwsim/hwsim1 (mac80211_hwsim)
  /devices/mac80211_hwsim/hwsim1/ieee80211/phy18 (ieee80211)
  /devices/mac80211_hwsim/hwsim1/ieee80211/phy18/rfkill20 (rfkill)
  /devices/mac80211_hwsim/hwsim1/net/wlan10 (net)
  /devices/mac80211_hwsim/hwsim1/net/wlan10/queues/rx-0 (queues)
  /devices/mac80211_hwsim/hwsim1/net/wlan10/queues/rx-1 (queues)
  /devices/mac80211_hwsim/hwsim1/net/wlan10/queues/rx-2 (queues)
  /devices/mac80211_hwsim/hwsim1/net/wlan10/queues/rx-3 (queues)
  /devices/mac80211_hwsim/net/hwsim0 (net)
  /devices/mac80211_hwsim/net/hwsim0/queues/rx-0 (queues)

Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
---

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 6f8cb3e..2543e74 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -194,7 +194,16 @@ static inline void hwsim_clear_sta_magic(struct ieee80211_sta *sta)
 	sp->magic = 0;
 }
 
-static struct class *hwsim_class;
+static struct bus_type hwsim_bus = {
+	.name = "mac80211_hwsim",
+};
+
+static struct device_driver hwsim_driver = {
+	.name = "mac80211_hwsim",
+	.bus = &hwsim_bus,
+};
+
+static struct device *hwsim_virtual_parent;
 
 static struct net_device *hwsim_mon; /* global monitor netdev */
 
@@ -280,7 +289,7 @@ static struct list_head hwsim_radios;
 struct mac80211_hwsim_data {
 	struct list_head list;
 	struct ieee80211_hw *hw;
-	struct device *dev;
+	struct device dev;
 	struct ieee80211_supported_band bands[2];
 	struct ieee80211_channel channels_2ghz[ARRAY_SIZE(hwsim_channels_2ghz)];
 	struct ieee80211_channel channels_5ghz[ARRAY_SIZE(hwsim_channels_5ghz)];
@@ -1063,22 +1072,13 @@ static void mac80211_hwsim_free(void)
 		list_move(i, &tmplist);
 	spin_unlock_bh(&hwsim_radio_lock);
 
-	list_for_each_entry_safe(data, tmpdata, &tmplist, list) {
-		debugfs_remove(data->debugfs_group);
-		debugfs_remove(data->debugfs_ps);
-		debugfs_remove(data->debugfs);
-		ieee80211_unregister_hw(data->hw);
-		device_unregister(data->dev);
-		ieee80211_free_hw(data->hw);
-	}
-	class_destroy(hwsim_class);
+	list_for_each_entry_safe(data, tmpdata, &tmplist, list)
+		device_unregister(&data->dev);
+	device_unregister(hwsim_virtual_parent);
+	driver_unregister(&hwsim_driver);
+	bus_unregister(&hwsim_bus);
 }
 
-
-static struct device_driver mac80211_hwsim_driver = {
-	.name = "mac80211_hwsim"
-};
-
 static const struct net_device_ops hwsim_netdev_ops = {
 	.ndo_start_xmit 	= hwsim_mon_xmit,
 	.ndo_change_mtu		= eth_change_mtu,
@@ -1095,6 +1095,7 @@ static void hwsim_mon_setup(struct net_device *dev)
 	dev->type = ARPHRD_IEEE80211_RADIOTAP;
 	memset(dev->dev_addr, 0, ETH_ALEN);
 	dev->dev_addr[0] = 0x12;
+	dev->dev.parent = hwsim_virtual_parent;
 }
 
 
@@ -1231,6 +1232,17 @@ DEFINE_SIMPLE_ATTRIBUTE(hwsim_fops_group,
 			hwsim_fops_group_read, hwsim_fops_group_write,
 			"%llx\n");
 
+static void hwsim_dev_release(struct device* hwsim_dev) {
+	struct mac80211_hwsim_data *data =
+	  container_of(hwsim_dev, struct mac80211_hwsim_data, dev);
+
+	debugfs_remove(data->debugfs_group);
+	debugfs_remove(data->debugfs_ps);
+	debugfs_remove(data->debugfs);
+	ieee80211_unregister_hw(data->hw);
+	ieee80211_free_hw(data->hw);
+}
+
 static int __init init_mac80211_hwsim(void)
 {
 	int i, err = 0;
@@ -1251,9 +1263,22 @@ static int __init init_mac80211_hwsim(void)
 	spin_lock_init(&hwsim_radio_lock);
 	INIT_LIST_HEAD(&hwsim_radios);
 
-	hwsim_class = class_create(THIS_MODULE, "mac80211_hwsim");
-	if (IS_ERR(hwsim_class))
-		return PTR_ERR(hwsim_class);
+	err = bus_register(&hwsim_bus);
+	if (err)
+		return err;
+
+	err = driver_register(&hwsim_driver);
+	if (err) {
+		bus_unregister(&hwsim_bus);
+		return err;
+	}
+
+	hwsim_virtual_parent = root_device_register("mac80211_hwsim");
+	if (IS_ERR(hwsim_virtual_parent)) {
+		driver_unregister(&hwsim_driver);
+		bus_unregister(&hwsim_bus);
+		return PTR_ERR(hwsim_virtual_parent);
+	}
 
 	memset(addr, 0, ETH_ALEN);
 	addr[0] = 0x02;
@@ -1271,18 +1296,19 @@ static int __init init_mac80211_hwsim(void)
 		data = hw->priv;
 		data->hw = hw;
 
-		data->dev = device_create(hwsim_class, NULL, 0, hw,
-					  "hwsim%d", i);
-		if (IS_ERR(data->dev)) {
+		dev_set_name(&data->dev, "hwsim%d", i);
+		data->dev.parent = hwsim_virtual_parent;
+		data->dev.bus = &hwsim_bus;
+		data->dev.release = hwsim_dev_release;
+		err = device_register(&data->dev);
+		if (err) {
 			printk(KERN_DEBUG
-			       "mac80211_hwsim: device_create "
-			       "failed (%ld)\n", PTR_ERR(data->dev));
-			err = -ENOMEM;
+			       "mac80211_hwsim: device_register failed (%d)\n",
+			       err);
 			goto failed_drvdata;
 		}
-		data->dev->driver = &mac80211_hwsim_driver;
 
-		SET_IEEE80211_DEV(hw, data->dev);
+		SET_IEEE80211_DEV(hw, &data->dev);
 		addr[3] = i >> 8;
 		addr[4] = i;
 		memcpy(data->addresses[0].addr, addr, ETH_ALEN);
@@ -1513,7 +1539,7 @@ failed_mon:
 	return err;
 
 failed_hw:
-	device_unregister(data->dev);
+	device_unregister(&data->dev);
 failed_drvdata:
 	ieee80211_free_hw(hw);
 failed:


