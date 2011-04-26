From: Ben Greear <greearb@candelatech.com>
Subject: rtl8169 related kernel splat in 2.6.38.4
Date: Tue, 26 Apr 2011 15:03:38 -0700
Message-ID: <4DB7413A.1020208@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43712 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231Ab1DZWDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 18:03:41 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p3QM3cgR004668
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 15:03:38 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see this on every (or at least most) boots:

------------[ cut here ]------------
WARNING: at /home/greearb/git/linux-2.6.dev.38.y/kernel/timer.c:983 del_timer_sync+0x25/0x37()
Hardware name: To Be Filled By O.E.M.
Modules linked in: veth 8021q garp stp llc fuse macvlan wanlink(P) pktgen coretemp hwmon nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 uinput arc4 ecb 
snd_hda_codec_realtek snd_hda_intel snd_hda_codec snd_hwdep snd_seq ath9k snd_seq_device mac80211 snd_pcm ath9k_common ath9k_hw snd_timer ath cfg80211 snd r8169 
iTCO_wdt soundcore iTCO_vendor_support microcode i2c_i801 snd_page_alloc serio_raw mii pcspkr i915 drm_kms_helper drm i2c_algo_bit video [last unloaded: 
scsi_wait_scan]
Pid: 3224, comm: ifup Tainted: P            2.6.38.4+ #6
Call Trace:
  [<c043094b>] ? warn_slowpath_common+0x65/0x7a
  [<c04398a0>] ? del_timer_sync+0x25/0x37
  [<c043096f>] ? warn_slowpath_null+0xf/0x13
  [<c04398a0>] ? del_timer_sync+0x25/0x37
  [<c06e94f3>] ? linkwatch_schedule_work+0x68/0x83
  [<c06e95b6>] ? linkwatch_fire_event+0xa8/0xad
  [<c06ef193>] ? netif_carrier_on+0x23/0x34
  [<f8af1b32>] ? __rtl8169_check_link_status+0x4f/0xaf [r8169]
  [<f8af2376>] ? rtl8169_interrupt+0x1e3/0x287 [r8169]
  [<c046c87c>] ? handle_IRQ_event+0x1d/0x9c
  [<c046e130>] ? handle_edge_irq+0xba/0x100
  [<c046e076>] ? handle_edge_irq+0x0/0x100
  <IRQ>  [<c0404026>] ? do_IRQ+0x37/0x90
  [<c04035e9>] ? common_interrupt+0x29/0x30
  [<c0491283>] ? unmap_vmas+0x477/0x5b7
  [<c049298b>] ? __do_fault+0x2f3/0x323
  [<c0495676>] ? exit_mmap+0x7a/0xc3
  [<c042ecd1>] ? mmput+0x61/0xd5
  [<c0432430>] ? exit_mm+0x103/0x10b
  [<c0433cd9>] ? do_exit+0x1b4/0x5cc
  [<c0580fed>] ? copy_to_user+0x2f/0x106
  [<c043a88c>] ? sys_rt_sigaction+0x64/0x77
  [<c0434153>] ? do_group_exit+0x62/0x85
  [<c0772373>] ? do_device_not_available+0x0/0x1a
  [<c0434189>] ? sys_exit_group+0x13/0x17
  [<c040301c>] ? sysenter_do_call+0x12/0x28
---[ end trace da518b58347d6cca ]---

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

