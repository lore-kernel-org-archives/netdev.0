From: Florin Iucha <florin@iucha.net>
Subject: crash in ieee80211_rate with linux-2.6.24-rc3
Date: Sun, 18 Nov 2007 14:18:28 -0600
Message-ID: <20071118201828.GT4456@iucha.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9a0qdc/o2xg/hSha"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iucha.net ([209.98.146.184]:35574 "EHLO mail.iucha.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752180AbXKRU1J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2007 15:27:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--9a0qdc/o2xg/hSha
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I'm trying to get the iwl3945 driver working on my laptop, using the
latest kernels.

Upon boot, when udev loads the driver, it does not create the proper
device.  This is the contents of the kernel log:

[   29.694882] iwl3945: Detected Intel PRO/Wireless 3945ABG Network Connect=
ion
[   29.781011] Bluetooth: HCI USB driver ver 2.9
[   29.781104] usbcore: registered new interface driver hci_usb
[   30.145481] iwl3945: Tunable channels: 11 802.11bg, 13 802.11a channels
[   30.145742] phy0: Selected rate control algorithm 'iwl-3945-rs'
[   30.145756] phy0: Failed to initialize wep
[   30.153205] iwl3945: Failed to register network device (error -12)
[   30.357032] lp0: using parport0 (interrupt-driven).
[   30.369224] ieee80211_crypt: registered algorithm 'NULL'
[   30.371757] ieee80211_crypt: registered algorithm 'WEP'
[   30.374179] ieee80211_crypt: registered algorithm 'TKIP'
[   30.376401] ieee80211_crypt: registered algorithm 'CCMP'

I suspect loading ieee80211_crypt after iwl3945 has something to do
with it.  Do I need to build ieee80211_crypt in the monolithic kernel
(as opposed to a module)?

Anyway, the module is loaded - but just sitting there.  If I rmmod it
then insmod it back, I get this:

[   64.830431] ACPI: PCI interrupt for device 0000:03:00.0 disabled
[   64.877506] iwl3945: Intel(R) PRO/Wireless 3945ABG/BG Network Connection=
 driver for Linux, 1.1.17kds
[   64.877515] iwl3945: Copyright(c) 2003-2007 Intel Corporation
[   64.877632] ACPI: PCI Interrupt 0000:03:00.0[A] -> GSI 17 (level, low) -=
> IRQ 17
[   64.877656] PCI: Setting latency timer of device 0000:03:00.0 to 64
[   64.879326] iwl3945: Detected Intel PRO/Wireless 3945ABG Network Connect=
ion
[   64.947524] iwl3945: Tunable channels: 11 802.11bg, 13 802.11a channels
[   64.947539] WARNING: at net/mac80211/ieee80211_rate.c:35 ieee80211_rate_=
control_register()
[   64.947543]=20
[   64.947544] Call Trace:
[   64.947586]  [<ffffffff880589dc>] :mac80211:ieee80211_rate_control_regis=
ter+0xa7/0xdd
[   64.947606]  [<ffffffff880811ad>] :iwl3945:iwl_bg_alive_start+0xc97/0xefa
[   64.947617]  [<ffffffff80513dc4>] thread_return+0x3d/0x81
[   64.947636]  [<ffffffff88080516>] :iwl3945:iwl_bg_alive_start+0x0/0xefa
[   64.947645]  [<ffffffff8023eb2d>] run_workqueue+0x7f/0x10b
[   64.947652]  [<ffffffff8023f449>] worker_thread+0x0/0xe4
[   64.947657]  [<ffffffff8023f523>] worker_thread+0xda/0xe4
[   64.947664]  [<ffffffff80242470>] autoremove_wake_function+0x0/0x2e
[   64.947671]  [<ffffffff8024235f>] kthread+0x47/0x74
[   64.947678]  [<ffffffff8020c408>] child_rip+0xa/0x12
[   64.947688]  [<ffffffff80242318>] kthread+0x0/0x74
[   64.947694]  [<ffffffff8020c3fe>] child_rip+0x0/0x12

And the machine becomes unhappy enough that is not willing to start
new terminals, or reboot cleanly.

The userspace is Ubuntu 7.10, only the kernel is vanilla from git.
The hardware is a Thinkpad T60, with the kernel compiled for AMD64.

Let me know if you need more details or if you want me to try a patch.

Cheers,
florin

--=20
Bruce Schneier expects the Spanish Inquisition.
      http://geekz.co.uk/schneierfacts/fact/163

--9a0qdc/o2xg/hSha
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHQJ4TND0rFCN2b1sRAukCAJ92RHANsI6+RJIzI8g06n7b/P2U1ACfVROe
CSxk/6q8YWdhmWLmh2JcgxI=
=ydaa
-----END PGP SIGNATURE-----

--9a0qdc/o2xg/hSha--
