From: Andrew Worsley <amworsley@gmail.com>
Subject: network packet corruption in v3.6.0-rc1 (and also in v3.5)
Date: Sat, 18 Aug 2012 16:40:18 +1000
Message-ID: <CA+Y=x3=jSrEaYdnaAF75p0utQq02MhoSh4SkshRVSc7JjjVPOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57810 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781Ab2HRGkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 02:40:20 -0400
Received: by eeil10 with SMTP id l10so1317008eei.19
        for <netdev@vger.kernel.org>; Fri, 17 Aug 2012 23:40:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some times I get a burst of errors and dropped tcp connections with
this warning. I had a similar issue with v3.5 (in fact v3.5 was
unusable for https connections which would give bad MAC code messages
at the application level)..

The issue seems better under v3.6-rc1 where as it was very bad under
v3.5. Let me know if there is something I can do to avoid this
problem. I am using the USB r8712u wireless NIC if that is relevant as
I haven't been able to get the native wireless working under the MAC
book yet (requires proprietary firmware extraction which I am not
familiar with)

Much obliged if there is anything I can do to avoid it as it is rather
annoying. Doesn't happen at all with my  Debian wheezy 3.2.0-2-amd64
kernel.


Andrew

Linux macbook 3.6.0-rc1+ #2 SMP Thu Aug 16 21:07:57 EST 2012 x86_64 GNU/Linux

[ 8280.095421] ------------[ cut here ]------------
[ 8280.095423] WARNING: at net/ipv4/tcp.c:1666 tcp_recvmsg+0x27b/0x98e()
[ 8280.095424] Hardware name: MacBookPro10,1
[ 8280.095425] recvmsg bug 2: copied 7A5E8B11 seq 7A5E8B11 rcvnxt 7A5E8B63 fl 0
[ 8280.095425] Modules linked in: r8712u(C) loop snd_hda_codec_hdmi
coretemp kvm_intel kvm snd_hda_codec_cirrus b43 nouveau snd_hda_intel
snd_hda_codec mac80211 crc32c_intel cfg80211 mxm_wmi snd_hwdep
ghash_clmulni_intel wmi ttm rfkill snd_pcm aesni_intel ssb aes_x86_64
rng_core pcmcia drm_kms_helper aes_generic snd_page_alloc ablk_helper
acpi_cpufreq lpc_ich applesmc drm cryptd snd_timer pcmcia_core
apple_gmux joydev evdev bcm5974 hid_generic snd microcode bcma
mfd_core mperf pcspkr input_polldev i2c_i801 i2c_algo_bit soundcore
i2c_core video battery button apple_bl ac processor thermal_sys
hid_apple ext4 crc16 jbd2 mbcache usbhid hid sd_mod crc_t10dif
ehci_hcd ahci libahci libata sdhci_pci scsi_mod xhci_hcd sdhci
mmc_core usbcore usb_common [last unloaded: r8712u]
[ 8280.095450] Pid: 2371, comm: firefox-bin Tainted: G        WC   3.6.0-rc1+ #2
[ 8280.095451] Call Trace:
[ 8280.095453]  [<ffffffff8103c850>] ? warn_slowpath_common+0x76/0x8a
[ 8280.095455]  [<ffffffff8103c8fc>] ? warn_slowpath_fmt+0x45/0x4a
[ 8280.095457]  [<ffffffff810602c7>] ? should_resched+0x5/0x23
[ 8280.095459]  [<ffffffff812dc1ac>] ? tcp_recvmsg+0x27b/0x98e
[ 8280.095460]  [<ffffffff812f6fed>] ? inet_recvmsg+0x5a/0x6e
[ 8280.095462]  [<ffffffff81297488>] ? __sock_recvmsg_nosec+0x29/0x69
[ 8280.095464]  [<ffffffff8129901c>] ? sock_recvmsg+0x5a/0x79
[ 8280.095467]  [<ffffffff8107ad35>] ? get_futex_key+0x7d/0x206
[ 8280.095469]  [<ffffffff8129a34b>] ? sys_recvfrom+0xc1/0x123
[ 8280.095471]  [<ffffffff8107cc6f>] ? sys_futex+0x127/0x148
[ 8280.095473]  [<ffffffff810ffa6f>] ? vfs_write+0xaf/0xf8
[ 8280.095475]  [<ffffffff810ffc72>] ? sys_write+0x58/0x6d
[ 8280.095477]  [<ffffffff8136d939>] ? system_call_fastpath+0x16/0x1b
[ 8280.095478] ---[ end trace 41af99a11f573306 ]---
[ 8280.095491] ------------[ cut here ]------------

..... repeatedly and also this one ....

