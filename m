From: Johan Hedberg <johan.hedberg@intel.com>
Subject: Re: Bluetooth: oops in rfcomm_sock_getsockopt_old
Date: Wed, 20 Nov 2013 17:02:14 +0200
Message-ID: <20131120150214.GA2364@x220.p-661hnu-f1>
References: <alpine.LNX.2.00.1311201553040.31451@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>, netdev@vger.kernel.org,
	linux-bluetooth@vger.kernel.org
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:54800 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608Ab3KTPCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 10:02:23 -0500
Received: by mail-la0-f52.google.com with SMTP id ev20so7183422lab.25
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 07:02:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1311201553040.31451@pobox.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Wed, Nov 20, 2013, Jiri Kosina wrote:
> I am seeing this during boot (when bluetoothd is starting) with current 
> Linus' tree (HEAD == b4789b8e6b), after latest netdev/bluetooth merge:
> 
>  BUG: unable to handle kernel paging request at 000000234df5351a
>  IP: [<ffffffffa05e95b9>] rfcomm_sock_getsockopt_old+0x39/0x190 [rfcomm]
>  PGD 0 
>  Oops: 0000 [#1] SMP 
>  Modules linked in: rfcomm bnep cpufreq_conservative cpufreq_userspace cpufreq_powersa
> CO_vendor_support kvm_intel snd_hda_codec_conexant kvm iwldvm mac80211 btusb bluetooth
> d_hda_intel snd_hda_codec snd_hwdep cfg80211 thinkpad_acpi snd_seq pcspkr snd_pcm i2c_i801 lpc_ich mfd_core rfkill e1000e ehci_pci snd_timer snd_page_alloc snd_seq_device ptp pps_core wmi snd tpm_tis soundcore battery ac tpm tpm_bios acpi_cpufreq autofs4 uhci_hcd ehci_hcd i915 usbcore usb_common drm_kms_helper drm i2c_algo_bit button video edd fan processor ata_generic thermal thermal_sys
>  CPU: 0 PID: 1024 Comm: bluetoothd Not tainted 3.11.0-07976-g8d6083f #1
>  Hardware name: LENOVO 7470BN2/7470BN2, BIOS 6DET38WW (2.02 ) 12/19/2008
>  task: ffff880076c0e000 ti: ffff880036f94000 task.ti: ffff880036f94000
>  RIP: 0010:[<ffffffffa05e95b9>]  [<ffffffffa05e95b9>] rfcomm_sock_getsockopt_old+0x39/0x190 [rfcomm]
>  RSP: 0018:ffff880036f95e78  EFLAGS: 00010246
>  RAX: 000000234df53512 RBX: 00007fff5ebe9e9c RCX: 00007fff5ebe9e9c
>  RDX: 00007fff5ebe9e98 RSI: 0000000000000003 RDI: ffff8800784eb480
>  RBP: ffff880036f95ec8 R08: ffff880076c1e000 R09: 00007fff5ebea148
>  R10: 00007fff5ebe9e98 R11: 0000000000000202 R12: ffff880076c1e000
>  R13: 0000000000000003 R14: 00007fff5ebe9e9c R15: 00007fff5ebe9e98
>  FS:  00007fd5d7655700(0000) GS:ffff88007c200000(0000) knlGS:0000000000000000
>  CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  CR2: 000000234df5351a CR3: 0000000037b06000 CR4: 00000000000007f0
>  Stack:
>   0000000000000004 00007fff5ebe9e98 ffff880036f95ea8 ffffffff81582e8f
>   ffffffff8148e61b ffff8800784eb480 0000000000000012 0000000000000003
>   00007fff5ebe9e9c 00007fff5ebe9e98 ffff880036f95f28 ffffffffa05e9763
>  Call Trace:
>   [<ffffffff81582e8f>] ? _raw_spin_unlock_bh+0x3f/0x50
>   [<ffffffff8148e61b>] ? release_sock+0x2b/0xa0
>   [<ffffffffa05e9763>] rfcomm_sock_getsockopt+0x53/0x190 [rfcomm]
>   [<ffffffff8158b737>] ? sysret_check+0x1b/0x56
>   [<ffffffff81486933>] SyS_getsockopt+0x73/0xe0
>   [<ffffffff8158b712>] system_call_fastpath+0x16/0x1b
>  Code: 04 48 89 5d d8 4c 89 6d e8 48 89 cb 4c 89 65 e0 4c 89 75 f0 41 89 f5 4c 89 7d f8 48 89 55 b8 4c 8b 67 20 49 8b 84 24 50 04 00 00 <4c> 8b 78 08 0f 85 27 01 00 00 e8 e8 83 b6 e0 48 89 d8 e8 60 40 
>  RIP  [<ffffffffa05e95b9>] rfcomm_sock_getsockopt_old+0x39/0x190 [rfcomm]
>   RSP <ffff880036f95e78>
>  CR2: 000000234df5351a
>  ---[ end trace d84df5c733bb1019 ]---
> 
> 
> I have bisected this to 94a86df01. I don't immediately see how this could 
> be causing the issue directly, hence sending out this as a heads-up, and 
> will continue looking into this eventually.
> 
> It seems to be very reliably reproducible, so I expect the bisection to be 
> correct (to be verified still).

The issue is already fixed in the bluetooth and wireless trees but
the patch hasn't yet made it to the net or Linus' tree.

Johan
