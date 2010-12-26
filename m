From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-2.6] sundance: Fix oopses with corrupted
 skb_shared_info
Date: Sun, 26 Dec 2010 12:01:01 +0100
Message-ID: <20101226110101.GA1850@del.dom.local>
References: <20101225121044.GA1841@del.dom.local>
 <4D15F6C9.50700@scarlet.be>
 <20101225151217.GA1994@del.dom.local>
 <20101225.194210.104056075.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="0OAP2g/MAC+5xKAE"
Cc: soete.joel@scarlet.be, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101225.194210.104056075.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Dec 25, 2010 at 07:42:10PM -0800, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Sat, 25 Dec 2010 16:12:17 +0100
> 
> > [PATCH net-2.6] sundance: Fix oopses with corrupted skb_shared_info
> > 
> > Joel Soete reported oopses at the beginning of pppoe connections since
> > v2.6.35. After debugging the bug was found in sundance skb allocation
> > and dma mapping code, where skb_reserve() bytes aren't taken into
> > account. This is an old bug, only uncovered by some change in 2.6.35.
> > 
> > Initial debugging patch by: Eric Dumazet <eric.dumazet@gmail.com>
> > 
> > Reported-by: Joel Soete <soete.joel@scarlet.be>
> > Tested-by: Joel Soete <soete.joel@scarlet.be>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > Cc: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, great work Jarek.
> 
> I was auditing ppp_generic.c hoping I'd find something, but
> if I had that backtrace I wouldn't have bothered :-)

Yes, with the backtrace it was a piece of cake :-) If I knew you're
interested... Anyway, I append a little bit for the record.

Thanks,
Jarek P.


--0OAP2g/MAC+5xKAE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="joel.syslog-2.6.37-rc7-t2.1000"

