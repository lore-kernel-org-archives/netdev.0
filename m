From: Frederik Deweerdt <frederik.deweerdt@xprog.eu>
Subject: [patch] ACPI toshiba: only register rfkill if bt is enabled
Date: Tue, 28 Oct 2008 23:51:57 +0000
Message-ID: <20081028235157.GA26314@gambetta>
References: <200810282210.38038.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	philipl@overt.org, akpm@linux-foundation.org
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:21410 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006AbYJ1XwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:52:05 -0400
Received: by ug-out-1314.google.com with SMTP id 39so441125ugf.37
        for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 16:52:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200810282210.38038.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello  Andrey,

It looks like a part of the rfkill initialization was done whenever
BT was on or not. The following patch checks for BT presence before
registering the rfkill to the input layer. Does it solve the problem for
you?

Regards,
Frederik

Register toshiba RFKill Switch only if bluetooth is enabled

Part of the rfkill initialization was done whenever BT was on or not. The
following patch checks for BT presence before registering the rfkill to
the input layer. Some minor cleanups (> 80 char lines) were also added
in the process.

On Tue, Oct 28, 2008 at 10:10:37PM +0300, Andrey Borzenkov wrote:
[...]
> [   66.633036] toshiba_acpi: Toshiba Laptop ACPI Extras version 0.19
> [   66.633054] toshiba_acpi:     HCI method: \_SB_.VALD.GHCI
> [   66.637764] input: Toshiba RFKill Switch as /devices/virtual/input/input3
[...]
> [  113.920753] ------------[ cut here ]------------
> [  113.920828] kernel BUG at /home/bor/src/linux-git/net/rfkill/rfkill.c:347!
> [  113.920845] invalid opcode: 0000 [#1] 
> [  113.920877] last sysfs file: /sys/devices/pci0000:00/0000:00:04.0/host0/target0:0:0/0:0:0:0/block/sda/size
> [  113.920900] Dumping ftrace buffer:
> [  113.920919]    (ftrace buffer empty)
> [  113.920933] Modules linked in: af_packet irnet ppp_generic slhc ircomm_tty ircomm binfmt_misc loop dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath dm_mod alim15x3 ide_core nvram toshiba cryptomgr aead crypto_blkcipher michael_mic crypto_algapi orinoco_cs orinoco hermes_dld hermes pcmcia firmware_class snd_ali5451 snd_ac97_codec ac97_bus snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device smsc_ircc2 snd_pcm_oss snd_pcm rtc_cmos irda snd_timer snd_mixer_oss rtc_core snd crc_ccitt yenta_socket rtc_lib rsrc_nonstatic i2c_ali1535 pcmcia_core pcspkr psmouse soundcore i2c_core evdev sr_mod snd_page_alloc alim1535_wdt cdrom fan sg video output toshiba_acpi rfkill thermal backlight ali_agp processor ac button input_polldev battery agpgart ohci_hcd usbcore reiserfs p
 ata_ali libata sd_mod scsi_mod [last unloaded: scsi_wait_scan]
> [  113.921765] 
> [  113.921785] Pid: 3272, comm: ipolldevd Not tainted (2.6.28-rc2-1avb #3) PORTEGE 4000
> [  113.921801] EIP: 0060:[<dfaa4683>] EFLAGS: 00010246 CPU: 0
> [  113.921854] EIP is at rfkill_force_state+0x53/0x90 [rfkill]
> [  113.921870] EAX: 00000000 EBX: 00000000 ECX: 00000003 EDX: 00000000
> [  113.921885] ESI: 00000000 EDI: ddd50300 EBP: d8d7af40 ESP: d8d7af24
> [  113.921900]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
> [  113.921918] Process ipolldevd (pid: 3272, ti=d8d7a000 task=d8d93c90 task.ti=d8d7a000)
> [  113.921933] Stack:
> [  113.921945]  d8d7af38 00000246 dfb029d8 dfb029c0 dfb029d8 dfb029c0 ddd50300 d8d7af5c
> [  113.922014]  dfb018e2 01000246 01000000 ddd50300 ddd50314 ddabb8a0 d8d7af68 dfb381c1
> [  113.922098]  00000000 d8d7afa4 c012ec0a 00000000 00000002 00000000 c012eba8 ddabb8c0
> [  113.922240] Call Trace:
> [  113.922240]  [<dfb018e2>] ? bt_poll_rfkill+0x5c/0x82 [toshiba_acpi]
> [  113.922240]  [<dfb381c1>] ? input_polled_device_work+0x11/0x40 [input_polldev]
> [  113.922240]  [<c012ec0a>] ? run_workqueue+0xea/0x1f0
> [  113.922240]  [<c012eba8>] ? run_workqueue+0x88/0x1f0
> [  113.922240]  [<dfb381b0>] ? input_polled_device_work+0x0/0x40 [input_polldev]
> [  113.922240]  [<c012f047>] ? worker_thread+0x87/0xf0
> [  113.922240]  [<c0132b00>] ? autoremove_wake_function+0x0/0x50
> [  113.922240]  [<c012efc0>] ? worker_thread+0x0/0xf0
> [  113.922240]  [<c013280f>] ? kthread+0x3f/0x80
> [  113.922240]  [<c01327d0>] ? kthread+0x0/0x80
> [  113.922240]  [<c01040d7>] ? kernel_thread_helper+0x7/0x10
> [  113.922240] Code: 43 54 89 73 54 39 c6 74 11 89 d9 ba 01 00 00 00 b8 40 68 aa df e8 3e 35 69 e0 89 f8 e8 77 fd 85 e0 31 c0 83 c4 10 5b 5e 5f 5d c3 <0f> 0b eb fe 89 f6 8d bc 27 00 00 00 00 be f4 4d aa df bb 5f 01 
> [  113.922240] EIP: [<dfaa4683>] rfkill_force_state+0x53/0x90 [rfkill] SS:ESP 0068:d8d7af24
> [  113.924700] ---[ end trace 0e404eb40cadd5f0 ]---

Signed-off-by: Frederik Deweerdt <frederik.deweerdt@gmail.com>

diff --git a/drivers/acpi/toshiba_acpi.c b/drivers/acpi/toshiba_acpi.c
index 66aac06..c1c9d87 100644
--- a/drivers/acpi/toshiba_acpi.c
+++ b/drivers/acpi/toshiba_acpi.c
@@ -824,34 +824,38 @@ static int __init toshiba_acpi_init(void)
 			toshiba_acpi_exit();
 			return -ENOMEM;
 		}
-	}
 
