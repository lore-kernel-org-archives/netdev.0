From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [linux-usb-devel] [PATCH RFC] ZyDAS ZD1211 USB-WLAN driver
Date: Sat, 3 Jun 2006 19:51:08 +0200
Message-ID: <200606031951.09135.oliver@neukum.org>
References: <44817083.508@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev@vger.kernel.org, Ulrich Kunitz <kune@deine-taler.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.kontent.de ([81.88.34.36]:57772 "EHLO Mail1.KONTENT.De")
	by vger.kernel.org with ESMTP id S1750727AbWFCRuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2006 13:50:54 -0400
To: linux-usb-devel@lists.sourceforge.net
In-Reply-To: <44817083.508@gentoo.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Samstag, 3. Juni 2006 13:20 schrieb Daniel Drake:
> I tried to submit this patch yesterday, but it doesn't appear to have 
> been delivered. The patch is probably a bit on the large side, so I'll 
> try again over http:
> 
> http://dev.gentoo.org/~dsd/kernel/zd1211rw.patch
> 
> Any comments appreciated.

+static int read_mac_addr(struct zd_chip *chip, u8 *mac_addr)
+{
+	static const zd_addr_t addr[2] = { CR_MAC_ADDR_P1, CR_MAC_ADDR_P2 };
+	return _read_mac_addr(chip, mac_addr, (const zd_addr_t *)addr);
+}

Why on the stack?

