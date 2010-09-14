From: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: 2.6.36-rc4/iwl: warning triggered in net/mac80211/scan.c:266
Date: Tue, 14 Sep 2010 16:28:15 +0200
Message-ID: <20100914142814.GA8744@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I am running 2.6.36-rc4 on T60 with an iwlagn wireless card:
03:00.0 Network controller: Intel Corporation PRO/Wireless 5100 AGN [Shiloh] Network Connection

I was compiling a large file which stressed the box heavily, and the
following warning in net/mac80211/scan.c triggered:

        /*
         * It's ok to abort a not-yet-running scan (that
         * we have one at all will be verified by checking
         * local->scan_req next), but not to complete it
         * successfully.
         */
        if (WARN_ON(!local->scanning && !aborted))
                aborted = true;

dmesg below:

[84379.361297] ------------[ cut here ]------------
[84379.361307] WARNING: at net/mac80211/scan.c:266 ieee80211_scan_completed+0x43/0x17f()
[84379.361311] Hardware name: 2241B48
[84379.361313] Modules linked in: tun iwlagn kvm_intel kvm iwlcore e1000e thinkpad_acpi [last unloaded: scsi_wait_scan]
[84379.361325] Pid: 8254, comm: kworker/u:0 Not tainted 2.6.36-rc4-mst #96
[84379.361328] Call Trace:
[84379.361334]  [<ffffffff815d1399>] ? ieee80211_scan_completed+0x43/0x17f
[84379.361340]  [<ffffffff81042046>] warn_slowpath_common+0x80/0x99
[84379.361354]  [<ffffffffa005d8e7>] ? iwl_generic_cmd_callback+0x0/0xe4 [iwlcore]
[84379.361359]  [<ffffffff81042074>] warn_slowpath_null+0x15/0x17
[84379.361363]  [<ffffffff815d1399>] ieee80211_scan_completed+0x43/0x17f
[84379.361374]  [<ffffffffa0065212>] iwl_bg_scan_completed+0x1ce/0x1d7 [iwlcore]
[84379.361380]  [<ffffffff81057153>] process_one_work+0x1e2/0x301
[84379.361391]  [<ffffffffa0065044>] ? iwl_bg_scan_completed+0x0/0x1d7 [iwlcore]
[84379.361395]  [<ffffffff8105752c>] worker_thread+0x130/0x243
[84379.361400]  [<ffffffff810573fc>] ? worker_thread+0x0/0x243
[84379.361404]  [<ffffffff8105bc1b>] kthread+0x81/0x89
[84379.361409]  [<ffffffff81003914>] kernel_thread_helper+0x4/0x10
[84379.361413]  [<ffffffff8105bb9a>] ? kthread+0x0/0x89
[84379.361417]  [<ffffffff81003910>] ? kernel_thread_helper+0x0/0x10
[84379.361420] ---[ end trace c5ebbd902daa4ea8 ]---
[84379.361422] ------------[ cut here ]------------
[84379.361426] WARNING: at net/mac80211/scan.c:269 ieee80211_scan_completed+0x62/0x17f()
[84379.361429] Hardware name: 2241B48
[84379.361431] Modules linked in: tun iwlagn kvm_intel kvm iwlcore e1000e thinkpad_acpi [last unloaded: scsi_wait_scan]
[84379.361441] Pid: 8254, comm: kworker/u:0 Tainted: G        W   2.6.36-rc4-mst #96
[84379.361461] Call Trace:
[84379.361464]  [<ffffffff815d13b8>] ? ieee80211_scan_completed+0x62/0x17f
[84379.361469]  [<ffffffff81042046>] warn_slowpath_common+0x80/0x99
[84379.361479]  [<ffffffffa005d8e7>] ? iwl_generic_cmd_callback+0x0/0xe4 [iwlcore]
[84379.361484]  [<ffffffff81042074>] warn_slowpath_null+0x15/0x17
[84379.361488]  [<ffffffff815d13b8>] ieee80211_scan_completed+0x62/0x17f
[84379.361503]  [<ffffffffa0065212>] iwl_bg_scan_completed+0x1ce/0x1d7 [iwlcore]
[84379.361506]  [<ffffffff81057153>] process_one_work+0x1e2/0x301
[84379.361512]  [<ffffffffa0065044>] ? iwl_bg_scan_completed+0x0/0x1d7 [iwlcore]
[84379.361515]  [<ffffffff8105752c>] worker_thread+0x130/0x243
[84379.361517]  [<ffffffff810573fc>] ? worker_thread+0x0/0x243
[84379.361519]  [<ffffffff8105bc1b>] kthread+0x81/0x89
[84379.361522]  [<ffffffff81003914>] kernel_thread_helper+0x4/0x10
[84379.361524]  [<ffffffff8105bb9a>] ? kthread+0x0/0x89
[84379.361526]  [<ffffffff81003910>] ? kernel_thread_helper+0x0/0x10
[84379.361528] ---[ end trace c5ebbd902daa4ea9 ]---

Should this happen? Does anyone care?
I am not sure how reproducible this is.
Thanks,

-- 
MST
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