-	/* Register input device for kill switch */
-	toshiba_acpi.poll_dev = input_allocate_polled_device();
-	if (!toshiba_acpi.poll_dev) {
-		printk(MY_ERR "unable to allocate kill-switch input device\n");
-		toshiba_acpi_exit();
-		return -ENOMEM;
-	}
-	toshiba_acpi.poll_dev->private = &toshiba_acpi;
-	toshiba_acpi.poll_dev->poll = bt_poll_rfkill;
-	toshiba_acpi.poll_dev->poll_interval = 1000; /* msecs */
-
-	toshiba_acpi.poll_dev->input->name = toshiba_acpi.rfk_name;
-	toshiba_acpi.poll_dev->input->id.bustype = BUS_HOST;
-	toshiba_acpi.poll_dev->input->id.vendor = 0x0930; /* Toshiba USB ID */
-	set_bit(EV_SW, toshiba_acpi.poll_dev->input->evbit);
-	set_bit(SW_RFKILL_ALL, toshiba_acpi.poll_dev->input->swbit);
-	input_report_switch(toshiba_acpi.poll_dev->input, SW_RFKILL_ALL, TRUE);
-	input_sync(toshiba_acpi.poll_dev->input);
-
-	ret = input_register_polled_device(toshiba_acpi.poll_dev);
-	if (ret) {
-		printk(MY_ERR "unable to register kill-switch input device\n");
-		rfkill_free(toshiba_acpi.rfk_dev);
-		toshiba_acpi.rfk_dev = NULL;
-		toshiba_acpi_exit();
-		return ret;
+		/* Register input device for kill switch */
+		toshiba_acpi.poll_dev = input_allocate_polled_device();
+		if (!toshiba_acpi.poll_dev) {
+			printk(MY_ERR
+			       "unable to allocate kill-switch input device\n");
+			toshiba_acpi_exit();
+			return -ENOMEM;
+		}
+		toshiba_acpi.poll_dev->private = &toshiba_acpi;
+		toshiba_acpi.poll_dev->poll = bt_poll_rfkill;
+		toshiba_acpi.poll_dev->poll_interval = 1000; /* msecs */
+
+		toshiba_acpi.poll_dev->input->name = toshiba_acpi.rfk_name;
+		toshiba_acpi.poll_dev->input->id.bustype = BUS_HOST;
+		/* Toshiba USB ID */
+		toshiba_acpi.poll_dev->input->id.vendor = 0x0930;
+		set_bit(EV_SW, toshiba_acpi.poll_dev->input->evbit);
+		set_bit(SW_RFKILL_ALL, toshiba_acpi.poll_dev->input->swbit);
+		input_report_switch(toshiba_acpi.poll_dev->input,
+				    SW_RFKILL_ALL, TRUE);
+		input_sync(toshiba_acpi.poll_dev->input);
+
+		ret = input_register_polled_device(toshiba_acpi.poll_dev);
+		if (ret) {
+			printk(MY_ERR
+			       "unable to register kill-switch input device\n");
+			rfkill_free(toshiba_acpi.rfk_dev);
+			toshiba_acpi.rfk_dev = NULL;
+			toshiba_acpi_exit();
+			return ret;
+		}
 	}
 
 	return 0;