Dec 24 10:23:27 sidh2 kernel: imklog 4.6.4, log source = /proc/kmsg started.
Dec 24 10:23:27 sidh2 rsyslogd: [origin software="rsyslogd" swVersion="4.6.4" x-pid="2874" x-info="http://www.rsyslog.com"] (re)start
Dec 24 10:23:27 sidh2 kernel: evices/platform/pcspkr/input/input2
Dec 24 10:23:27 sidh2 kernel: [    5.240072] rtc_cmos 00:04: RTC can wake from S4
Dec 24 10:23:27 sidh2 kernel: [    5.275411] rtc_cmos 00:04: rtc core: registered rtc_cmos as rtc0
Dec 24 10:23:27 sidh2 kernel: [    5.275437] rtc0: alarms up to one month, 242 bytes nvram, hpet irqs
Dec 24 10:23:27 sidh2 kernel: [    5.275486] i801_smbus 0000:00:1f.3: PCI INT C -> GSI 18 (level, low) -> IRQ 18
Dec 24 10:23:27 sidh2 kernel: [    5.275513] md: raid1 personality registered for level 1
Dec 24 10:23:27 sidh2 kernel: [    5.275564] device-mapper: uevent: version 1.0.3
Dec 24 10:23:27 sidh2 kernel: [    5.275615] device-mapper: ioctl: 4.18.0-ioctl (2010-06-29) initialised: dm-devel@redhat.com
Dec 24 10:23:27 sidh2 kernel: [    5.275628] cpuidle: using governor ladder
Dec 24 10:23:27 sidh2 kernel: [    5.275629] cpuidle: using governor menu
Dec 24 10:23:27 sidh2 kernel: [    5.275631] No iBFT detected.
Dec 24 10:23:27 sidh2 kernel: [    5.275752] usbcore: registered new interface driver usbhid
Dec 24 10:23:27 sidh2 kernel: [    5.275753] usbhid: USB HID core driver
Dec 24 10:23:27 sidh2 kernel: [    5.276508] HDA Intel 0000:00:1b.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
Dec 24 10:23:27 sidh2 kernel: [    5.276538] HDA Intel 0000:00:1b.0: irq 41 for MSI/MSI-X
Dec 24 10:23:27 sidh2 kernel: [    5.276554] HDA Intel 0000:00:1b.0: setting latency timer to 64
Dec 24 10:23:27 sidh2 kernel: [    5.313196] ALSA device list:
Dec 24 10:23:27 sidh2 kernel: [    5.313198]   #0: HDA Intel at 0xfbff8000 irq 41
Dec 24 10:23:27 sidh2 kernel: [    5.313335] TCP cubic registered
Dec 24 10:23:27 sidh2 kernel: [    5.313405] NET: Registered protocol family 10
Dec 24 10:23:27 sidh2 kernel: [    5.313625] lo: Disabled Privacy Extensions
Dec 24 10:23:27 sidh2 kernel: [    5.313947] Mobile IPv6
Dec 24 10:23:27 sidh2 kernel: [    5.313949] NET: Registered protocol family 17
Dec 24 10:23:27 sidh2 kernel: [    5.314916] registered taskstats version 1
Dec 24 10:23:27 sidh2 kernel: [    5.315258] rtc_cmos 00:04: setting system clock to 2010-12-24 10:23:06 UTC (1293186186)
Dec 24 10:23:27 sidh2 kernel: [    5.343416] ata3.00: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Dec 24 10:23:27 sidh2 kernel: [    5.343430] ata3.01: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
Dec 24 10:23:27 sidh2 kernel: [    5.363713] ata3.00: HPA detected: current 586070255, native 586072368
Dec 24 10:23:27 sidh2 kernel: [    5.363718] ata3.00: ATA-8: WDC WD3000HLFS-01G6U1, 04.04V02, max UDMA/133
Dec 24 10:23:27 sidh2 kernel: [    5.363721] ata3.00: 586070255 sectors, multi 16: LBA48 NCQ (depth 0/32)
Dec 24 10:23:27 sidh2 kernel: [    5.363961] ata3.01: ATA-8: WDC WD3000HLFS-01G6U1, 04.04V02, max UDMA/133
Dec 24 10:23:27 sidh2 kernel: [    5.363964] ata3.01: 586072368 sectors, multi 16: LBA48 NCQ (depth 0/32)
Dec 24 10:23:27 sidh2 kernel: [    5.379720] ata3.00: configured for UDMA/133
Dec 24 10:23:27 sidh2 kernel: [    5.395942] ata3.01: configured for UDMA/133
Dec 24 10:23:27 sidh2 kernel: [    5.396038] scsi 2:0:0:0: Direct-Access     ATA      WDC WD3000HLFS-0 04.0 PQ: 0 ANSI: 5
Dec 24 10:23:27 sidh2 kernel: [    5.396104] sd 2:0:0:0: Attached scsi generic sg0 type 0
Dec 24 10:23:27 sidh2 kernel: [    5.396108] sd 2:0:0:0: [sda] 586070255 512-byte logical blocks: (300 GB/279 GiB)
Dec 24 10:23:27 sidh2 kernel: [    5.396148] sd 2:0:0:0: [sda] Write Protect is off
Dec 24 10:23:27 sidh2 kernel: [    5.396149] sd 2:0:0:0: [sda] Mode Sense: 00 3a 00 00
Dec 24 10:23:27 sidh2 kernel: [    5.396162] scsi 2:0:1:0: Direct-Access     ATA      WDC WD3000HLFS-0 04.0 PQ: 0 ANSI: 5
Dec 24 10:23:27 sidh2 kernel: [    5.396166] sd 2:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 24 10:23:27 sidh2 kernel: [    5.396229] sd 2:0:1:0: [sdb] 586072368 512-byte logical blocks: (300 GB/279 GiB)
Dec 24 10:23:27 sidh2 kernel: [    5.396231] sd 2:0:1:0: Attached scsi generic sg1 type 0
Dec 24 10:23:27 sidh2 kernel: [    5.396278] sd 2:0:1:0: [sdb] Write Protect is off
Dec 24 10:23:27 sidh2 kernel: [    5.396279] sd 2:0:1:0: [sdb] Mode Sense: 00 3a 00 00
Dec 24 10:23:27 sidh2 kernel: [    5.396296] sd 2:0:1:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 24 10:23:27 sidh2 kernel: [    5.397509] scsi 4:0:0:0: CD-ROM            Optiarc  DVD RW AD-5240S  1.01 PQ: 0 ANSI: 5
Dec 24 10:23:27 sidh2 kernel: [    5.402098] sr0: scsi3-mmc drive: 48x/48x writer cd/rw xa/form2 cdda tray
Dec 24 10:23:27 sidh2 kernel: [    5.402101] cdrom: Uniform CD-ROM driver Revision: 3.20
Dec 24 10:23:27 sidh2 kernel: [    5.402184] sr 4:0:0:0: Attached scsi CD-ROM sr0
Dec 24 10:23:27 sidh2 kernel: [    5.402208] sr 4:0:0:0: Attached scsi generic sg2 type 5
Dec 24 10:23:27 sidh2 kernel: [    5.402269] scsi 6:0:0:0: Direct-Access     ATA      IC35L060AVV207-0 V22O PQ: 0 ANSI: 5
Dec 24 10:23:27 sidh2 kernel: [    5.402324] sd 6:0:0:0: [sdc] 78156288 512-byte logical blocks: (40.0 GB/37.2 GiB)
Dec 24 10:23:27 sidh2 kernel: [    5.402327] sd 6:0:0:0: Attached scsi generic sg3 type 0
Dec 24 10:23:27 sidh2 kernel: [    5.402363] sd 6:0:0:0: [sdc] Write Protect is off
Dec 24 10:23:27 sidh2 kernel: [    5.402364] sd 6:0:0:0: [sdc] Mode Sense: 00 3a 00 00
Dec 24 10:23:27 sidh2 kernel: [    5.402373] scsi 6:0:1:0: Direct-Access     ATA      IC35L060AVV207-0 V22O PQ: 0 ANSI: 5
Dec 24 10:23:27 sidh2 kernel: [    5.402380] sd 6:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 24 10:23:27 sidh2 kernel: [    5.402440] sd 6:0:1:0: Attached scsi generic sg4 type 0
Dec 24 10:23:27 sidh2 kernel: [    5.402442] sd 6:0:1:0: [sdd] 78154175 512-byte logical blocks: (40.0 GB/37.2 GiB)
Dec 24 10:23:27 sidh2 kernel: [    5.402493] sd 6:0:1:0: [sdd] Write Protect is off
Dec 24 10:23:27 sidh2 kernel: [    5.402495] sd 6:0:1:0: [sdd] Mode Sense: 00 3a 00 00
Dec 24 10:23:27 sidh2 kernel: [    5.402513] sd 6:0:1:0: [sdd] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
Dec 24 10:23:27 sidh2 kernel: [    5.424484]  sda: sda1 sda2 < sda5 sda6 sda7 >
Dec 24 10:23:27 sidh2 kernel: [    5.433313]  sdc: sdc1 sdc2 sdc3 < sdc5 >
Dec 24 10:23:27 sidh2 kernel: [    5.443389] firewire_core: created device fw0: GUID 00cb51fb0000241d, S400
Dec 24 10:23:27 sidh2 kernel: [    5.452907]  sdb: sdb1 sdb2 < sdb5 sdb6 sdb7 >
Dec 24 10:23:27 sidh2 kernel: [    5.453051] sd 2:0:0:0: [sda] Attached SCSI disk
Dec 24 10:23:27 sidh2 kernel: [    5.453110] sd 2:0:1:0: [sdb] Attached SCSI disk
Dec 24 10:23:27 sidh2 kernel: [    5.455339] usb 4-1: new low speed USB device using uhci_hcd and address 2
Dec 24 10:23:27 sidh2 kernel: [    5.466628]  sdd: sdd1 sdd2 sdd3 < sdd5 sdd6 >
Dec 24 10:23:27 sidh2 kernel: [    5.466657] sd 6:0:0:0: [sdc] Attached SCSI disk
Dec 24 10:23:27 sidh2 kernel: [    5.466714] sdd: p6 size 27969102 extends beyond EOD, enabling native capacity
Dec 24 10:23:27 sidh2 kernel: [    5.466733] ata7: soft resetting link
Dec 24 10:23:27 sidh2 kernel: [    5.632247] usb 4-1: New USB device found, idVendor=046d, idProduct=c045
Dec 24 10:23:27 sidh2 kernel: [    5.632250] usb 4-1: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 24 10:23:27 sidh2 kernel: [    5.632253] usb 4-1: Product: USB-PS/2 Optical Mouse
Dec 24 10:23:27 sidh2 kernel: [    5.632255] usb 4-1: Manufacturer: Logitech
Dec 24 10:23:27 sidh2 kernel: [    5.649376] input: Logitech USB-PS/2 Optical Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-1/4-1:1.0/input/input3
Dec 24 10:23:27 sidh2 kernel: [    5.649454] generic-usb 0003:046D:C045.0001: input,hidraw0: USB HID v1.10 Mouse [Logitech USB-PS/2 Optical Mouse] on usb-0000:00:1a.1-1/input0
Dec 24 10:23:27 sidh2 kernel: [    5.651793] ata7.01: n_sectors mismatch 78154175 != 78156288
Dec 24 10:23:27 sidh2 kernel: [    5.651795] ata7.01: new n_sectors matches native, probably late HPA unlock, n_sectors updated
Dec 24 10:23:27 sidh2 kernel: [    5.692203] ata7.00: configured for UDMA/100
Dec 24 10:23:27 sidh2 kernel: [    5.716196] ata7.01: configured for UDMA/100
Dec 24 10:23:27 sidh2 kernel: [    5.716199] ata7: EH complete
Dec 24 10:23:27 sidh2 kernel: [    5.716303] sdc: detected capacity change from 0 to 40016019456
Dec 24 10:23:27 sidh2 kernel: [    5.716327] sd 6:0:1:0: [sdd] 78156288 512-byte logical blocks: (40.0 GB/37.2 GiB)
Dec 24 10:23:27 sidh2 kernel: [    5.716595] sdd: detected capacity change from 40014937600 to 40016019456
Dec 24 10:23:27 sidh2 kernel: [    5.758661]  sdd: sdd1 sdd2 sdd3 < sdd5 sdd6 >
Dec 24 10:23:27 sidh2 kernel: [    5.759011] sd 6:0:1:0: [sdd] Attached SCSI disk
Dec 24 10:23:27 sidh2 kernel: [    5.759027] sdc: detected capacity change from 0 to 40016019456
Dec 24 10:23:27 sidh2 kernel: [    5.759034] Freeing unused kernel memory: 740k freed
Dec 24 10:23:27 sidh2 kernel: [    5.759110] sdd: detected capacity change from 0 to 40016019456
Dec 24 10:23:27 sidh2 kernel: [    5.759170] Write protecting the kernel read-only data: 10240k
Dec 24 10:23:27 sidh2 kernel: [    5.759365] Freeing unused kernel memory: 592k freed
Dec 24 10:23:27 sidh2 kernel: [    5.759514] Freeing unused kernel memory: 1796k freed
Dec 24 10:23:27 sidh2 kernel: [    5.812293] udev[107]: starting version 164
Dec 24 10:23:27 sidh2 kernel: [    5.891201] usb 4-2: new low speed USB device using uhci_hcd and address 3
Dec 24 10:23:27 sidh2 kernel: [    6.075049] usb 4-2: New USB device found, idVendor=047b, idProduct=0002
Dec 24 10:23:27 sidh2 kernel: [    6.075053] usb 4-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 24 10:23:27 sidh2 kernel: [    6.075056] usb 4-2: Product: USB Keyboard and Mouse
Dec 24 10:23:27 sidh2 kernel: [    6.075058] usb 4-2: Manufacturer: SILITEK
Dec 24 10:23:27 sidh2 kernel: [    6.119198] input: SILITEK USB Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-2/4-2:1.0/input/input4
Dec 24 10:23:27 sidh2 kernel: [    6.119242] generic-usb 0003:047B:0002.0002: input,hidraw1: USB HID v1.00 Keyboard [SILITEK USB Keyboard and Mouse] on usb-0000:00:1a.1-2/input0
Dec 24 10:23:27 sidh2 kernel: [    6.144069] input: SILITEK USB Keyboard and Mouse as /devices/pci0000:00/0000:00:1a.1/usb4/4-2/4-2:1.1/input/input5
Dec 24 10:23:27 sidh2 kernel: [    6.144140] generic-usb 0003:047B:0002.0003: input,hidraw2: USB HID v1.00 Mouse [SILITEK USB Keyboard and Mouse] on usb-0000:00:1a.1-2/input1
Dec 24 10:23:27 sidh2 kernel: [    6.292011] md: md0 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.292556] md: bind<sdb1>
Dec 24 10:23:27 sidh2 kernel: [    6.292668] md: bind<sda1>
Dec 24 10:23:27 sidh2 kernel: [    6.293290] bio: create slab <bio-1> at 1
Dec 24 10:23:27 sidh2 kernel: [    6.293324] md/raid1:md0: active with 2 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.293335] md0: detected capacity change from 0 to 509804544
Dec 24 10:23:27 sidh2 kernel: [    6.293771] md0: detected capacity change from 0 to 509804544
Dec 24 10:23:27 sidh2 kernel: [    6.300304]  md0: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.328226] md: md1 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.328813] md: bind<sdb5>
Dec 24 10:23:27 sidh2 kernel: [    6.328928] md: bind<sda5>
Dec 24 10:23:27 sidh2 kernel: [    6.330097] md/raid1:md1: active with 2 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.330117] md1: detected capacity change from 0 to 75779342336
Dec 24 10:23:27 sidh2 kernel: [    6.330933] md1: detected capacity change from 0 to 75779342336
Dec 24 10:23:27 sidh2 kernel: [    6.336401]  md1: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.387394] usb 5-2: new low speed USB device using uhci_hcd and address 2
Dec 24 10:23:27 sidh2 kernel: [    6.389044] md: md21 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.389527] md: bind<sdb6>
Dec 24 10:23:27 sidh2 kernel: [    6.389633] md: bind<sda6>
Dec 24 10:23:27 sidh2 kernel: [    6.390250] md/raid1:md21: active with 2 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.390260] md21: detected capacity change from 0 to 76799279104
Dec 24 10:23:27 sidh2 kernel: [    6.390698] md21: detected capacity change from 0 to 76799279104
Dec 24 10:23:27 sidh2 kernel: [    6.396274]  md21: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.455809] md: md100 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.456482] md: bind<sdc1>
Dec 24 10:23:27 sidh2 kernel: [    6.457637] md/raid1:md100: active with 1 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.457658] md100: detected capacity change from 0 to 1019805696
Dec 24 10:23:27 sidh2 kernel: [    6.458471] md100: detected capacity change from 0 to 1019805696
Dec 24 10:23:27 sidh2 kernel: [    6.464367]  md100: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.469798] md: md101 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.470478] md: bind<sdc2>
Dec 24 10:23:27 sidh2 kernel: [    6.472246] md/raid1:md101: active with 1 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.472265] md101: detected capacity change from 0 to 4096181248
Dec 24 10:23:27 sidh2 kernel: [    6.473180] md101: detected capacity change from 0 to 4096181248
Dec 24 10:23:27 sidh2 kernel: [    6.488201]  md101: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.507575] md: md102 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.517517] md: bind<sdc5>
Dec 24 10:23:27 sidh2 kernel: [    6.518202] md/raid1:md102: active with 1 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.518215] md102: detected capacity change from 0 to 34899761152
Dec 24 10:23:27 sidh2 kernel: [    6.518703] md102: detected capacity change from 0 to 34899761152
Dec 24 10:23:27 sidh2 kernel: [    6.565840] usb 5-2: New USB device found, idVendor=1781, idProduct=0898
Dec 24 10:23:27 sidh2 kernel: [    6.565843] usb 5-2: New USB device strings: Mfr=1, Product=2, SerialNumber=0
Dec 24 10:23:27 sidh2 kernel: [    6.565846] usb 5-2: Product: PxRC PhoenixRC USB Interface
Dec 24 10:23:27 sidh2 kernel: [    6.565848] usb 5-2: Manufacturer: Runtime
Dec 24 10:23:27 sidh2 kernel: [    6.568822]  md102: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.584928] generic-usb 0003:1781:0898.0004: hiddev0,hidraw3: USB HID v1.00 Device [Runtime PxRC PhoenixRC USB Interface] on usb-0000:00:1a.2-2/input0
Dec 24 10:23:27 sidh2 kernel: [    6.652131] md: md300 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.658126] md: bind<sdd1>
Dec 24 10:23:27 sidh2 kernel: [    6.658832] md/raid1:md300: active with 1 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.658843] md300: detected capacity change from 0 to 526372864
Dec 24 10:23:27 sidh2 kernel: [    6.659281] md300: detected capacity change from 0 to 526372864
Dec 24 10:23:27 sidh2 kernel: [    6.676590]  md300: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.790221] md: md301 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.791409] md: bind<sdd2>
Dec 24 10:23:27 sidh2 kernel: [    6.792245] md/raid1:md301: active with 1 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.792259] md301: detected capacity change from 0 to 4194877440
Dec 24 10:23:27 sidh2 kernel: [    6.792840] md301: detected capacity change from 0 to 4194877440
Dec 24 10:23:27 sidh2 kernel: [    6.810764]  md301: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    6.865434] md: md302 stopped.
Dec 24 10:23:27 sidh2 kernel: [    6.865997] md: bind<sdd5>
Dec 24 10:23:27 sidh2 kernel: [    6.866601] md/raid1:md302: active with 1 out of 2 mirrors
Dec 24 10:23:27 sidh2 kernel: [    6.866615] md302: detected capacity change from 0 to 20974354432
Dec 24 10:23:27 sidh2 kernel: [    6.867046] md302: detected capacity change from 0 to 20974354432
Dec 24 10:23:27 sidh2 kernel: [    6.872477]  md302: unknown partition table
Dec 24 10:23:27 sidh2 kernel: [    7.214289] PM: Starting manual resume from disk
Dec 24 10:23:27 sidh2 kernel: [    7.246107] EXT3-fs (dm-0): recovery required on readonly filesystem
Dec 24 10:23:27 sidh2 kernel: [    7.246111] EXT3-fs (dm-0): write access will be enabled during recovery
Dec 24 10:23:27 sidh2 kernel: [    7.253697] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [    7.291977] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [    7.291991] EXT3-fs (dm-0): recovery complete
Dec 24 10:23:27 sidh2 kernel: [    7.292989] EXT3-fs (dm-0): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [    8.353328] udev[426]: starting version 164
Dec 24 10:23:27 sidh2 kernel: [    8.535471] pci_hotplug: PCI Hot Plug PCI Core version: 0.5
Dec 24 10:23:27 sidh2 kernel: [    8.539010] shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
Dec 24 10:23:27 sidh2 kernel: [    8.602446] EDAC MC: Ver: 2.1.0 Dec 23 2010
Dec 24 10:23:27 sidh2 kernel: [    8.603035] parport0: PC-style at 0xcf00 [PCSPP,TRISTATE,EPP]
Dec 24 10:23:27 sidh2 kernel: [    8.618390] parport0: Printer, Hewlett-Packard HP LaserJet 1100
Dec 24 10:23:27 sidh2 kernel: [    8.713503] Linux agpgart interface v0.103
Dec 24 10:23:27 sidh2 kernel: [    8.768411] EDAC i7core: Driver loaded.
Dec 24 10:23:27 sidh2 kernel: [    8.846606] udev[460]: renamed network interface eth1 to eth1-eth0
Dec 24 10:23:27 sidh2 kernel: [    8.886583] udev[440]: renamed network interface eth0 to eth1
Dec 24 10:23:27 sidh2 kernel: [    8.910562] udev[460]: renamed network interface eth1-eth0 to eth0
Dec 24 10:23:27 sidh2 kernel: [    9.222006] nvidia: module license 'NVIDIA' taints kernel.
Dec 24 10:23:27 sidh2 kernel: [    9.222008] Disabling lock debugging due to kernel taint
Dec 24 10:23:27 sidh2 kernel: [    9.533656] nvidia 0000:02:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
Dec 24 10:23:27 sidh2 kernel: [    9.533664] nvidia 0000:02:00.0: setting latency timer to 64
Dec 24 10:23:27 sidh2 kernel: [    9.533668] vgaarb: device changed decodes: PCI:0000:02:00.0,olddecodes=io+mem,decodes=none:owns=io+mem
Dec 24 10:23:27 sidh2 kernel: [    9.533759] NVRM: loading NVIDIA UNIX x86_64 Kernel Module  260.19.21  Thu Nov  4 21:16:27 PDT 2010
Dec 24 10:23:27 sidh2 kernel: [   10.993805] EXT3-fs (dm-0): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   11.106085] lp0: using parport0 (polling).
Dec 24 10:23:27 sidh2 kernel: [   13.882151] Adding 3997692k swap on /dev/mapper/rootvg-swap.  Priority:-1 extents:1 across:3997692k 
Dec 24 10:23:27 sidh2 kernel: [   19.172869] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.178765] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.179320] EXT3-fs (dm-31): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.179324] EXT3-fs (dm-31): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.202445] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.208940] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.209488] EXT3-fs (dm-35): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.209492] EXT3-fs (dm-35): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.229080] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.237342] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.237957] EXT3-fs (dm-33): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.237961] EXT3-fs (dm-33): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.273871] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.282650] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.283220] EXT3-fs (dm-32): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.283224] EXT3-fs (dm-32): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.296624] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.298972] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.331023] EXT3-fs (md0): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.331027] EXT3-fs (md0): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.342261] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.347623] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.348162] EXT3-fs (dm-27): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.348165] EXT3-fs (dm-27): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.355363] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.358476] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.359104] EXT3-fs (dm-29): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.359108] EXT3-fs (dm-29): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.373022] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.381730] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.382290] EXT3-fs (dm-34): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.382294] EXT3-fs (dm-34): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.398033] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.404628] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.405189] EXT3-fs (dm-30): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.405193] EXT3-fs (dm-30): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   19.412992] EXT3-fs: barriers not enabled
Dec 24 10:23:27 sidh2 kernel: [   19.416712] kjournald starting.  Commit interval 5 seconds
Dec 24 10:23:27 sidh2 kernel: [   19.417286] EXT3-fs (dm-28): using internal journal
Dec 24 10:23:27 sidh2 kernel: [   19.417290] EXT3-fs (dm-28): mounted filesystem with ordered data mode
Dec 24 10:23:27 sidh2 kernel: [   20.055835] eth1: Link up
Dec 24 10:23:27 sidh2 kernel: [   20.056165] eth1: Link changed: 10Mbps, half duplex
Dec 24 10:23:27 sidh2 kernel: [   20.294381] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294388] WARNING: at net/core/dev.c:2612 netif_rx+0x156/0x190()
Dec 24 10:23:27 sidh2 kernel: [   20.294390] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294392] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294404] Pid: 0, comm: kworker/0:1 Tainted: P            2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294407] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294408]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294417]  [<ffffffff8148c546>] ? netif_rx+0x156/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.294422]  [<ffffffff8125e241>] ? unmap_single+0x31/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294426]  [<ffffffff8125e152>] ? swiotlb_tbl_unmap_single+0x52/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.294431]  [<ffffffff81359003>] ? rx_poll+0x243/0x420
Dec 24 10:23:27 sidh2 kernel: [   20.294435]  [<ffffffff8105facf>] ? tasklet_action+0xef/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.294438]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294442]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.294445]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294448]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294451]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294456]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.294458]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.294465]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294469]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.294472] ---[ end trace 5fd8282097138a2d ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294477] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294482] WARNING: at net/core/dev.c:2907 __netif_receive_skb+0x6a4/0x6c0()
Dec 24 10:23:27 sidh2 kernel: [   20.294484] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294485] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294495] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294497] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294498]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294505]  [<ffffffff81486434>] ? __netif_receive_skb+0x6a4/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.294509]  [<ffffffff8125da20>] ? swiotlb_dma_mapping_error+0x10/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.294513]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294516]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.294519]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294522]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.294525]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294528]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294531]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294534]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.294536]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.294542]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294545]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.294548] ---[ end trace 5fd8282097138a2e ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294551] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294554] WARNING: at net/core/skbuff.c:580 __skb_clone+0x10a/0x110()
Dec 24 10:23:27 sidh2 kernel: [   20.294556] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294557] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294567] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294569] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294570]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294576]  [<ffffffff8147bd3a>] ? __skb_clone+0x10a/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.294581]  [<ffffffff81547442>] ? packet_rcv+0x142/0x450
Dec 24 10:23:27 sidh2 kernel: [   20.294585]  [<ffffffff814860ba>] ? __netif_receive_skb+0x32a/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.294588]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294592]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.294595]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294598]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.294601]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294604]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294607]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294610]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.294612]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.294618]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294621]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.294623] ---[ end trace 5fd8282097138a2f ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294625] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294628] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.294629] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294631] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294640] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294642] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294643]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294649]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.294653]  [<ffffffff8154747e>] ? packet_rcv+0x17e/0x450
Dec 24 10:23:27 sidh2 kernel: [   20.294657]  [<ffffffff814860ba>] ? __netif_receive_skb+0x32a/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.294660]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294664]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.294667]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294670]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.294673]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294676]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294678]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294682]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.294684]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.294690]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294693]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.294695] ---[ end trace 5fd8282097138a30 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294698] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294701] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.294702] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294704] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294714] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294715] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294717]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294722]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.294725]  [<ffffffff8135f760>] ? pppoe_disc_rcv+0x80/0x250
Dec 24 10:23:27 sidh2 kernel: [   20.294729]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.294733]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294736]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.294740]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294742]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.294745]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294748]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294751]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294755]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.294756]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.294762]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294766]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.294768] ---[ end trace 5fd8282097138a31 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294769] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294772] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.294774] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294775] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294785] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294787] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294788]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294794]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.294797]  [<ffffffff8135f760>] ? pppoe_disc_rcv+0x80/0x250
Dec 24 10:23:27 sidh2 kernel: [   20.294800]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.294804]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294807]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.294811]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.294814]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.294817]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294824]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.294828]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294831]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.294833]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.294839]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294842]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.294845] ---[ end trace 5fd8282097138a32 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294856] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294859] WARNING: at net/core/skbuff.c:455 consume_skb+0xaf/0xc0()
Dec 24 10:23:27 sidh2 kernel: [   20.294861] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294862] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294872] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294874] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294877]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294880]  [<ffffffff8147c8df>] ? consume_skb+0xaf/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294884]  [<ffffffff81480c8c>] ? skb_free_datagram+0xc/0x40
Dec 24 10:23:27 sidh2 kernel: [   20.294887]  [<ffffffff81549238>] ? packet_recvmsg+0x2e8/0x4d0
Dec 24 10:23:27 sidh2 kernel: [   20.294892]  [<ffffffff814748bd>] ? sock_recvmsg+0xed/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294898]  [<ffffffff8116c8e8>] ? compat_core_sys_select+0x288/0x2a0
Dec 24 10:23:27 sidh2 kernel: [   20.294901]  [<ffffffff81473902>] ? sockfd_lookup_light+0x22/0x80
Dec 24 10:23:27 sidh2 kernel: [   20.294905]  [<ffffffff81474a63>] ? sys_recvfrom+0xf3/0x180
Dec 24 10:23:27 sidh2 kernel: [   20.294908]  [<ffffffff815479da>] ? packet_bind+0x6a/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294912]  [<ffffffff81474c5f>] ? sys_bind+0xcf/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294915]  [<ffffffff81012f75>] ? read_tsc+0x5/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.294920]  [<ffffffff81083701>] ? ktime_get_ts+0x61/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.294925]  [<ffffffff814a1b5c>] ? compat_sys_socketcall+0x13c/0x210
Dec 24 10:23:27 sidh2 kernel: [   20.294928]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.294930] ---[ end trace 5fd8282097138a33 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.294932] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.294934] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.294936] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.294937] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.294947] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.294949] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.294952]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.294955]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.294959]  [<ffffffff81480c8c>] ? skb_free_datagram+0xc/0x40
Dec 24 10:23:27 sidh2 kernel: [   20.294962]  [<ffffffff81549238>] ? packet_recvmsg+0x2e8/0x4d0
Dec 24 10:23:27 sidh2 kernel: [   20.294966]  [<ffffffff814748bd>] ? sock_recvmsg+0xed/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.294970]  [<ffffffff8116c8e8>] ? compat_core_sys_select+0x288/0x2a0
Dec 24 10:23:27 sidh2 kernel: [   20.294973]  [<ffffffff81473902>] ? sockfd_lookup_light+0x22/0x80
Dec 24 10:23:27 sidh2 kernel: [   20.294977]  [<ffffffff81474a63>] ? sys_recvfrom+0xf3/0x180
Dec 24 10:23:27 sidh2 kernel: [   20.294980]  [<ffffffff815479da>] ? packet_bind+0x6a/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.294983]  [<ffffffff81474c5f>] ? sys_bind+0xcf/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.294987]  [<ffffffff81012f75>] ? read_tsc+0x5/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.294990]  [<ffffffff81083701>] ? ktime_get_ts+0x61/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.294994]  [<ffffffff814a1b5c>] ? compat_sys_socketcall+0x13c/0x210
Dec 24 10:23:27 sidh2 kernel: [   20.294997]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.294999] ---[ end trace 5fd8282097138a34 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.333302] r8169 0000:08:00.0: eth0: link up
Dec 24 10:23:27 sidh2 kernel: [   20.333308] r8169 0000:08:00.0: eth0: link up
Dec 24 10:23:27 sidh2 kernel: [   20.513542] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.513550] WARNING: at net/core/dev.c:2612 netif_rx+0x156/0x190()
Dec 24 10:23:27 sidh2 kernel: [   20.513552] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.513554] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.513566] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.513569] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.513570]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.513579]  [<ffffffff8148c546>] ? netif_rx+0x156/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.513584]  [<ffffffff8125e241>] ? unmap_single+0x31/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513588]  [<ffffffff8125e152>] ? swiotlb_tbl_unmap_single+0x52/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.513593]  [<ffffffff81359003>] ? rx_poll+0x243/0x420
Dec 24 10:23:27 sidh2 kernel: [   20.513597]  [<ffffffff8105facf>] ? tasklet_action+0xef/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.513601]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513604]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.513608]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.513611]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513613]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.513618]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.513620]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.513628]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.513632]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.513634] ---[ end trace 5fd8282097138a35 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.513640] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.513645] WARNING: at net/core/dev.c:2907 __netif_receive_skb+0x6a4/0x6c0()
Dec 24 10:23:27 sidh2 kernel: [   20.513647] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.513648] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.513658] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.513660] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.513662]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.513668]  [<ffffffff81486434>] ? __netif_receive_skb+0x6a4/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.513672]  [<ffffffff8125da20>] ? swiotlb_dma_mapping_error+0x10/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.513676]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513679]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.513682]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513685]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.513688]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.513691]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513694]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.513697]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.513699]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.513705]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.513709]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.513711] ---[ end trace 5fd8282097138a36 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.513715] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.513717] WARNING: at net/core/skbuff.c:580 __skb_clone+0x10a/0x110()
Dec 24 10:23:27 sidh2 kernel: [   20.513719] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.513720] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.513730] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.513732] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.513733]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.513739]  [<ffffffff8147bd3a>] ? __skb_clone+0x10a/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.513745]  [<ffffffff81547442>] ? packet_rcv+0x142/0x450
Dec 24 10:23:27 sidh2 kernel: [   20.513748]  [<ffffffff814860ba>] ? __netif_receive_skb+0x32a/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.513752]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513755]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.513759]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513761]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.513764]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.513767]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513770]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.513774]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.513775]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.513782]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.513785]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.513787] ---[ end trace 5fd8282097138a37 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.513788] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.513791] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.513793] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.513794] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.513804] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.513806] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.513807]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.513813]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.513816]  [<ffffffff8154747e>] ? packet_rcv+0x17e/0x450
Dec 24 10:23:27 sidh2 kernel: [   20.513820]  [<ffffffff814860ba>] ? __netif_receive_skb+0x32a/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.513824]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513827]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.513830]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513833]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.513836]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.513839]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513842]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.513846]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.513847]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.513853]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.513856]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.513859] ---[ end trace 5fd8282097138a38 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.513862] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.513865] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.513867] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.513868] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.513878] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.513880] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.513881]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.513887]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.513890]  [<ffffffff8135f760>] ? pppoe_disc_rcv+0x80/0x250
Dec 24 10:23:27 sidh2 kernel: [   20.513894]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.513897]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513900]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.513904]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513907]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.513910]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.513913]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513915]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.513919]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.513920]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.513927]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.513930]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.513932] ---[ end trace 5fd8282097138a39 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.513933] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.513936] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.513938] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.513939] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.513949] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.513951] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.513952]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.513958]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.513961]  [<ffffffff8135f760>] ? pppoe_disc_rcv+0x80/0x250
Dec 24 10:23:27 sidh2 kernel: [   20.513965]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.513969]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513972]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.513975]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.513978]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.513981]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.513984]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.513986]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.513990]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.513992]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.513998]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.514001]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.514003] ---[ end trace 5fd8282097138a3a ]---
Dec 24 10:23:27 sidh2 kernel: [   20.514015] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.514018] WARNING: at net/core/skbuff.c:455 consume_skb+0xaf/0xc0()
Dec 24 10:23:27 sidh2 kernel: [   20.514020] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.514021] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.514031] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.514033] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.514036]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.514040]  [<ffffffff8147c8df>] ? consume_skb+0xaf/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.514045]  [<ffffffff81480c8c>] ? skb_free_datagram+0xc/0x40
Dec 24 10:23:27 sidh2 kernel: [   20.514050]  [<ffffffff81549238>] ? packet_recvmsg+0x2e8/0x4d0
Dec 24 10:23:27 sidh2 kernel: [   20.514056]  [<ffffffff810e27f8>] ? find_get_page+0x18/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.514062]  [<ffffffff814748bd>] ? sock_recvmsg+0xed/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.514069]  [<ffffffff8116c8e8>] ? compat_core_sys_select+0x288/0x2a0
Dec 24 10:23:27 sidh2 kernel: [   20.514074]  [<ffffffff81473902>] ? sockfd_lookup_light+0x22/0x80
Dec 24 10:23:27 sidh2 kernel: [   20.514079]  [<ffffffff81474a63>] ? sys_recvfrom+0xf3/0x180
Dec 24 10:23:27 sidh2 kernel: [   20.514084]  [<ffffffff815479da>] ? packet_bind+0x6a/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.514089]  [<ffffffff81474c5f>] ? sys_bind+0xcf/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.514094]  [<ffffffff81012f75>] ? read_tsc+0x5/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.514099]  [<ffffffff81083701>] ? ktime_get_ts+0x61/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.514106]  [<ffffffff814a1b5c>] ? compat_sys_socketcall+0x13c/0x210
Dec 24 10:23:27 sidh2 kernel: [   20.514111]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.514114] ---[ end trace 5fd8282097138a3b ]---
Dec 24 10:23:27 sidh2 kernel: [   20.514116] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.514120] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.514123] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.514125] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.514138] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.514141] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.514146]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.514150]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.514155]  [<ffffffff81480c8c>] ? skb_free_datagram+0xc/0x40
Dec 24 10:23:27 sidh2 kernel: [   20.514160]  [<ffffffff81549238>] ? packet_recvmsg+0x2e8/0x4d0
Dec 24 10:23:27 sidh2 kernel: [   20.514165]  [<ffffffff810e27f8>] ? find_get_page+0x18/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.514170]  [<ffffffff814748bd>] ? sock_recvmsg+0xed/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.514176]  [<ffffffff8116c8e8>] ? compat_core_sys_select+0x288/0x2a0
Dec 24 10:23:27 sidh2 kernel: [   20.514182]  [<ffffffff81473902>] ? sockfd_lookup_light+0x22/0x80
Dec 24 10:23:27 sidh2 kernel: [   20.514187]  [<ffffffff81474a63>] ? sys_recvfrom+0xf3/0x180
Dec 24 10:23:27 sidh2 kernel: [   20.514193]  [<ffffffff815479da>] ? packet_bind+0x6a/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.514198]  [<ffffffff81474c5f>] ? sys_bind+0xcf/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.514203]  [<ffffffff81012f75>] ? read_tsc+0x5/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.514208]  [<ffffffff81083701>] ? ktime_get_ts+0x61/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.514213]  [<ffffffff814a1b5c>] ? compat_sys_socketcall+0x13c/0x210
Dec 24 10:23:27 sidh2 kernel: [   20.514218]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.514221] ---[ end trace 5fd8282097138a3c ]---
Dec 24 10:23:27 sidh2 kernel: [   20.528729] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.528734] WARNING: at net/core/dev.c:2612 netif_rx+0x156/0x190()
Dec 24 10:23:27 sidh2 kernel: [   20.528736] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.528737] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.528748] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.528751] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.528752]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.528759]  [<ffffffff8148c546>] ? netif_rx+0x156/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.528763]  [<ffffffff8125e241>] ? unmap_single+0x31/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.528767]  [<ffffffff8125e152>] ? swiotlb_tbl_unmap_single+0x52/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.528771]  [<ffffffff81359003>] ? rx_poll+0x243/0x420
Dec 24 10:23:27 sidh2 kernel: [   20.528774]  [<ffffffff8105facf>] ? tasklet_action+0xef/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.528778]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.528781]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.528784]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.528787]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.528789]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.528793]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.528795]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.528802]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.528805]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.528808] ---[ end trace 5fd8282097138a3d ]---
Dec 24 10:23:27 sidh2 kernel: [   20.528812] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.528816] WARNING: at net/core/dev.c:2907 __netif_receive_skb+0x6a4/0x6c0()
Dec 24 10:23:27 sidh2 kernel: [   20.528818] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.528819] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.528829] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.528831] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.528832]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.528839]  [<ffffffff81486434>] ? __netif_receive_skb+0x6a4/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.528843]  [<ffffffff8125da20>] ? swiotlb_dma_mapping_error+0x10/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.528847]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.528850]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.528853]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.528856]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.528859]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.528862]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.528865]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.528868]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.528870]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.528876]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.528880]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.528882] ---[ end trace 5fd8282097138a3e ]---
Dec 24 10:23:27 sidh2 kernel: [   20.528884] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.528887] WARNING: at drivers/net/pppoe.c:434 pppoe_rcv+0x269/0x300()
Dec 24 10:23:27 sidh2 kernel: [   20.528889] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.528890] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.528906] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.528908] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.528909]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.528915]  [<ffffffff8135e979>] ? pppoe_rcv+0x269/0x300
Dec 24 10:23:27 sidh2 kernel: [   20.528919]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.528923]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.528926]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.528929]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.528932]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.528935]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.528938]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.528941]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.528944]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.528946]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.528952]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.528955]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.528957] ---[ end trace 5fd8282097138a3f ]---
Dec 24 10:23:27 sidh2 kernel: [   20.528959] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.528962] WARNING: at drivers/net/pppoe.c:457 pppoe_rcv+0x2e3/0x300()
Dec 24 10:23:27 sidh2 kernel: [   20.528964] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.528965] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.528975] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.528977] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.528978]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.528983]  [<ffffffff8135e9f3>] ? pppoe_rcv+0x2e3/0x300
Dec 24 10:23:27 sidh2 kernel: [   20.528987]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.528991]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.528994]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.528998]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529001]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529003]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529007]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529009]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529013]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529014]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529021]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529024]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529026] ---[ end trace 5fd8282097138a40 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529028] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529031] WARNING: at drivers/net/pppoe.c:388 pppoe_rcv_core+0x22c/0x240()
Dec 24 10:23:27 sidh2 kernel: [   20.529032] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529034] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529043] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529045] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529046]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529052]  [<ffffffff8135f14c>] ? pppoe_rcv_core+0x22c/0x240
Dec 24 10:23:27 sidh2 kernel: [   20.529055]  [<ffffffff8147a8a4>] ? sk_receive_skb+0x114/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.529059]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.529063]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529066]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.529069]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529072]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529075]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529078]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529081]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529084]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529086]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529092]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529095]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529098] ---[ end trace 5fd8282097138a41 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529102] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529105] WARNING: at net/core/dev.c:2612 netif_rx+0x156/0x190()
Dec 24 10:23:27 sidh2 kernel: [   20.529107] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529108] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529118] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529120] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529121]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529126]  [<ffffffff8148c546>] ? netif_rx+0x156/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.529130]  [<ffffffff8125e241>] ? unmap_single+0x31/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529134]  [<ffffffff8125e152>] ? swiotlb_tbl_unmap_single+0x52/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.529137]  [<ffffffff81359003>] ? rx_poll+0x243/0x420
Dec 24 10:23:27 sidh2 kernel: [   20.529141]  [<ffffffff8105facf>] ? tasklet_action+0xef/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.529144]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529147]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529149]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529152]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529155]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529159]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529160]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529167]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529170]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529172] ---[ end trace 5fd8282097138a42 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529176] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529179] WARNING: at net/core/dev.c:2907 __netif_receive_skb+0x6a4/0x6c0()
Dec 24 10:23:27 sidh2 kernel: [   20.529181] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529182] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529192] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529194] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529195]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529201]  [<ffffffff81486434>] ? __netif_receive_skb+0x6a4/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.529205]  [<ffffffff8125da20>] ? swiotlb_dma_mapping_error+0x10/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.529209]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529212]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.529215]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529218]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529221]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529224]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529227]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529231]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529232]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529238]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529241]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529244] ---[ end trace 5fd8282097138a43 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529245] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529248] WARNING: at drivers/net/pppoe.c:434 pppoe_rcv+0x269/0x300()
Dec 24 10:23:27 sidh2 kernel: [   20.529250] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529251] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529261] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529263] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529264]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529269]  [<ffffffff8135e979>] ? pppoe_rcv+0x269/0x300
Dec 24 10:23:27 sidh2 kernel: [   20.529273]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.529277]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529280]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.529283]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529286]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529289]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529292]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529295]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529299]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529300]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529306]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529309]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529312] ---[ end trace 5fd8282097138a44 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529313] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529316] WARNING: at drivers/net/pppoe.c:457 pppoe_rcv+0x2e3/0x300()
Dec 24 10:23:27 sidh2 kernel: [   20.529318] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529319] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529329] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529330] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529332]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529337]  [<ffffffff8135e9f3>] ? pppoe_rcv+0x2e3/0x300
Dec 24 10:23:27 sidh2 kernel: [   20.529341]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.529345]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529348]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.529351]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529354]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529357]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529360]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529363]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529366]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529368]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529374]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529377]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529380] ---[ end trace 5fd8282097138a45 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529381] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529384] WARNING: at drivers/net/pppoe.c:388 pppoe_rcv_core+0x22c/0x240()
Dec 24 10:23:27 sidh2 kernel: [   20.529386] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529387] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529397] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529399] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529400]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529405]  [<ffffffff8135f14c>] ? pppoe_rcv_core+0x22c/0x240
Dec 24 10:23:27 sidh2 kernel: [   20.529409]  [<ffffffff8147a8a4>] ? sk_receive_skb+0x114/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.529412]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.529416]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529419]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.529422]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.529425]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529428]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.529431]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529434]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.529438]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.529439]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.529445]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.529448]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.529451] ---[ end trace 5fd8282097138a46 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529462] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529466] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.529467] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529469] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529478] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529480] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529484]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529487]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.529490]  [<ffffffff8135a332>] ? ppp_read+0x162/0x1c0
Dec 24 10:23:27 sidh2 kernel: [   20.529494]  [<ffffffff81053060>] ? default_wake_function+0x0/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.529499]  [<ffffffff8112b5d5>] ? vfs_read+0xc5/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.529503]  [<ffffffff8112bc5e>] ? sys_read+0x4e/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529506]  [<ffffffff81565315>] ? page_fault+0x25/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529509]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.529512] ---[ end trace 5fd8282097138a47 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529513] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529516] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.529518] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529519] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529529] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529530] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529534]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529537]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.529540]  [<ffffffff8135a332>] ? ppp_read+0x162/0x1c0
Dec 24 10:23:27 sidh2 kernel: [   20.529544]  [<ffffffff81053060>] ? default_wake_function+0x0/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.529548]  [<ffffffff8112b5d5>] ? vfs_read+0xc5/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.529551]  [<ffffffff8112bc5e>] ? sys_read+0x4e/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529554]  [<ffffffff81565315>] ? page_fault+0x25/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.529557]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.529559] ---[ end trace 5fd8282097138a48 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529577] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529580] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.529582] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529583] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529593] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529595] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529598]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529601]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.529605]  [<ffffffff8135a332>] ? ppp_read+0x162/0x1c0
Dec 24 10:23:27 sidh2 kernel: [   20.529608]  [<ffffffff81053060>] ? default_wake_function+0x0/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.529612]  [<ffffffff8112b5d5>] ? vfs_read+0xc5/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.529616]  [<ffffffff8112bc5e>] ? sys_read+0x4e/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529621]  [<ffffffff810a013f>] ? compat_sys_gettimeofday+0x9f/0xb0
Dec 24 10:23:27 sidh2 kernel: [   20.529624]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.529626] ---[ end trace 5fd8282097138a49 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.529627] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.529630] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.529632] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.529633] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.529651] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.529653] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.529656]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.529659]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.529663]  [<ffffffff8135a332>] ? ppp_read+0x162/0x1c0
Dec 24 10:23:27 sidh2 kernel: [   20.529666]  [<ffffffff81053060>] ? default_wake_function+0x0/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.529670]  [<ffffffff8112b5d5>] ? vfs_read+0xc5/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.529674]  [<ffffffff8112bc5e>] ? sys_read+0x4e/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.529677]  [<ffffffff810a013f>] ? compat_sys_gettimeofday+0x9f/0xb0
Dec 24 10:23:27 sidh2 kernel: [   20.529680]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.529682] ---[ end trace 5fd8282097138a4a ]---
Dec 24 10:23:27 sidh2 kernel: [   20.536724] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.536728] WARNING: at net/core/dev.c:2612 netif_rx+0x156/0x190()
Dec 24 10:23:27 sidh2 kernel: [   20.536730] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.536731] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.536741] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.536743] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.536745]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.536751]  [<ffffffff8148c546>] ? netif_rx+0x156/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.536755]  [<ffffffff8125e241>] ? unmap_single+0x31/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.536758]  [<ffffffff8125e152>] ? swiotlb_tbl_unmap_single+0x52/0x110
Dec 24 10:23:27 sidh2 kernel: [   20.536762]  [<ffffffff81359003>] ? rx_poll+0x243/0x420
Dec 24 10:23:27 sidh2 kernel: [   20.536765]  [<ffffffff8105facf>] ? tasklet_action+0xef/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.536769]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536772]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.536775]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.536778]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.536780]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.536784]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.536786]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.536792]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.536795]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.536798] ---[ end trace 5fd8282097138a4b ]---
Dec 24 10:23:27 sidh2 kernel: [   20.536802] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.536806] WARNING: at net/core/dev.c:2907 __netif_receive_skb+0x6a4/0x6c0()
Dec 24 10:23:27 sidh2 kernel: [   20.536807] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.536809] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.536818] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.536820] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.536821]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.536828]  [<ffffffff81486434>] ? __netif_receive_skb+0x6a4/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.536832]  [<ffffffff8125da20>] ? swiotlb_dma_mapping_error+0x10/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.536836]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536839]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.536842]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536845]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.536848]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.536851]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.536854]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.536857]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.536859]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.536865]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.536868]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.536870] ---[ end trace 5fd8282097138a4c ]---
Dec 24 10:23:27 sidh2 kernel: [   20.536872] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.536875] WARNING: at drivers/net/pppoe.c:434 pppoe_rcv+0x269/0x300()
Dec 24 10:23:27 sidh2 kernel: [   20.536877] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.536878] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.536888] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.536889] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.536891]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.536896]  [<ffffffff8135e979>] ? pppoe_rcv+0x269/0x300
Dec 24 10:23:27 sidh2 kernel: [   20.536900]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.536904]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536907]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.536910]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536913]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.536916]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.536919]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.536922]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.536926]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.536927]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.536933]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.536936]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.536939] ---[ end trace 5fd8282097138a4d ]---
Dec 24 10:23:27 sidh2 kernel: [   20.536940] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.536943] WARNING: at drivers/net/pppoe.c:457 pppoe_rcv+0x2e3/0x300()
Dec 24 10:23:27 sidh2 kernel: [   20.536945] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.536946] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.536956] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.536958] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.536959]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.536964]  [<ffffffff8135e9f3>] ? pppoe_rcv+0x2e3/0x300
Dec 24 10:23:27 sidh2 kernel: [   20.536968]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.536972]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536975]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.536978]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.536981]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.536984]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.536987]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.536990]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.536993]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.536995]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.537001]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.537004]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.537007] ---[ end trace 5fd8282097138a4e ]---
Dec 24 10:23:27 sidh2 kernel: [   20.537008] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.537011] WARNING: at drivers/net/pppoe.c:388 pppoe_rcv_core+0x22c/0x240()
Dec 24 10:23:27 sidh2 kernel: [   20.537013] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.537014] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.537024] Pid: 0, comm: kworker/0:1 Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.537026] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.537027]  <IRQ>  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.537033]  [<ffffffff8135f14c>] ? pppoe_rcv_core+0x22c/0x240
Dec 24 10:23:27 sidh2 kernel: [   20.537036]  [<ffffffff8147a8a4>] ? sk_receive_skb+0x114/0x130
Dec 24 10:23:27 sidh2 kernel: [   20.537040]  [<ffffffff814861b2>] ? __netif_receive_skb+0x422/0x6c0
Dec 24 10:23:27 sidh2 kernel: [   20.537043]  [<ffffffff81486552>] ? process_backlog+0x102/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.537046]  [<ffffffff8148c25e>] ? net_rx_action+0xfe/0x290
Dec 24 10:23:27 sidh2 kernel: [   20.537050]  [<ffffffff8105f76e>] ? __do_softirq+0xae/0x200
Dec 24 10:23:27 sidh2 kernel: [   20.537053]  [<ffffffff8100be5c>] ? call_softirq+0x1c/0x30
Dec 24 10:23:27 sidh2 kernel: [   20.537056]  [<ffffffff8100e1d5>] ? do_softirq+0x65/0xa0
Dec 24 10:23:27 sidh2 kernel: [   20.537059]  [<ffffffff8105f655>] ? irq_exit+0x85/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.537061]  [<ffffffff8100d757>] ? do_IRQ+0x67/0xe0
Dec 24 10:23:27 sidh2 kernel: [   20.537065]  [<ffffffff81565053>] ? ret_from_intr+0x0/0x11
Dec 24 10:23:27 sidh2 kernel: [   20.537066]  <EOI>  [<ffffffff8101469f>] ? mwait_idle+0x7f/0xf0
Dec 24 10:23:27 sidh2 kernel: [   20.537073]  [<ffffffff81009e72>] ? cpu_idle+0xb2/0x140
Dec 24 10:23:27 sidh2 kernel: [   20.537076]  [<ffffffff8155e4c1>] ? start_secondary+0x1e6/0x1eb
Dec 24 10:23:27 sidh2 kernel: [   20.537078] ---[ end trace 5fd8282097138a4f ]---
Dec 24 10:23:27 sidh2 kernel: [   20.537085] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.537088] WARNING: at net/core/skbuff.c:433 kfree_skb+0xc8/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.537090] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.537091] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.537101] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.537103] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.537106]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.537109]  [<ffffffff8147c9b8>] ? kfree_skb+0xc8/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.537113]  [<ffffffff8135a332>] ? ppp_read+0x162/0x1c0
Dec 24 10:23:27 sidh2 kernel: [   20.537116]  [<ffffffff81053060>] ? default_wake_function+0x0/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.537120]  [<ffffffff8112b5d5>] ? vfs_read+0xc5/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.537124]  [<ffffffff8112bc5e>] ? sys_read+0x4e/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.537127]  [<ffffffff810a013f>] ? compat_sys_gettimeofday+0x9f/0xb0
Dec 24 10:23:27 sidh2 kernel: [   20.537130]  [<ffffffff81040940>] ? sysenter_dispatch+0x7/0x2e
Dec 24 10:23:27 sidh2 kernel: [   20.537133] ---[ end trace 5fd8282097138a50 ]---
Dec 24 10:23:27 sidh2 kernel: [   20.537134] ------------[ cut here ]------------
Dec 24 10:23:27 sidh2 kernel: [   20.537137] WARNING: at net/core/skbuff.c:416 __kfree_skb+0xc1/0xd0()
Dec 24 10:23:27 sidh2 kernel: [   20.537139] Hardware name: EX58-UD3R
Dec 24 10:23:27 sidh2 kernel: [   20.537140] Modules linked in: lp nvidia(P) tpm_tis tpm i7core_edac agpgart tpm_bios parport_pc edac_core parport shpchp pci_hotplug [last unloaded: scsi_wait_scan]
Dec 24 10:23:27 sidh2 kernel: [   20.537149] Pid: 1649, comm: pppd Tainted: P        W   2.6.37-rc7-amd64-t2 #2
Dec 24 10:23:27 sidh2 kernel: [   20.537151] Call Trace:
Dec 24 10:23:27 sidh2 kernel: [   20.537155]  [<ffffffff81058e1b>] ? warn_slowpath_common+0x7b/0xc0
Dec 24 10:23:27 sidh2 kernel: [   20.537158]  [<ffffffff8147c821>] ? __kfree_skb+0xc1/0xd0
Dec 24 10:23:27 sidh2 kernel: [   20.537161]  [<ffffffff8135a332>] ? ppp_read+0x162/0x1c0
Dec 24 10:23:27 sidh2 kernel: [   20.537165]  [<ffffffff81053060>] ? default_wake_function+0x0/0x20
Dec 24 10:23:27 sidh2 kernel: [   20.537168]  [<ffffffff8112b5d5>] ? vfs_read+0xc5/0x190
Dec 24 10:23:27 sidh2 kernel: [   20.537172]  [<ffffffff8112bc5e>] ? sys_read+0x4e/0x90
Dec 24 10:23:27 sidh2 kernel: [   20.537175]  [<ffffffff810a013f>] ? compat_sys_gettimeofday+0x9f/0xb0

--0OAP2g/MAC+5xKAE--