+static int zd1211_hw_reset_phy(struct zd_chip *chip)
+{
+	static const struct zd_ioreq16 ioreqs[] = {
+		{ CR0,   0x0a }, { CR1,   0x06 }, { CR2,   0x26 },
+		{ CR3,   0x38 }, { CR4,   0x80 }, { CR9,   0xa0 },
+		{ CR10,  0x81 }, { CR11,  0x00 }, { CR12,  0x7f },
+		{ CR13,  0x8c }, { CR14,  0x80 }, { CR15,  0x3d },
+		{ CR16,  0x20 }, { CR17,  0x1e }, { CR18,  0x0a },
+		{ CR19,  0x48 }, { CR20,  0x0c }, { CR21,  0x0c },
+		{ CR22,  0x23 }, { CR23,  0x90 }, { CR24,  0x14 },
+		{ CR25,  0x40 }, { CR26,  0x10 }, { CR27,  0x19 },
+		{ CR28,  0x7f }, { CR29,  0x80 }, { CR30,  0x4b },
+		{ CR31,  0x60 }, { CR32,  0x43 }, { CR33,  0x08 },
+		{ CR34,  0x06 }, { CR35,  0x0a }, { CR36,  0x00 },
+		{ CR37,  0x00 }, { CR38,  0x38 }, { CR39,  0x0c },
+		{ CR40,  0x84 }, { CR41,  0x2a }, { CR42,  0x80 },
+		{ CR43,  0x10 }, { CR44,  0x12 }, { CR46,  0xff },
+		{ CR47,  0x1E }, { CR48,  0x26 }, { CR49,  0x5b },
+		{ CR64,  0xd0 }, { CR65,  0x04 }, { CR66,  0x58 },
+		{ CR67,  0xc9 }, { CR68,  0x88 }, { CR69,  0x41 },
+		{ CR70,  0x23 }, { CR71,  0x10 }, { CR72,  0xff },
+		{ CR73,  0x32 }, { CR74,  0x30 }, { CR75,  0x65 },
+		{ CR76,  0x41 }, { CR77,  0x1b }, { CR78,  0x30 },
+		{ CR79,  0x68 }, { CR80,  0x64 }, { CR81,  0x64 },
+		{ CR82,  0x00 }, { CR83,  0x00 }, { CR84,  0x00 },
+		{ CR85,  0x02 }, { CR86,  0x00 }, { CR87,  0x00 },
+		{ CR88,  0xff }, { CR89,  0xfc }, { CR90,  0x00 },
+		{ CR91,  0x00 }, { CR92,  0x00 }, { CR93,  0x08 },
+		{ CR94,  0x00 }, { CR95,  0x00 }, { CR96,  0xff },
+		{ CR97,  0xe7 }, { CR98,  0x00 }, { CR99,  0x00 },
+		{ CR100, 0x00 }, { CR101, 0xae }, { CR102, 0x02 },
+		{ CR103, 0x00 }, { CR104, 0x03 }, { CR105, 0x65 },
+		{ CR106, 0x04 }, { CR107, 0x00 }, { CR108, 0x0a },
+		{ CR109, 0xaa }, { CR110, 0xaa }, { CR111, 0x25 },
+		{ CR112, 0x25 }, { CR113, 0x00 }, { CR119, 0x1e },
+		{ CR125, 0x90 }, { CR126, 0x00 }, { CR127, 0x00 },
+		{ },
+		{ CR5,   0x00 }, { CR6,   0x00 }, { CR7,   0x00 },
+		{ CR8,   0x00 }, { CR9,   0x20 }, { CR12,  0xf0 },
+		{ CR20,  0x0e }, { CR21,  0x0e }, { CR27,  0x10 },
+		{ CR44,  0x33 }, { CR47,  0x1E }, { CR83,  0x24 },
+		{ CR84,  0x04 }, { CR85,  0x00 }, { CR86,  0x0C },
+		{ CR87,  0x12 }, { CR88,  0x0C }, { CR89,  0x00 },
+		{ CR90,  0x10 }, { CR91,  0x08 }, { CR93,  0x00 },
+		{ CR94,  0x01 }, { CR95,  0x00 }, { CR96,  0x50 },
+		{ CR97,  0x37 }, { CR98,  0x35 }, { CR101, 0x13 },
+		{ CR102, 0x27 }, { CR103, 0x27 }, { CR104, 0x18 },
+		{ CR105, 0x12 }, { CR109, 0x27 }, { CR110, 0x27 },
+		{ CR111, 0x27 }, { CR112, 0x27 }, { CR113, 0x27 },
+		{ CR114, 0x27 }, { CR115, 0x26 }, { CR116, 0x24 },
+		{ CR117, 0xfc }, { CR118, 0xfa }, { CR120, 0x4f },
+		{ CR123, 0x27 }, { CR125, 0xaa }, { CR127, 0x03 },
+		{ CR128, 0x14 }, { CR129, 0x12 }, { CR130, 0x10 },
+		{ CR131, 0x0C }, { CR136, 0xdf }, { CR137, 0x40 },
+		{ CR138, 0xa0 }, { CR139, 0xb0 }, { CR140, 0x99 },
+		{ CR141, 0x82 }, { CR142, 0x54 }, { CR143, 0x1c },
+		{ CR144, 0x6c }, { CR147, 0x07 }, { CR148, 0x4c },
+		{ CR149, 0x50 }, { CR150, 0x0e }, { CR151, 0x18 },
+		{ CR160, 0xfe }, { CR161, 0xee }, { CR162, 0xaa },
+		{ CR163, 0xfa }, { CR164, 0xfa }, { CR165, 0xea },
+		{ CR166, 0xbe }, { CR167, 0xbe }, { CR168, 0x6a },
+		{ CR169, 0xba }, { CR170, 0xba }, { CR171, 0xba },
+		/* Note: CR204 must lead the CR203 */
+		{ CR204, 0x7d },
+		{ },
+		{ CR203, 0x30 },
+	};

This is too much to allocate on the stack.

+static void disconnect(struct usb_interface *intf)
+{
+	struct net_device *netdev = zd_intf_to_netdev(intf);
+	struct zd_mac *mac = zd_netdev_mac(netdev);
+	struct zd_usb *usb = &mac->chip.usb;
+
+	dev_dbg_f(zd_usb_dev(usb), "\n");
+
+	zd_netdev_disconnect(netdev);
+
+	/* Just in case something has gone wrong! */
+	zd_usb_disable_rx(usb);
+	zd_usb_disable_int(usb);
+
+	/* If the disconnect has been caused by a removal of the
+	 * driver module, the reset allows reloading of the driver. If the
+	 * reset will not be executed here, the upload of the firmware in the
+	 * probe function caused by the reloading of the driver will fail.
+	 */
+	usb_reset_device(interface_to_usbdev(intf));
+
+	/* If somebody still waits on this lock now, this is an error. */
+	zd_netdev_free(netdev);
+	dev_dbg(&intf->dev, "disconnected\n");
+}

This is racy. It allows io to disconnected devices. You must take the
lock and set a flag that you test after you've taken the lock elsewhere.

	Regards
		Oliver
