From: Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
Subject: WARN_ON_ONCE(work > weight) in napi_poll()
Date: Fri, 30 Jun 2017 19:34:44 +0300
Message-ID: <26670dce-4dd2-f8e4-0e14-90d74257e739@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Language: en-US
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I occasionally hit WARN_ON_ONCE(work > weight); in napi_poll() on a laptop with ath10k card.


[37207.593370] ------------[ cut here ]------------
[37207.593380] WARNING: CPU: 0 PID: 7 at ../net/core/dev.c:5274 net_rx_action+0x258/0x360
[37207.593381] Modules linked in: snd_hda_codec_realtek snd_soc_skl snd_hda_codec_generic snd_soc_skl_ipc snd_soc_sst_ipc snd_soc_sst_dsp snd_hda_ext_core snd_soc_sst_match snd_soc_core rtsx_pci_sdmmc mmc_core snd_pcm_dmaengine x86_pkg_temp_thermal snd_hda_intel uvcvideo kvm_intel videobuf2_vmalloc kvm snd_hda_codec snd_hwdep btusb videobuf2_memops btintel snd_hda_core videobuf2_v4l2 bluetooth irqbypass snd_pcm videobuf2_core crc32c_intel videodev mei_me mei rtsx_pci intel_lpss_pci intel_lpss_acpi intel_vbtn intel_lpss mfd_core tpm_tis intel_hid tpm_tis_core tpm efivarfs
[37207.593430] CPU: 0 PID: 7 Comm: ksoftirqd/0 Not tainted 4.11.7 #28
[37207.593432] Hardware name: Dell Inc. XPS 13 9360/0839Y6, BIOS 1.3.5 05/08/2017
[37207.593433] Call Trace:
[37207.593442]  dump_stack+0x68/0x96
[37207.593447]  __warn+0xcb/0xf0
[37207.593450]  warn_slowpath_null+0x1d/0x20
[37207.593452]  net_rx_action+0x258/0x360
[37207.593459]  __do_softirq+0x12f/0x2f6
[37207.593463]  run_ksoftirqd+0x1f/0x40
[37207.593468]  smpboot_thread_fn+0x10a/0x160
[37207.593471]  kthread+0x108/0x140
[37207.593474]  ? sort_range+0x30/0x30
[37207.593477]  ? kthread_create_on_node+0x40/0x40
[37207.593480]  ret_from_fork+0x2e/0x40
[37207.593483] ---[ end trace 5e4e25ee6369e3eb ]---