[ 7278.076260] ------------[ cut here ]------------
[ 7278.076264] WARNING: at net/ipv4/tcp.c:1654 tcp_recvmsg+0x242/0x98e()
[ 7278.076265] Hardware name: MacBookPro10,1
[ 7278.076266] recvmsg bug: copied F9A0EDEF seq F9A0EE40 rcvnxt F9A0F017 fl 0
[ 7278.076267] Modules linked in: r8712u(C) loop snd_hda_codec_hdmi
coretemp kvm_intel kvm snd_hda_codec_cirrus b43 nouveau snd_hda_intel
snd_hda_codec mac80211 crc32c_intel cfg80211 mxm_wmi snd_hwdep
ghash_clmulni_intel wmi ttm rfkill snd_pcm aesni_intel ssb aes_x86_64
rng_core pcmcia drm_kms_helper aes_generic snd_page_alloc ablk_helper
acpi_cpufreq lpc_ich applesmc drm cryptd snd_timer pcmcia_core
apple_gmux joydev evdev bcm5974 hid_generic snd microcode bcma
mfd_core mperf pcspkr input_polldev i2c_i801 i2c_algo_bit soundcore
i2c_core video battery button apple_bl ac processor thermal_sys
hid_apple ext4 crc16 jbd2 mbcache usbhid hid sd_mod crc_t10dif
ehci_hcd ahci libahci libata sdhci_pci scsi_mod xhci_hcd sdhci
mmc_core usbcore usb_common [last unloaded: r8712u]
[ 7278.076304] Pid: 2371, comm: firefox-bin Tainted: G        WC   3.6.0-rc1+ #2
[ 7278.076305] Call Trace:
[ 7278.076308]  [<ffffffff8103c850>] ? warn_slowpath_common+0x76/0x8a
[ 7278.076311]  [<ffffffff8103c8fc>] ? warn_slowpath_fmt+0x45/0x4a
[ 7278.076314]  [<ffffffff810602c7>] ? should_resched+0x5/0x23
[ 7278.076317]  [<ffffffff812dc173>] ? tcp_recvmsg+0x242/0x98e
[ 7278.076320]  [<ffffffff812f6fed>] ? inet_recvmsg+0x5a/0x6e
[ 7278.076322]  [<ffffffff81297488>] ? __sock_recvmsg_nosec+0x29/0x69
[ 7278.076325]  [<ffffffff8129901c>] ? sock_recvmsg+0x5a/0x79
[ 7278.076329]  [<ffffffff8107ad35>] ? get_futex_key+0x7d/0x206
[ 7278.076332]  [<ffffffff8129a34b>] ? sys_recvfrom+0xc1/0x123
[ 7278.076335]  [<ffffffff8107cc6f>] ? sys_futex+0x127/0x148
[ 7278.076339]  [<ffffffff810ffa6f>] ? vfs_write+0xaf/0xf8
[ 7278.076341]  [<ffffffff810ffc72>] ? sys_write+0x58/0x6d
[ 7278.076344]  [<ffffffff8136d939>] ? system_call_fastpath+0x16/0x1b
[ 7278.076346] ---[ end trace 41af99a11f52c199 ]---
[ 7278.076371] ------------[ cut here ]------------
[ 7278.076374] WARNING: at net/ipv4/tcp.c:1654 tcp_recvmsg+0x242/0x98e()
[ 7278.076375] Hardware name: MacBookPro10,1
[ 7278.076377] recvmsg bug: copied F9A0EDEF seq F9A0EE40 rcvnxt F9A0F017 fl 0
[ 7278.076378] Modules linked in: r8712u(C) loop snd_hda_codec_hdmi
coretemp kvm_intel kvm snd_hda_codec_cirrus b43 nouveau snd_hda_intel
snd_hda_codec mac80211 crc32c_intel cfg80211 mxm_wmi snd_hwdep
ghash_clmulni_intel wmi ttm rfkill snd_pcm aesni_intel ssb aes_x86_64
rng_core pcmcia drm_kms_helper aes_generic snd_page_alloc ablk_helper
acpi_cpufreq lpc_ich applesmc drm cryptd snd_timer pcmcia_core
apple_gmux joydev evdev bcm5974 hid_generic snd microcode bcma
mfd_core mperf pcspkr input_polldev i2c_i801 i2c_algo_bit soundcore
i2c_core video battery button apple_bl ac processor thermal_sys
hid_apple ext4 crc16 jbd2 mbcache usbhid hid sd_mod crc_t10dif
ehci_hcd ahci libahci libata sdhci_pci scsi_mod xhci_hcd sdhci
mmc_core usbcore usb_common [last unloaded: r8712u]
[ 7278.076415] Pid: 2371, comm: firefox-bin Tainted: G        WC   3.6.0-rc1+ #2
[ 7278.076416] Call Trace:
[ 7278.076419]  [<ffffffff8103c850>] ? warn_slowpath_common+0x76/0x8a
[ 7278.076422]  [<ffffffff8103c8fc>] ? warn_slowpath_fmt+0x45/0x4a
[ 7278.076425]  [<ffffffff810602c7>] ? should_resched+0x5/0x23
[ 7278.076428]  [<ffffffff812dc173>] ? tcp_recvmsg+0x242/0x98e
[ 7278.076430]  [<ffffffff812f6fed>] ? inet_recvmsg+0x5a/0x6e
[ 7278.076433]  [<ffffffff81297488>] ? __sock_recvmsg_nosec+0x29/0x69
[ 7278.076436]  [<ffffffff8129901c>] ? sock_recvmsg+0x5a/0x79
[ 7278.076439]  [<ffffffff8107ad35>] ? get_futex_key+0x7d/0x206
[ 7278.076443]  [<ffffffff8129a34b>] ? sys_recvfrom+0xc1/0x123
[ 7278.076446]  [<ffffffff8107cc6f>] ? sys_futex+0x127/0x148
[ 7278.076449]  [<ffffffff810ffa6f>] ? vfs_write+0xaf/0xf8
[ 7278.076452]  [<ffffffff810ffc72>] ? sys_write+0x58/0x6d
[ 7278.076455]  [<ffffffff8136d939>] ? system_call_fastpath+0x16/0x1b
[ 7278.076456] ---[ end trace 41af99a11f52c19a ]---
[ 7278.076482] ------------[ cut here ]------------
[ 7278.076485] WARNING: at net/ipv4/tcp.c:1654 tcp_recvmsg+0x242/0x98e()


