From: Diego Viola <diego.viola@gmail.com>
Subject: Re: Dell Inspiron 5558/0VNM2T and suspend/resume problem with r8169
Date: Fri, 3 Mar 2017 13:11:37 -0300
Message-ID: <CA+ToGPHxz1nwZr4ZwaqAUkabN08N+1xLHxiEYTjGs34MVBGKWA@mail.gmail.com>
References: <CA+ToGPHD9qRLer2aVFkNhRmJjKwEf6=sdwyqdW_X463H-Fnh3g@mail.gmail.com>
 <CA+ToGPEvrHFukKkO1u9v0ndeCHepjGKs5v43MX7MmaEHgwdyag@mail.gmail.com>
 <CA+ToGPGS+QsWQaH6WBNeXw_jVkmN3o+2f7CTW3i5bhjLTfJwCQ@mail.gmail.com> <CA+ToGPE67L3AA-gSB8GMYP6fco-j+TkjUy7xo4mWWf7_TwVfCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+ToGPE67L3AA-gSB8GMYP6fco-j+TkjUy7xo4mWWf7_TwVfCg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 3, 2017 at 12:40 PM, Diego Viola <diego.viola@gmail.com> wrote:
> On Fri, Mar 3, 2017 at 12:37 PM, Diego Viola <diego.viola@gmail.com> wrote:
>> On Wed, Mar 1, 2017 at 12:47 PM, Diego Viola <diego.viola@gmail.com> wrote:
>>> On Wed, Mar 1, 2017 at 12:44 PM, Diego Viola <diego.viola@gmail.com> wrote:
>>>> My machine (a Dell Inspiron 5558 laptop) fails to resume from suspend
>>>> unless I rmmod r8169 first.
>>>>
>>>> Another workaround is to do this before suspend:
>>>>
>>>> echo 0 > /sys/power/pm_async
>>>>
>>>> I've been reproducing the freeze like this:
>>>>
>>>> $ i3lock && systemctl suspend
>>>>
>>>> I would have to repeat this at least 5 times for the freeze to occur,
>>>> but it seems to be easily reproducible.
>>>>
>>>> If I don't invoke i3lock, I cannot get the freeze to happen, but it
>>>> seems to happen with other lockers also.
>>>>
>>>> I have tried Alt+SysRq+r and tried to switch to another TTY but the
>>>> machine is always unresponsive, which indicates that it's a kernel
>>>> panic.
>>>>
>>>> I have had a similar issue to this about a year ago with the jme
>>>> driver and this was the fix:
>>>>
>>>> https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/jme.c?id=ee50c130c82175eaa0820c96b6d3763928af2241
>>>>
>>>> I haven't tried getting a kernel trace yet, but all seems to indicate
>>>> the problem is caused by r8169, at least til now.
>>>>
>>>> Any ideas, please?
>>>>
>>>> Thanks,
>>>> Diego
>>>
>>> Sorry, I forgot to mention, I'm on Arch Linux (x86_64), kernel 4.9.11-1-ARCH.
>>>
>>> Diego
>>
>> This is still a problem with Linux 4.10.1.
>>
>> Diego
>
> I got this trace in the journal while suspending, not sure if it's
> related to this problem:
>
> Mar 03 12:05:05 myhost kernel: PM: Preparing system for sleep (mem)
> Mar 03 12:05:05 myhost kernel: Freezing user space processes ...
> Mar 03 12:05:05 myhost kernel: usb 2-6: new full-speed USB device
> number 34 using xhci_hcd
> Mar 03 12:05:05 myhost kernel: sr 1:0:0:0: [sr0] tag#28
> UNKNOWN(0x2003) Result: hostbyte=0x00 driverbyte=0x08
> Mar 03 12:05:05 myhost kernel: sr 1:0:0:0: [sr0] tag#28 Sense Key :
> 0x6 [current]
> Mar 03 12:05:05 myhost kernel: sr 1:0:0:0: [sr0] tag#28 ASC=0x28 ASCQ=0x0
> Mar 03 12:05:05 myhost kernel: sr 1:0:0:0: [sr0] tag#28 CDB:
> opcode=0x28 28 00 00 00 00 04 00 00 02 00
> Mar 03 12:05:05 myhost kernel: blk_update_request: I/O error, dev sr0, sector 16
> Mar 03 12:05:05 myhost kernel: (elapsed 1.452 seconds) done.
> Mar 03 12:05:05 myhost kernel: Freezing remaining freezable tasks ...
> Mar 03 12:05:05 myhost kernel: ------------[ cut here ]------------
> Mar 03 12:05:05 myhost kernel: WARNING: CPU: 3 PID: 2134 at
> drivers/base/firmware_class.c:1200 _request_firmware+0x2da/0xa70
> Mar 03 12:05:05 myhost kernel: Modules linked in: fuse nls_iso8859_1
> nls_cp437 vfat fat snd_hda_codec_hdmi rtsx_usb_ms memstick
> rtsx_usb_sdmmc dell_led snd_hda_codec_realtek snd_hda_codec_generic
> dell_laptop intel_rapl x86_pkg_temp_thermal intel_powerclamp coretemp
> kvm_int
> Mar 03 12:05:05 myhost kernel:  bluetooth cfg80211 aesni_intel
> aes_x86_64 crypto_simd glue_helper cryptd evdev intel_cstate
> input_leds intel_rapl_perf mac_hid i915 pcspkr snd snd_soc_sst_acpi
> thermal snd_soc_sst_match wmi battery ac97_bus soundcore fjes
> drm_kms_helper vide
> Mar 03 12:05:05 myhost kernel: CPU: 3 PID: 2134 Comm: kworker/3:5 Not
> tainted 4.10.1-ARCH #1
> Mar 03 12:05:05 myhost kernel: Hardware name: Dell Inc. Inspiron
> 5558/0VNM2T, BIOS A14 11/22/2016
> Mar 03 12:05:05 myhost kernel: Workqueue: usb_hub_wq hub_event [usbcore]
> Mar 03 12:05:05 myhost kernel: Call Trace:
> Mar 03 12:05:05 myhost kernel:  dump_stack+0x63/0x83
> Mar 03 12:05:05 myhost kernel:  __warn+0xcb/0xf0
> Mar 03 12:05:05 myhost kernel:  warn_slowpath_null+0x1d/0x20
> Mar 03 12:05:05 myhost kernel:  _request_firmware+0x2da/0xa70
> Mar 03 12:05:05 myhost kernel:  request_firmware+0x37/0x50
> Mar 03 12:05:05 myhost kernel:  ath3k_load_patch+0xc3/0x1e0 [ath3k]
> Mar 03 12:05:05 myhost kernel:  ath3k_probe+0x76/0x4ac [ath3k]
> Mar 03 12:05:05 myhost kernel:  ? __pm_runtime_set_status+0x1c0/0x2a0
> Mar 03 12:05:05 myhost kernel:  usb_probe_interface+0x159/0x2d0 [usbcore]
> Mar 03 12:05:05 myhost kernel:  driver_probe_device+0x2bb/0x460
> Mar 03 12:05:05 myhost kernel:  __device_attach_driver+0x8c/0x100
> Mar 03 12:05:05 myhost kernel:  ? __driver_attach+0xf0/0xf0
> Mar 03 12:05:05 myhost kernel:  bus_for_each_drv+0x67/0xb0
> Mar 03 12:05:05 myhost kernel:  __device_attach+0xdd/0x160
> Mar 03 12:05:05 myhost kernel:  device_initial_probe+0x13/0x20
> Mar 03 12:05:05 myhost kernel:  bus_probe_device+0x92/0xa0
> Mar 03 12:05:05 myhost kernel:  device_add+0x393/0x670
> Mar 03 12:05:05 myhost kernel:  usb_set_configuration+0x5f9/0x910 [usbcore]
> Mar 03 12:05:05 myhost kernel:  generic_probe+0x2e/0x80 [usbcore]
> Mar 03 12:05:05 myhost kernel:  usb_probe_device+0x2e/0x70 [usbcore]
> Mar 03 12:05:05 myhost kernel:  driver_probe_device+0x2bb/0x460
> Mar 03 12:05:05 myhost kernel:  __device_attach_driver+0x8c/0x100
> Mar 03 12:05:05 myhost kernel:  ? __driver_attach+0xf0/0xf0
> Mar 03 12:05:05 myhost kernel:  bus_for_each_drv+0x67/0xb0
> Mar 03 12:05:05 myhost kernel:  __device_attach+0xdd/0x160
> Mar 03 12:05:05 myhost kernel:  device_initial_probe+0x13/0x20
> Mar 03 12:05:05 myhost kernel:  bus_probe_device+0x92/0xa0
> Mar 03 12:05:05 myhost kernel:  device_add+0x393/0x670
> Mar 03 12:05:05 myhost kernel:  usb_new_device+0x1c9/0x3f0 [usbcore]
> Mar 03 12:05:05 myhost kernel:  hub_event+0xb95/0x1520 [usbcore]
> Mar 03 12:05:05 myhost kernel:  process_one_work+0x1e5/0x470
> Mar 03 12:05:05 myhost kernel:  worker_thread+0x48/0x4e0
> Mar 03 12:05:05 myhost kernel:  kthread+0x101/0x140
> Mar 03 12:05:05 myhost kernel:  ? process_one_work+0x470/0x470
> Mar 03 12:05:05 myhost kernel:  ? kthread_create_on_node+0x60/0x60
> Mar 03 12:05:05 myhost kernel:  ret_from_fork+0x2c/0x40
> Mar 03 12:05:05 myhost kernel: ---[ end trace 40ac42fc353e2506 ]---
> Mar 03 12:05:05 myhost kernel: usb 2-6: firmware:
> ar3k/AthrBT_0x31010000.dfu will not be loaded
> Mar 03 12:05:05 myhost kernel: Bluetooth: Patch file not found
> ar3k/AthrBT_0x31010000.dfu
> Mar 03 12:05:05 myhost kernel: Bluetooth: Loading patch file failed
> Mar 03 12:05:05 myhost kernel: ath3k: probe of 2-6:1.0 failed with error -11
> Mar 03 12:05:05 myhost kernel: (elapsed 0.032 seconds) done.

I'm still able to reproduce the problem even after doing a `rmmod r8169`.

Looks like I was too quick to blame r8169.

I'll get another trace with netconsole later to see exactly what's
making it freeze.

Diego