Under v3.5 kernel:
My firefox https sessions would constantly drop out with:
SSL received a record with an incorrect Message Authentication Code.
(Error code: ssl_error_bad_mac_read)

and this oops was repeated:
[ 6238.625211] ------------[ cut here ]------------
[ 6238.625212] WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0x27b/0x98e()
[ 6238.625213] Hardware name: MacBookPro10,1
[ 6238.625214] recvmsg bug 2: copied FBAA7A49 seq FBAA7A49 rcvnxt FBAA7A96 fl 0
[ 6238.625215] Modules linked in: loop snd_hda_codec_hdmi coretemp
kvm_intel snd_hda_codec_cirrus b43 kvm nouveau snd_hda_intel mac80211
snd_hda_codec cfg80211 crc32c_intel rfkill mxm_wmi ghash_clmulni_intel
wmi ssb acpi_cpufreq snd_hwdep aesni_intel rng_core mperf ttm snd_pcm
aes_x86_64 drm_kms_helper apple_gmux pcmcia snd_page_alloc aes_generic
drm cryptd lpc_ich snd_timer pcmcia_core input_polldev microcode
pcspkr i2c_i801 processor video bcma mfd_core snd i2c_algo_bit
soundcore ac battery apple_bl button thermal_sys joydev hid_apple
hid_generic usbhid hid bcm5974 usb_storage uas r8712u(C) evdev
uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core videodev
media i2c_core ext4 crc16 jbd2 mbcache sd_mod crc_t10dif xhci_hcd ahci
libahci libata ehci_hcd scsi_mod sdhci_pci usbcore sdhci mmc_core
usb_common [last unloaded: scsi_wait_scan]
[ 6238.625261] Pid: 2705, comm: firefox-bin Tainted: G        WC   3.5.0 #1
[ 6238.625262] Call Trace:
[ 6238.625264]  [<ffffffff81039678>] ? warn_slowpath_common+0x76/0x8a
[ 6238.625265]  [<ffffffff81039724>] ? warn_slowpath_fmt+0x45/0x4a
[ 6238.625267]  [<ffffffff8105cbfc>] ? should_resched+0x5/0x23
[ 6238.625269]  [<ffffffff812d9196>] ? tcp_recvmsg+0x27b/0x98e
[ 6238.625271]  [<ffffffff812f3205>] ? inet_recvmsg+0x5a/0x6e
[ 6238.625272]  [<ffffffff81293718>] ? __sock_recvmsg_nosec+0x29/0x69
[ 6238.625274]  [<ffffffff81294b81>] ? sock_recvmsg+0xc8/0xe8
[ 6238.625276]  [<ffffffff81077465>] ? get_futex_key+0x7d/0x206
[ 6238.625278]  [<ffffffff81078bd9>] ? do_futex+0xd4/0x773
[ 6238.625280]  [<ffffffff811011ca>] ? fget_light+0x63/0x74
[ 6238.625281]  [<ffffffff81294d0d>] ? sockfd_lookup_light+0x17/0x4c
[ 6238.625283]  [<ffffffff812966cd>] ? sys_recvfrom+0xc1/0x123
[ 6238.625285]  [<ffffffff8107939f>] ? sys_futex+0x127/0x148
[ 6238.625287]  [<ffffffff8110060c>] ? sys_write+0x58/0x6d
[ 6238.625289]  [<ffffffff8136a4b9>] ? system_call_fastpath+0x16/0x1b
[ 6238.625290] ---[ end trace fc69f478338db70e ]---
[ 6238.625308] ------------[ cut here ]------------
