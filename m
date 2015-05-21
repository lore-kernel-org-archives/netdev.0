From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-05-21
Date: Thu, 21 May 2015 16:39:04 +0300
Message-ID: <87k2w26oef.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	michal.kazior-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a wireless-drivers pull request for 4.2. This time please pay
extra attention to this pull as there are two problems:

=46irst of all as you can see the diffstat from git-pull-request in the
end is just weird. I was long and hard trying to check everything and t=
o
my understanding all the merges look ok and I cannot explain the reason
for the diffstat, but of course I might be missing something. Maybe
git-request-pull is just buggy? At least with gitk everything looks to
be ok and the patch list below also looks valid.

Secondly there's a non-trivial conflict in
drivers/net/wireless/ath/ath10k/mac.c which is due to removal of
=46IF_PROMISC_IN_BSS in commit df1404650c. You need to remove more code
than just the obvious conflicts shown by git. In the end of this mail I
added a git diff output after I fixed the conflict, hopefully that help=
s
you to fix it. The main points are that you remove
ath10k_mac_should_disable_promisc() and the last ath10k_monitor_recalc(=
)
call from ath10k_vdev_start_restart() along with the obvious conflict
fixes git points out.

There's also a patch from Michal which will also help to fix the
resolution. Michal, please double check the resolution proposal below s=
o
that I didn't miss anything.

https://patchwork.kernel.org/patch/6387631/

Please let me know if there are any problems.

Kalle

The following changes since commit e7afe89fd67d40a7f5fff8130c5f925d99a9=
4b1f:

  iwlwifi: mvm: force quota update update after FW restart (2015-04-28 =
15:02:25 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-05-21

for you to fetch changes up to 6e65104504feaff41848defcef9c2c16c119f90c=
:

  brcmfmac: check result of USB firmware request (2015-05-09 17:00:46 +=
0300)

----------------------------------------------------------------
ath10k:

* enable channel 144 on 5 GHz
* enable Adaptive Noise Immunity (ANI) by default
* add Wake on Wireless LAN (WOW) patterns support
* add basic Tunneled Direct Link Setup (TDLS) support
* add multi-channel support for QCA6174
* enable IBSS RSN support
* enable Bluetooth Coexistance whenever firmware supports it
* add more versatile way to set bitrates used by the firmware

ath9k:

* spectral scan: add support for multiple FFT frames per report

iwlwifi:

* major rework of the scan code (Luca)
* some work on the thermal code (Chaya Rachel)
* some work on the firwmare debugging infrastructure

brcmfmac:

* SDIO suspend and resume fixes
* wiphy band info and changes in regulatory settings
* add support for BCM4324 SDIO and BCM4358 PCIe
* enable support of PCIe devices on router platforms (Hante)

----------------------------------------------------------------
Arend van Spriel (8):
      brcmfmac: use static superset of channels for wiphy bands
      brcmfmac: update wiphy band information upon updating regulatory =
domain
      brcmfmac: add description for feature flags
      brcmfmac: make scheduled scan support conditional
      brcmfmac: add support for BCM4324 rev B5 chipset
      brcmfmac: process interrupt regardless sdiod state
      brcmfmac: fix sdio suspend and resume
      brcmfmac: add support for BCM4358 PCIe device

Arik Nemtsov (1):
      iwlwifi: mvm: iterate all interfaces during HW recovery cleanup

Ashok Raj Nagarajan (2):
      ath10k: enable Adaptive Noise Immunity (ANI) by default
      ath10k: allow user to toggle ani_enable via debugfs

Avinash Patil (1):
      revert "mwifiex: enable aggregation for TID 6 and 7 streams"

Bartosz Markowski (2):
      ath10k: update MODULE_FIRMWARE definitions for QCA6174
      ath10k: fix PMF by using AES-CMAC/IGTK software crypto

Cathy Luo (1):
      mwifiex: reduce spinlock usage in main process

Chaya Rachel Ivgi (1):
      iwlwifi: mvm: make thermal throttling values configurable per NIC=
 family

Dan Carpenter (1):
      brcmfmac: cleanup a sizeof()

David Spinadel (2):
      iwlwifi: mvm: remove deprecated command IDs
      iwlwifi: mvm: include wildcard SSID in scans

Dmitry Torokhov (1):
      mwifiex: do not return success when command times out

Eliad Peller (2):
      iwlwifi: mvm: avoid use-after-free on iwl_mvm_d0i3_enable_tx() [B=
UGFIX]
      wl18xx: fallback to default conf in case of invalid conf file

Emmanuel Grumbach (4):
      Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-=
next
      iwlwifi: mvm: allow scheduled scan for all the firmwares
      iwlwifi: clarify the device / firmware mapping in Kconfig
      iwlwifi: allow to limit the size of the external buffer for firmw=
are debugging

Eyal Reizer (1):
      wl18xx: wlan_irq: support platform dependent interrupt types

Eyal Shapira (1):
      iwlwifi: rs: cleanup last_txrate_idx

=46elix Fietkau (2):
      bcma: use absolute base for SoC GPIO pins
      bcma: enable 32 GPIO pins for BCM4707

Hante Meuleman (2):
      brcmfmac: add additional 43602 pcie device id.
      brcmfmac: Add support for multiple PCIE devices in nvram.

Janusz Dziedzic (6):
      ath10k: add WMI support for WOW
      ath10k: add WOW disconnect/magic-packet support
      ath10k: add WMI support for WOW patterns
      ath10k: add WOW patterns support
      ath10k: disable burst mode
      ath10k: enable ibss-rsn

Janusz.Dziedzic-++hxYGjEMp0AvxtiuMwx3w@public.gmane.org (1):
      ath10k: setup maximum number of supported stations

Johannes Berg (1):
      iwlwifi: mvm: don't reset key index on HW restart

Kalle Valo (5):
      ath10k: bump up FW API to 5
      Merge mac80211-next into ath-next
      ath10k: fix HTT op backwards compatibility for QCA6174
      Merge ath-next from ath.git
      Merge tag 'iwlwifi-next-for-kalle-2015-05-03' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next

Liad Kaufman (3):
      iwlwifi: rs: remove code duplication when filling lq cmd
      iwlwifi: pcie: support marbh fw dbg mode
      iwlwifi: rs: remove unneeded check of average tpt in window

Luciano Coelho (28):
      iwlwifi: mvm: add scan parameters debugging info
      iwlwifi: mvm: don't increase max_out_time when low priority scan =
is requested
      iwlwifi: mvm: convert scan_status to a bitmap
      iwlwifi: mvm: don't wait for scan stopped work when cancelling sc=
ans
      iwlwifi: mvm: check if scan can be started before cancelling othe=
r scans
      iwlwifi: mvm: generalize the other-scan stopping code
      iwlwifi: mvm: rename unified_scan symbols to just scan
      iwlwifi: mvm: move scan code from mac80211.c to scan.c
      iwlwifi: mvm: differentiate net-detect from sched scan
      iwlwifi: mvm: some clean ups in fw-api-scan.h
      iwlwifi: mvm: always use iwl_mvm_scan_size to calculate the scan =
size
      iwlwifi: mvm: combine scan size checks into a common function
      iwlwifi: mvm: combine parts of UMAC and LMAC scans
      iwlwifi: mvm: combine parts of UMAC and LMAC sched scans
      iwlwifi: mvm: add common scan params to thw iwl_mvm_scan_params s=
truct
      iwlwifi: mvm: combine ssid_bitmap setting for regular scans
      iwlwifi: mvm: revert order of SSIDs for sched scans
      iwlwifi: mvm: combine SSID functions for sched and regular scans
      iwlwifi: mvm: rename scan_calc_params to scan_calc_dwell
      iwlwifi: mvm: combine LMAC and UMAC preq generation
      iwlwifi: mvm: add number of scan iterations and multiplier to par=
ams
      iwlwifi: mvm: combine LMAC scans into one
      iwlwifi: mvm: trim sched scan delay down to 16-bit for LMAC as we=
ll
      iwlwifi: mvm: combine UMAC scans into one
      iwlwifi: mvm: move all UMAC scan flags setting into the relevant =
function
      iwlwifi: mvm: move all LMAC scan flags into a single funtion
      iwlwifi: mvm: rename generic_scan_cmd functions to dwell
      iwlwifi: mvm: remove some unused stuff from scan.c

Marek Puzyniak (5):
      ath10k: make peer type configurable
      ath10k: store max tdls vdevs that fw can handle
      ath10k: update station counting
      ath10k: add wmi support for tdls
      ath10k: introduce basic tdls functionality

Masanari Iida (1):
      wireless: fix typos in mwifiex and rtlwifi

Matti Gottlieb (1):
      iwlwifi: mvm: ROC: Reduce the aux roc max delay

Michal Kazior (56):
      ath10k: fix AP/IBSS CSA with template based fw
      ath10k: fix broken traffic for 802.1x in client mode
      ath10k: fix broken traffic for static WEP in IBSS
      ath10k: fix ap u-apsd cmd on qca6174 w/ wmi-tlv
      ath10k: fix TxBF VHT capabilities for 2+ RF-chain devices
      ath10k: refactor p2p noa code
      ath10k: implement handling of p2p noa event
      ath10k: improve 11b coex
      ath10k: fix some pci wake/sleep issues
      ath10k: save/restore pci config space properly
      ath10k: fix patching mistake for AP/IBSS CSA
      ath10k: fix CAC regression
      ath10k: fix WPA crypto
      ath10k: implement wmi roam event
      ath10k: add hw connection monitor support
      ath10k: strip qos data bit always
      ath10k: protect driver from unsolicited htc ep0 events
      ath10k: clear htt.freq
      ath10k: unify tx mode and dispatch
      ath10k: move rate definitions to file start
      ath10k: derive rate from bitrate
      ath10k: drop RATETAB_ENT macro
      ath10k: add hw rate definitions
      ath10k: use hw rate definitions for fixed rate
      ath10k: simplify fixed rate selection
      ath10k: rework legacy rx rate decoding
      ath10k: deduplicate bitrate to rate idx conversion
      ath10k: document ofdm/5ghz rate offset with a macro
      ath10k: fix aid setup in station mode
      ath10k: fix survey reporting
      ath10k: don't call quiet mode if it's not implemented
      ath10k: allow empty ssid vdev config
      ath10k: implement chanctx API
      ath10k: implement adaptive qcs command
      ath10k: rework tx queue locking
      ath10k: implement tx pause wmi event
      ath10k: enable multi-channel on supported devices
      ath10k: allocate fw resources for iface combinations
      ath10k: clean up set_bitrate_mask handling
      ath10k: fix IBSS scanning on wmi-tlv and qca6174
      ath10k: fix insufficient tracing buffer size
      ath10k: replenish htc tx credits always
      ath10k: fix arvif->wep_keys clearing
      ath10k: fix static wep with more than 1 key in client mode
      ath10k: fix hw roc expiration
      ath10k: use scan burst for hw roc
      ath10k: fix error handling in pci_probe
      ath10k: add extra check for frame tracing
      ath10k: change static wep key handling for client mode
      ath10k: don't use reassoc flag
      ath10k: fix multiple key static wep with ibss
      ath10k: set def key idx for ibss
      ath10k: share board file loading code across FW APIs
      ath10k: allow loading device specific board files
      ath10k: fix qca61x4 hw2.1 support
      ath10k: implement more versatile set_bitrate_mask

Nicholas Mc Guire (6):
      ath10k: mac: match wait_for_completion_timeout return type
      ath10k: htc: match wait_for_completion_timeout return type
      ath10k: debug: match wait_for_completion_timeout return type
      ath10k: thermal: match wait_for_completion_timeout return type
      ath10k: core: match wait_for_completion_timeout return type
      ath10k: harmonize error case handling in ath10k_core_start

Nick Kossifidis (11):
      ath9k: Add a new debug flag for FFT spectral scan
      ath9k: Fix hanlding of maximum magnitude index
      ath9k: Move processing of FFT frames to different functions
      ath9k: Perform integrity checks when processing FFT frames
      ath9k: Support processing of multiple FFT frames per report.
      ath9k: Skip malformed frames on normal FFT report
      ath9k: No need for that extra memcpy
      ath9k: Skip FFT reports if we are out of output buffers
      ath9k: No need for that extra memset
      ath9k: Mix the received FFT bins to the random pool
      ath9k: Enable short repeat by default on ath9k_htc

Peter Oh (8):
      ath: introduce chirp parameter used by DFS
      ath10k: update chirp value in pulse event
      ath: enhance radar detection by looking up chirp
      ath10k: enable channel 144 on 5GHz band
      ath: support new FCC DFS Radar Type 1
      ath: define JP DFS patterns separated from FCC
      ath: lower JP W53 band DFS detection threshold around 30%
      ath10k: use MAC clock rate same as FW uses for survey accuracy

Rafa=C5=82 Mi=C5=82ecki (1):
      brcmfmac: check result of USB firmware request

Rajkumar Manoharan (12):
      ath10k: increase copy engine entries for rx wmi
      ath10k: increase duty cycle maximum limit
      ath10k: fix wrong symlink name on error path
      ath10k: fix rts profile for second rate series
      ath10k: increase station kickout threshold
      ath10k: add debugfs entry to configure quiet period
      ath10k: fix interpretation of cooling device state
      ath10k: configure thermal throttle while powering up
      ath10k: do not restrict thermal throttling to ap mode
      ath10k: cache throttle state when device is down
      ath10k: move driver state check before setting throttle
      ath10k: add ATH10K_FW_IE_HTT_OP_VERSION

SenthilKumar Jegadeesan (1):
      ath10k: increase AST table SKID length limit

Sujith Manoharan (1):
      ath10k: fix no-ack frame status

Vasanthakumar Thiagarajan (2):
      ath10k: move ath10k_vdev_stop() up before ath10k_vdev_start_resta=
rt()
      ath10k: fix interrupt storm

Xinming Hu (1):
      mwifiex: parsing aid while receiving association response

Yanbo Li (3):
      ath10k: change the fw stats access mask
      ath10k: add the WMI Air Time Fairness service define
      ath10k: enable the BT-coex feature

Zhaoyang Liu (1):
      mwifiex: fix invalid HT IE configuration in FW

 .gitignore                                         |    1 +
 .mailmap                                           |    1 +
 CREDITS                                            |   21 +
 Documentation/ABI/obsolete/sysfs-block-zram        |  119 +
 Documentation/ABI/testing/sysfs-block-dm           |   22 +
 Documentation/ABI/testing/sysfs-block-zram         |   25 +
 Documentation/ABI/testing/sysfs-class-cxl          |    2 +-
 Documentation/ABI/testing/sysfs-class-led-flash    |   80 +
 Documentation/ABI/testing/sysfs-class-mtd          |   10 +
 .../ABI/testing/sysfs-driver-toshiba_acpi          |   93 +-
 .../ABI/testing/sysfs-platform-dell-laptop         |   69 +
 Documentation/CodingStyle                          |  162 +-
 Documentation/DocBook/crypto-API.tmpl              |  860 ++++
 Documentation/DocBook/drm.tmpl                     |   31 +-
 Documentation/DocBook/media/v4l/biblio.xml         |   11 +-
 Documentation/DocBook/media/v4l/compat.xml         |    2 +-
 Documentation/DocBook/media/v4l/dev-sliced-vbi.xml |    2 +-
 .../DocBook/media/v4l/media-ioc-enum-entities.xml  |   92 +-
 .../DocBook/media/v4l/pixfmt-packed-rgb.xml        |   79 +-
 Documentation/DocBook/media/v4l/pixfmt-sgrbg8.xml  |   16 +-
 .../DocBook/media/v4l/pixfmt-srggb10p.xml          |    2 +-
 Documentation/DocBook/media/v4l/pixfmt-yuv420m.xml |    4 +-
 Documentation/DocBook/media/v4l/pixfmt.xml         |  110 +-
 Documentation/DocBook/media/v4l/subdev-formats.xml | 1299 +++--
 Documentation/DocBook/media/v4l/v4l2.xml           |    9 +
 Documentation/DocBook/media/v4l/vidioc-cropcap.xml |    9 +-
 Documentation/DocBook/media/v4l/vidioc-dqevent.xml |  121 +-
 Documentation/DocBook/media/v4l/vidioc-g-crop.xml  |    5 +
 .../DocBook/media/v4l/vidioc-g-dv-timings.xml      |   18 +-
 Documentation/DocBook/media/v4l/vidioc-g-fbuf.xml  |    4 +-
 .../DocBook/media/v4l/vidioc-g-selection.xml       |    4 +-
 .../DocBook/media/v4l/vidioc-g-sliced-vbi-cap.xml  |    2 +-
 .../DocBook/media/v4l/vidioc-querycap.xml          |    8 +-
 .../DocBook/media/v4l/vidioc-queryctrl.xml         |   12 +-
 .../v4l/vidioc-subdev-enum-frame-interval.xml      |   13 +-
 .../media/v4l/vidioc-subdev-enum-frame-size.xml    |   13 +-
 .../media/v4l/vidioc-subdev-enum-mbus-code.xml     |   11 +-
 .../DocBook/media/v4l/vidioc-subscribe-event.xml   |  111 +-
 Documentation/IRQ-domain.txt                       |    3 +-
 Documentation/Makefile                             |    2 +-
 Documentation/PCI/MSI-HOWTO.txt                    |   21 +-
 Documentation/PCI/pci-error-recovery.txt           |    2 +-
 Documentation/PCI/pcieaer-howto.txt                |    4 +-
 Documentation/SubmittingPatches                    |    4 +-
 Documentation/arm/00-INDEX                         |    2 -
 Documentation/arm/Booting                          |    9 +-
 Documentation/arm/Makefile                         |    1 -
 Documentation/arm/Marvell/README                   |    5 +
 Documentation/arm/README                           |   15 +-
 Documentation/arm/SH-Mobile/Makefile               |    7 -
 Documentation/arm/SH-Mobile/vrl4.c                 |  170 -
 Documentation/arm/SH-Mobile/zboot-rom-mmcif.txt    |   29 -
 Documentation/arm/SH-Mobile/zboot-rom-sdhi.txt     |   42 -
 Documentation/arm/msm/gpiomux.txt                  |  176 -
 Documentation/arm64/acpi_object_usage.txt          |  593 +++
 Documentation/arm64/arm-acpi.txt                   |  505 ++
 Documentation/blackfin/Makefile                    |    2 +-
 Documentation/block/biodoc.txt                     |   36 +-
 Documentation/blockdev/nbd.txt                     |   48 +-
 Documentation/blockdev/zram.txt                    |   87 +-
 Documentation/cgroups/memory.txt                   |    8 +-
 Documentation/cpu-hotplug.txt                      |    2 +-
 Documentation/crypto/crypto-API-userspace.txt      |  205 -
 Documentation/device-mapper/dm-crypt.txt           |    4 +-
 Documentation/device-mapper/log-writes.txt         |  140 +
 Documentation/device-mapper/switch.txt             |    4 +-
 Documentation/device-mapper/thin-provisioning.txt  |    3 -
 Documentation/device-mapper/verity.txt             |   21 +-
 Documentation/devicetree/bindings/arc/pct.txt      |   20 +
 Documentation/devicetree/bindings/arc/pmu.txt      |   24 -
 .../devicetree/bindings/arm/al,alpine.txt          |   88 +
 Documentation/devicetree/bindings/arm/altera.txt   |   14 +
 Documentation/devicetree/bindings/arm/amlogic.txt  |    4 +
 .../devicetree/bindings/arm/arch_timer.txt         |    8 +-
 .../devicetree/bindings/arm/armada-39x.txt         |   20 +
 .../devicetree/bindings/arm/atmel-at91.txt         |    4 +-
 ...351-cpu-method =3D> brcm,bcm11351-cpu-method.txt} |    0
 .../arm/bcm/{bcm11351.txt =3D> brcm,bcm11351.txt}    |    0
 .../arm/bcm/{bcm21664.txt =3D> brcm,bcm21664.txt}    |    0
 .../arm/{bcm2835.txt =3D> bcm/brcm,bcm2835.txt}      |    0
 .../arm/{bcm4708.txt =3D> bcm/brcm,bcm4708.txt}      |    0
 .../arm/bcm/{bcm63138.txt =3D> brcm,bcm63138.txt}    |    0
 .../arm/{brcm-brcmstb.txt =3D> bcm/brcm,brcmstb.txt} |    0
 .../arm/bcm/{cygnus.txt =3D> brcm,cygnus.txt}        |    0
 Documentation/devicetree/bindings/arm/cci.txt      |    7 +-
 .../devicetree/bindings/arm/coresight.txt          |    1 -
 .../bindings/arm/cpu-enable-method/al,alpine-smp   |   52 +
 Documentation/devicetree/bindings/arm/cpus.txt     |    1 +
 .../bindings/arm/exynos/power_domain.txt           |    3 +
 .../devicetree/bindings/arm/geniatech.txt          |    5 -
 Documentation/devicetree/bindings/arm/gic.txt      |    2 +
 .../devicetree/bindings/arm/marvell,kirkwood.txt   |    1 +
 .../bindings/arm/msm/qcom,idle-state.txt           |   84 +
 .../devicetree/bindings/arm/msm/qcom,saw2.txt      |   40 +-
 .../devicetree/bindings/arm/msm/timer.txt          |   16 +-
 .../devicetree/bindings/arm/omap/ctrl.txt          |   79 +
 Documentation/devicetree/bindings/arm/omap/l4.txt  |   26 +
 .../devicetree/bindings/arm/omap/prcm.txt          |    6 +-
 Documentation/devicetree/bindings/arm/pmu.txt      |    7 +
 Documentation/devicetree/bindings/arm/rockchip.txt |    4 +
 Documentation/devicetree/bindings/arm/shmobile.txt |    8 -
 .../bindings/arm/tegra/nvidia,tegra30-actmon.txt   |   32 +
 .../bindings/bus/{bcma.txt =3D> brcm,bus-axi.txt}    |    0
 .../devicetree/bindings/bus/omap-ocp2scp.txt       |    3 +-
 .../devicetree/bindings/bus/renesas,bsc.txt        |   46 +
 .../devicetree/bindings/bus/simple-pm-bus.txt      |   44 +
 .../{bcm-kona-clock.txt =3D> brcm,kona-ccu.txt}      |    0
 .../devicetree/bindings/clock/exynos3250-clock.txt |    8 +
 .../devicetree/bindings/clock/exynos5433-clock.txt |  462 ++
 .../bindings/clock/fujitsu,mb86s70-crg11.txt       |   26 +
 .../devicetree/bindings/clock/mvebu-core-clock.txt |    9 +
 .../bindings/clock/mvebu-gated-clock.txt           |   15 +-
 .../devicetree/bindings/clock/pistachio-clock.txt  |  123 +
 .../devicetree/bindings/clock/pwm-clock.txt        |   26 +
 .../devicetree/bindings/clock/qcom,gcc.txt         |    1 +
 .../bindings/clock/renesas,r8a7778-cpg-clocks.txt  |   25 +
 Documentation/devicetree/bindings/clock/sunxi.txt  |    3 +
 .../devicetree/bindings/common-properties.txt      |   60 +
 Documentation/devicetree/bindings/cris/axis.txt    |    9 +
 Documentation/devicetree/bindings/cris/boards.txt  |    8 +
 .../devicetree/bindings/cris/interrupts.txt        |   23 +
 .../devicetree/bindings/crypto/img-hash.txt        |   27 +
 .../devicetree/bindings/dma/apm-xgene-dma.txt      |   47 +
 .../dma/{bcm2835-dma.txt =3D> brcm,bcm2835-dma.txt}  |    0
 .../devicetree/bindings/dma/jz4780-dma.txt         |   56 +
 .../devicetree/bindings/dma/qcom_bam_dma.txt       |    1 +
 .../devicetree/bindings/dma/rcar-audmapp.txt       |   29 -
 .../devicetree/bindings/dma/renesas,usb-dmac.txt   |   37 +
 Documentation/devicetree/bindings/drm/imx/ldb.txt  |   62 +-
 .../devicetree/bindings/extcon/extcon-usb-gpio.txt |   18 +
 .../gpio/{gpio-bcm-kona.txt =3D> brcm,kona-gpio.txt} |    0
 .../devicetree/bindings/gpio/gpio-altera.txt       |   43 +
 Documentation/devicetree/bindings/gpio/gpio.txt    |   30 +
 .../devicetree/bindings/gpio/mrvl-gpio.txt         |    2 +-
 .../bindings/hwrng/brcm,iproc-rng200.txt           |   12 +
 .../i2c/{i2c-bcm-kona.txt =3D> brcm,kona-i2c.txt}    |    0
 .../devicetree/bindings/i2c/trivial-devices.txt    |    1 +
 .../interrupt-controller/brcm,bcm3380-l2-intc.txt  |   41 +
 .../interrupt-controller/brcm,bcm7038-l1-intc.txt  |   52 +
 .../interrupt-controller/brcm,bcm7120-l2-intc.txt  |   12 +-
 .../interrupt-controller/cdns,xtensa-mx.txt        |   18 +
 .../interrupt-controller/cdns,xtensa-pic.txt       |   25 +
 .../bindings/interrupt-controller/mips-gic.txt     |    5 +
 Documentation/devicetree/bindings/leds/common.txt  |    6 +-
 .../devicetree/bindings/leds/leds-gpio.txt         |   12 +-
 .../devicetree/bindings/leds/leds-pm8941-wled.txt  |   43 +
 .../devicetree/bindings/mailbox/arm-mhu.txt        |   43 +
 .../bindings/media/exynos-jpeg-codec.txt           |    2 +-
 .../devicetree/bindings/media/i2c/mt9v032.txt      |   39 +
 .../devicetree/bindings/media/i2c/ov2640.txt       |   46 +
 .../devicetree/bindings/media/i2c/ov2659.txt       |   38 +
 .../devicetree/bindings/media/ti,omap3isp.txt      |   71 +
 .../devicetree/bindings/media/video-interfaces.txt |    6 +
 .../devicetree/bindings/media/xilinx/video.txt     |   35 +
 .../devicetree/bindings/media/xilinx/xlnx,v-tc.txt |   33 +
 .../bindings/media/xilinx/xlnx,v-tpg.txt           |   71 +
 .../bindings/media/xilinx/xlnx,video.txt           |   55 +
 .../memory-controllers/ingenic,jz4780-nemc.txt     |   75 +
 .../mfd/{bcm590xx.txt =3D> brcm,bcm59056.txt}        |    0
 .../devicetree/bindings/mfd/qcom,tcsr.txt          |   22 +
 .../devicetree/bindings/mips/brcm/bcm3384-intc.txt |   37 -
 .../mips/brcm/{bmips.txt =3D> brcm,bmips.txt}        |    0
 .../devicetree/bindings/mips/brcm/cm-dsl.txt       |   11 -
 .../devicetree/bindings/mips/brcm/soc.txt          |   12 +
 .../devicetree/bindings/mips/img/pistachio.txt     |   42 +
 .../bindings/misc/{smc.txt =3D> brcm,kona-smc.txt}   |    0
 Documentation/devicetree/bindings/misc/lis302.txt  |    9 +-
 .../mmc/{kona-sdhci.txt =3D> brcm,kona-sdhci.txt}    |    0
 Documentation/devicetree/bindings/mtd/m25p80.txt   |   13 +-
 .../devicetree/bindings/mtd/pxa3xx-nand.txt        |    2 +-
 .../devicetree/bindings/mtd/sunxi-nand.txt         |    2 +-
 ...oadcom-sf2.txt =3D> brcm,bcm7445-switch-v4.0.txt} |    0
 .../{broadcom-bcmgenet.txt =3D> brcm,bcmgenet.txt}   |    0
 ...broadcom-systemport.txt =3D> brcm,systemport.txt} |    0
 ...oadcom-mdio-unimac.txt =3D> brcm,unimac-mdio.txt} |    0
 Documentation/devicetree/bindings/net/ethernet.txt |    6 +
 Documentation/devicetree/bindings/net/stmmac.txt   |    4 +
 .../devicetree/bindings/net/wireless/ti,wlcore.txt |   47 +
 .../bindings/panel/ampire,am800480r3tmqwa1h.txt    |    7 +
 .../devicetree/bindings/panel/auo,b101ean01.txt    |    7 +
 .../bindings/panel/innolux,at043tn24.txt           |    7 +
 .../bindings/panel/innolux,zj070na-01p.txt         |    7 +
 .../bindings/panel/ortustech,com43h4m85ulc.txt     |    7 +
 .../bindings/panel/samsung,ltn140at29-301.txt      |    7 +
 .../bindings/panel/shelly,sca07010-bfn-lnn.txt     |    7 +
 .../phy/{bcm-phy.txt =3D> brcm,kona-usb2-phy.txt}    |    0
 .../devicetree/bindings/power/fsl,imx-gpc.txt      |   59 +
 .../bindings/power/renesas,sysc-rmobile.txt        |    1 +
 .../pwm/{bcm-kona-pwm.txt =3D> brcm,kona-pwm.txt}    |    0
 Documentation/devicetree/bindings/pwm/imx-pwm.txt  |   12 +-
 .../brcm,bcm21664-resetmgr.txt}                    |    0
 .../devicetree/bindings/rtc/digicolor-rtc.txt      |   17 +
 .../devicetree/bindings/rtc/stmp3xxx-rtc.txt       |    5 +
 .../bindings/security/tpm/st33zp24-spi.txt         |   34 +
 .../devicetree/bindings/serial/atmel-usart.txt     |    3 +-
 .../{bcm63xx-uart.txt =3D> brcm,bcm6345-uart.txt}    |    0
 .../devicetree/bindings/serial/omap_serial.txt     |   20 +
 .../devicetree/bindings/soc/mediatek/pwrap.txt     |   58 +
 .../devicetree/bindings/soc/qcom/qcom,gsbi.txt     |   30 +-
 .../{bcm2835-i2s.txt =3D> brcm,bcm2835-i2s.txt}      |    0
 .../bindings/sound/ingenic,jz4740-i2s.txt          |    2 +-
 .../devicetree/bindings/sound/max98925.txt         |   22 +
 .../bindings/sound/nvidia,tegra-audio-max98090.txt |    1 +
 .../devicetree/bindings/sound/omap-twl4030.txt     |    3 +-
 .../devicetree/bindings/sound/qcom,lpass-cpu.txt   |   43 +
 .../devicetree/bindings/sound/renesas,rsnd.txt     |  125 +-
 .../bindings/sound/renesas,rsrc-card.txt           |   67 +
 Documentation/devicetree/bindings/sound/storm.txt  |   23 +
 Documentation/devicetree/bindings/sound/wm8804.txt |    7 +
 .../bindings/spmi/qcom,spmi-pmic-arb.txt           |    6 +-
 .../kona-timer.txt =3D> timer/brcm,kona-timer.txt}   |    0
 Documentation/devicetree/bindings/unittest.txt     |   44 +-
 .../brcm/usb.txt =3D> usb/brcm,bcm3384-usb.txt}      |    0
 .../devicetree/bindings/vendor-prefixes.txt        |    7 +
 .../devicetree/bindings/video/atmel,lcdc.txt       |   12 +-
 .../devicetree/bindings/video/ti,omap-dss.txt      |    4 +-
 .../kona-wdt.txt =3D> watchdog/brcm,kona-wdt.txt}    |    0
 Documentation/devicetree/booting-without-of.txt    |   28 +
 .../{of_selftest.txt =3D> of_unittest.txt}           |   28 +-
 Documentation/dma-buf-sharing.txt                  |   23 +-
 Documentation/driver-model/devres.txt              |    5 +
 Documentation/email-clients.txt                    |   11 +-
 Documentation/filesystems/Locking                  |   12 +-
 Documentation/filesystems/f2fs.txt                 |    6 +
 Documentation/filesystems/nfs/nfs-rdma.txt         |    9 +-
 Documentation/filesystems/porting                  |   12 +
 Documentation/filesystems/proc.txt                 |   21 +-
 Documentation/filesystems/vfs.txt                  |    8 +-
 Documentation/filesystems/xfs.txt                  |   29 +-
 Documentation/gpio/board.txt                       |   41 +-
 Documentation/gpio/consumer.txt                    |   65 +-
 Documentation/i2o/README                           |   63 -
 Documentation/i2o/ioctl                            |  394 --
 Documentation/input/alps.txt                       |   13 +-
 Documentation/input/event-codes.txt                |    2 +-
 Documentation/input/gpio-tilt.txt                  |    2 +-
 Documentation/input/iforce-protocol.txt            |    2 +-
 Documentation/input/walkera0701.txt                |    2 +-
 Documentation/input/yealink.txt                    |    2 +-
 Documentation/ioctl/ioctl-number.txt               |    1 +
 Documentation/kernel-parameters.txt                |   41 +-
 Documentation/kmemcheck.txt                        |    4 +-
 Documentation/kprobes.txt                          |    4 +-
 Documentation/laptops/thinkpad-acpi.txt            |   18 +
 Documentation/leds/leds-class-flash.txt            |   22 +
 Documentation/md-cluster.txt                       |  176 +
 Documentation/memory-barriers.txt                  |    2 +-
 Documentation/memory-hotplug.txt                   |   47 +-
 Documentation/networking/mpls-sysctl.txt           |    9 +
 Documentation/networking/scaling.txt               |    2 +-
 .../powerpc/pci_iov_resource_on_powernv.txt        |  301 ++
 Documentation/powerpc/transactional_memory.txt     |   36 +-
 Documentation/printk-formats.txt                   |   59 +-
 Documentation/scheduler/completion.txt             |  132 +-
 Documentation/security/Smack.txt                   |  129 +-
 Documentation/sound/alsa/ControlNames.txt          |   10 +-
 Documentation/sound/alsa/HD-Audio.txt              |    6 +-
 Documentation/sound/alsa/timestamping.txt          |  200 +
 Documentation/spi/spidev_test.c                    |    4 +-
 Documentation/sysctl/kernel.txt                    |   21 +
 Documentation/sysctl/vm.txt                        |   11 +
 Documentation/target/tcm_mod_builder.py            |   79 +-
 Documentation/target/tcmu-design.txt               |   43 +-
 Documentation/trace/coresight.txt                  |    2 +-
 Documentation/video4linux/v4l2-controls.txt        |    4 +-
 Documentation/video4linux/v4l2-framework.txt       |    6 +-
 Documentation/video4linux/vivid.txt                |    5 +
 Documentation/virtual/kvm/api.txt                  |   17 +
 Documentation/vm/hugetlbpage.txt                   |   55 +-
 Documentation/vm/pagemap.txt                       |    3 +-
 Documentation/vm/transhuge.txt                     |   11 +
 Documentation/vm/unevictable-lru.txt               |   12 +
 Documentation/vm/zsmalloc.txt                      |   70 +
 Documentation/zh_CN/arm64/booting.txt              |   54 +-
 Documentation/zh_CN/arm64/legacy_instructions.txt  |   72 +
 Documentation/zh_CN/arm64/memory.txt               |   65 +-
 Kbuild                                             |   21 +-
 MAINTAINERS                                        |  253 +-
 Makefile                                           |   32 +-
 README                                             |   42 +-
 arch/Kconfig                                       |    2 +-
 arch/alpha/include/asm/processor.h                 |    1 +
 arch/alpha/include/asm/thread_info.h               |    2 -
 arch/arc/boot/dts/angel4.dts                       |    2 +-
 arch/arc/configs/nsimosci_defconfig                |   19 +-
 arch/arc/include/asm/arcregs.h                     |   14 +-
 arch/arc/include/asm/bitops.h                      |   31 +-
 arch/arc/include/asm/perf_event.h                  |   70 +-
 arch/arc/include/asm/thread_info.h                 |    2 -
 arch/arc/kernel/perf_event.c                       |   73 +-
 arch/arc/kernel/process.c                          |    9 +-
 arch/arc/kernel/setup.c                            |    5 +-
 arch/arc/kernel/signal.c                           |   14 +-
 arch/arc/kernel/traps.c                            |    4 +-
 arch/arc/kernel/troubleshoot.c                     |    3 +-
 arch/arc/mm/init.c                                 |    9 +-
 arch/arm/Kconfig                                   |   76 +-
 arch/arm/Kconfig.debug                             |  108 +-
 arch/arm/Makefile                                  |    3 +-
 arch/arm/boot/Makefile                             |    2 +-
 arch/arm/boot/compressed/Makefile                  |   15 -
 arch/arm/boot/compressed/head-shmobile.S           |   30 -
 arch/arm/boot/compressed/mmcif-sh7372.c            |   88 -
 arch/arm/boot/compressed/sdhi-sh7372.c             |   95 -
 arch/arm/boot/compressed/sdhi-shmobile.c           |  449 --
 arch/arm/boot/compressed/sdhi-shmobile.h           |   11 -
 arch/arm/boot/dts/Makefile                         |   35 +-
 arch/arm/boot/dts/alpine-db.dts                    |   35 +
 arch/arm/boot/dts/alpine.dtsi                      |  160 +
 arch/arm/boot/dts/am335x-chiliboard.dts            |  112 +
 arch/arm/boot/dts/am335x-chilisom.dtsi             |  239 +
 arch/arm/boot/dts/am335x-evmsk.dts                 |   11 +
 arch/arm/boot/dts/am335x-nano.dts                  |   18 +-
 arch/arm/boot/dts/am33xx-clocks.dtsi               |    2 +-
 arch/arm/boot/dts/am33xx.dtsi                      |   87 +-
 arch/arm/boot/dts/am3517.dtsi                      |    2 +-
 arch/arm/boot/dts/am35xx-clocks.dtsi               |    2 +-
 arch/arm/boot/dts/am4372.dtsi                      |   91 +-
 arch/arm/boot/dts/am437x-idk-evm.dts               |   22 +
 arch/arm/boot/dts/am43x-epos-evm.dts               |   84 +-
 arch/arm/boot/dts/am43xx-clocks.dtsi               |    2 +-
 arch/arm/boot/dts/am57xx-beagle-x15.dts            |   58 +-
 arch/arm/boot/dts/armada-370-db.dts                |   13 +-
 arch/arm/boot/dts/armada-370-mirabox.dts           |    2 +-
 arch/arm/boot/dts/armada-370-netgear-rn102.dts     |    2 +-
 arch/arm/boot/dts/armada-370-netgear-rn104.dts     |    2 +-
 arch/arm/boot/dts/armada-370-rd.dts                |    2 +-
 arch/arm/boot/dts/armada-370-synology-ds213j.dts   |    3 +-
 arch/arm/boot/dts/armada-370-xp.dtsi               |   11 +-
 arch/arm/boot/dts/armada-370.dtsi                  |    3 +-
 arch/arm/boot/dts/armada-375-db.dts                |    2 +-
 arch/arm/boot/dts/armada-375.dtsi                  |   15 +-
 arch/arm/boot/dts/armada-385-db-ap.dts             |   44 +-
 arch/arm/boot/dts/armada-388-db.dts                |    4 +-
 arch/arm/boot/dts/armada-388-gp.dts                |    5 +-
 arch/arm/boot/dts/armada-388-rd.dts                |   12 +-
 arch/arm/boot/dts/armada-38x.dtsi                  |   23 +-
 arch/arm/boot/dts/armada-390.dtsi                  |   57 +
 arch/arm/boot/dts/armada-398-db.dts                |  153 +
 arch/arm/boot/dts/armada-398.dtsi                  |   60 +
 arch/arm/boot/dts/armada-39x.dtsi                  |  508 ++
 arch/arm/boot/dts/armada-xp-axpwifiap.dts          |    2 +-
 arch/arm/boot/dts/armada-xp-db.dts                 |    2 +-
 arch/arm/boot/dts/armada-xp-gp.dts                 |    2 +-
 arch/arm/boot/dts/armada-xp-lenovo-ix4-300d.dts    |    3 +-
 arch/arm/boot/dts/armada-xp-linksys-mamba.dts      |  393 ++
 arch/arm/boot/dts/armada-xp-matrix.dts             |    2 +-
 arch/arm/boot/dts/armada-xp-mv78260.dtsi           |    1 -
 arch/arm/boot/dts/armada-xp-mv78460.dtsi           |    1 -
 arch/arm/boot/dts/armada-xp-netgear-rn2120.dts     |    2 +-
 arch/arm/boot/dts/armada-xp-openblocks-ax3-4.dts   |    2 +-
 arch/arm/boot/dts/armada-xp-synology-ds414.dts     |    3 +-
 arch/arm/boot/dts/armada-xp.dtsi                   |    8 +-
 arch/arm/boot/dts/at91-sama5d3_xplained.dts        |   14 +
 arch/arm/boot/dts/at91-sama5d4_xplained.dts        |  241 +
 arch/arm/boot/dts/at91-sama5d4ek.dts               |   55 +-
 arch/arm/boot/dts/at91rm9200.dtsi                  |    8 +-
 arch/arm/boot/dts/at91sam9260.dtsi                 |    2 +-
 arch/arm/boot/dts/at91sam9261.dtsi                 |    2 +-
 arch/arm/boot/dts/at91sam9263.dtsi                 |    2 +-
 arch/arm/boot/dts/at91sam9g25.dtsi                 |    1 +
 arch/arm/boot/dts/at91sam9g25ek.dts                |   18 +
 arch/arm/boot/dts/at91sam9g45.dtsi                 |    2 +-
 arch/arm/boot/dts/at91sam9n12.dtsi                 |   11 +-
 arch/arm/boot/dts/at91sam9n12ek.dts                |   18 +
 arch/arm/boot/dts/at91sam9rl.dtsi                  |    2 +-
 arch/arm/boot/dts/at91sam9x5.dtsi                  |    2 +-
 arch/arm/boot/dts/at91sam9x5_isi.dtsi              |   46 +
 arch/arm/boot/dts/at91sam9x5cm.dtsi                |    4 +
 arch/arm/boot/dts/at91sam9x5ek.dtsi                |   48 +
 arch/arm/boot/dts/bcm-cygnus.dtsi                  |   78 +
 arch/arm/boot/dts/bcm4708-netgear-r6250.dts        |    4 +-
 arch/arm/boot/dts/bcm4709-netgear-r8000.dts        |   77 +
 arch/arm/boot/dts/bcm7445.dtsi                     |   14 +-
 arch/arm/boot/dts/bcm911360_entphn.dts             |   13 +
 arch/arm/boot/dts/bcm958300k.dts                   |    8 +
 arch/arm/boot/dts/bcm958305k.dts                   |   53 +
 arch/arm/boot/dts/dm8168-evm.dts                   |   14 +-
 arch/arm/boot/dts/dm816x.dtsi                      |   60 +
 arch/arm/boot/dts/dove.dtsi                        |   63 +-
 arch/arm/boot/dts/dra7-evm.dts                     |    8 +
 arch/arm/boot/dts/dra7.dtsi                        |  182 +-
 arch/arm/boot/dts/dra72-evm.dts                    |    8 +
 arch/arm/boot/dts/dra72x.dtsi                      |    5 +
 arch/arm/boot/dts/dra74x.dtsi                      |    5 +
 arch/arm/boot/dts/dra7xx-clocks.dtsi               |    8 +
 arch/arm/boot/dts/emev2-kzm9d.dts                  |   13 +
 arch/arm/boot/dts/emev2.dtsi                       |   10 +
 arch/arm/boot/dts/exynos3250.dtsi                  |    4 +
 arch/arm/boot/dts/exynos4412-odroid-common.dtsi    |   14 +
 arch/arm/boot/dts/exynos5250-snow.dts              |   57 +-
 arch/arm/boot/dts/exynos5250-spring.dts            |   21 +-
 arch/arm/boot/dts/exynos5250.dtsi                  |    2 +-
 arch/arm/boot/dts/exynos5420-arndale-octa.dts      |    4 +-
 arch/arm/boot/dts/exynos5420-peach-pit.dts         |   99 +-
 arch/arm/boot/dts/exynos5420-pinctrl.dtsi          |    7 +
 arch/arm/boot/dts/exynos5420-smdk5420.dts          |    7 +-
 arch/arm/boot/dts/exynos5420.dtsi                  |   10 +-
 arch/arm/boot/dts/exynos5422-odroidxu3.dts         |   21 +-
 arch/arm/boot/dts/exynos5800-peach-pi.dts          |   71 +-
 arch/arm/boot/dts/hip04.dtsi                       |    1 -
 arch/arm/boot/dts/imx25-pdk.dts                    |   58 +
 arch/arm/boot/dts/imx25-pinfunc.h                  |   86 +-
 arch/arm/boot/dts/imx27.dtsi                       |    2 +
 arch/arm/boot/dts/imx28-apf28.dts                  |    2 +-
 arch/arm/boot/dts/imx28-apf28dev.dts               |   30 +-
 arch/arm/boot/dts/imx28.dtsi                       |   14 +
 arch/arm/boot/dts/imx35.dtsi                       |    1 +
 arch/arm/boot/dts/imx50.dtsi                       |    3 +
 arch/arm/boot/dts/imx51.dtsi                       |    3 +
 arch/arm/boot/dts/imx53.dtsi                       |    3 +
 arch/arm/boot/dts/imx6dl-aristainetos_4.dts        |    4 +
 arch/arm/boot/dts/imx6dl-aristainetos_7.dts        |    4 +
 arch/arm/boot/dts/imx6dl-cubox-i.dts               |   38 +
 arch/arm/boot/dts/imx6dl-hummingboard.dts          |   38 +
 arch/arm/boot/dts/imx6q-cubox-i.dts                |   38 +
 arch/arm/boot/dts/imx6q-hummingboard.dts           |   38 +
 arch/arm/boot/dts/imx6q.dtsi                       |   20 +-
 arch/arm/boot/dts/imx6qdl-cubox-i.dtsi             |   62 +
 arch/arm/boot/dts/imx6qdl-hummingboard.dtsi        |  101 +-
 arch/arm/boot/dts/imx6qdl-microsom-ar8035.dtsi     |   38 +
 arch/arm/boot/dts/imx6qdl-microsom.dtsi            |   38 +
 arch/arm/boot/dts/imx6qdl-sabreauto.dtsi           |   35 +
 arch/arm/boot/dts/imx6qdl.dtsi                     |   49 +-
 arch/arm/boot/dts/imx6sl-warp.dts                  |  262 +
 arch/arm/boot/dts/imx6sl.dtsi                      |   13 +-
 arch/arm/boot/dts/imx6sx-sdb-reva.dts              |  143 +
 arch/arm/boot/dts/imx6sx-sdb.dts                   |  603 +--
 arch/arm/boot/dts/imx6sx-sdb.dtsi                  |  562 ++
 arch/arm/boot/dts/imx6sx.dtsi                      |    9 +-
 arch/arm/boot/dts/kirkwood-nas2big.dts             |  143 +
 arch/arm/boot/dts/kirkwood-net2big.dts             |    5 +
 arch/arm/boot/dts/meson.dtsi                       |   20 +
 arch/arm/boot/dts/meson6-atv1200.dts               |    4 +
 arch/arm/boot/dts/meson8-minix-neo-x8.dts          |  128 +
 arch/arm/boot/dts/meson8.dtsi                      |   68 +
 arch/arm/boot/dts/mt6589.dtsi                      |    5 +
 arch/arm/boot/dts/nspire-classic.dtsi              |    5 +
 arch/arm/boot/dts/nspire-cx.dts                    |    4 +
 arch/arm/boot/dts/nspire.dtsi                      |   21 +
 arch/arm/boot/dts/omap2420.dtsi                    |   80 +-
 arch/arm/boot/dts/omap2430-clocks.dtsi             |    8 +-
 arch/arm/boot/dts/omap2430.dtsi                    |  107 +-
 arch/arm/boot/dts/omap24xx-clocks.dtsi             |    6 +-
 arch/arm/boot/dts/omap3-beagle-xm.dts              |    2 -
 arch/arm/boot/dts/omap3-beagle.dts                 |   54 +-
 arch/arm/boot/dts/omap3-cm-t3517.dts               |   10 +
 arch/arm/boot/dts/omap3-cm-t3730.dts               |   10 +
 arch/arm/boot/dts/omap3-cm-t3x30.dtsi              |    1 -
 arch/arm/boot/dts/omap3-devkit8000.dts             |    1 -
 arch/arm/boot/dts/omap3-evm-common.dtsi            |   10 +
 arch/arm/boot/dts/omap3-gta04.dtsi                 |    1 -
 arch/arm/boot/dts/omap3-igep.dtsi                  |    1 -
 arch/arm/boot/dts/omap3-igep0020-rev-f.dts         |    9 +
 arch/arm/boot/dts/omap3-igep0030-rev-g.dts         |    9 +
 arch/arm/boot/dts/omap3-lilly-a83x.dtsi            |    1 -
 arch/arm/boot/dts/omap3-n9.dts                     |   37 +
 arch/arm/boot/dts/omap3-n900.dts                   |   68 +-
 arch/arm/boot/dts/omap3-n950-n9.dtsi               |    2 +-
 arch/arm/boot/dts/omap3-n950.dts                   |   37 +
 arch/arm/boot/dts/omap3-overo-base.dtsi            |    1 -
 arch/arm/boot/dts/omap3-pandora-1ghz.dts           |   70 +
 arch/arm/boot/dts/omap3-pandora-600mhz.dts         |   65 +
 arch/arm/boot/dts/omap3-pandora-common.dtsi        |  640 +++
 arch/arm/boot/dts/omap3-tao3530.dtsi               |   12 +-
 arch/arm/boot/dts/omap3-zoom3.dts                  |   10 +
 arch/arm/boot/dts/omap3.dtsi                       |   96 +-
 arch/arm/boot/dts/omap34xx-hs.dtsi                 |   16 -
 arch/arm/boot/dts/omap34xx.dtsi                    |   17 +
 arch/arm/boot/dts/omap36xx-hs.dtsi                 |   16 -
 arch/arm/boot/dts/omap36xx.dtsi                    |   17 +
 arch/arm/boot/dts/omap3xxx-clocks.dtsi             |   13 +-
 arch/arm/boot/dts/omap4-cpu-thermal.dtsi           |    4 +-
 arch/arm/boot/dts/omap4-panda-common.dtsi          |   10 +
 arch/arm/boot/dts/omap4-sdp.dts                    |   11 +
 arch/arm/boot/dts/omap4-var-som-om44-wlan.dtsi     |   10 +
 arch/arm/boot/dts/omap4.dtsi                       |  200 +-
 arch/arm/boot/dts/omap5.dtsi                       |  182 +-
 arch/arm/boot/dts/qcom-apq8064.dtsi                |   51 +-
 arch/arm/boot/dts/qcom-apq8074-dragonboard.dts     |    2 +
 arch/arm/boot/dts/qcom-apq8084-ifc6540.dts         |    1 +
 arch/arm/boot/dts/qcom-apq8084-mtp.dts             |    1 +
 arch/arm/boot/dts/qcom-apq8084.dtsi                |   56 +-
 arch/arm/boot/dts/qcom-ipq8064.dtsi                |   52 +-
 arch/arm/boot/dts/qcom-msm8660.dtsi                |    8 +
 arch/arm/boot/dts/qcom-msm8960.dtsi                |   15 +
 .../boot/dts/qcom-msm8974-sony-xperia-honami.dts   |    2 +
 arch/arm/boot/dts/qcom-msm8974.dtsi                |   56 +-
 arch/arm/boot/dts/qcom-pm8841.dtsi                 |   18 +
 arch/arm/boot/dts/qcom-pm8941.dtsi                 |   18 +
 arch/arm/boot/dts/qcom-pma8084.dtsi                |   18 +
 arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts    |  156 -
 arch/arm/boot/dts/r8a73a4-ape6evm.dts              |   59 +-
 arch/arm/boot/dts/r8a73a4.dtsi                     |  557 +-
 arch/arm/boot/dts/r8a7740.dtsi                     |   79 +-
 arch/arm/boot/dts/r8a7778-bockw.dts                |  174 +
 arch/arm/boot/dts/r8a7778.dtsi                     |  293 ++
 arch/arm/boot/dts/r8a7779-marzen.dts               |    9 +
 arch/arm/boot/dts/r8a7790-lager.dts                |   87 +
 arch/arm/boot/dts/r8a7790.dtsi                     |  259 +-
 arch/arm/boot/dts/r8a7791-henninger.dts            |   11 +
 arch/arm/boot/dts/r8a7791-koelsch.dts              |   87 +-
 arch/arm/boot/dts/r8a7791.dtsi                     |  278 +-
 arch/arm/boot/dts/r8a7794-alt.dts                  |   13 +
 arch/arm/boot/dts/r8a7794.dtsi                     |  157 +-
 arch/arm/boot/dts/rk3188-radxarock.dts             |   16 +
 arch/arm/boot/dts/rk3288-evb-act8846.dts           |   10 +
 arch/arm/boot/dts/rk3288-evb-rk808.dts             |    7 +
 arch/arm/boot/dts/rk3288-evb.dtsi                  |   13 +
 arch/arm/boot/dts/rk3288-firefly.dtsi              |   20 +
 arch/arm/boot/dts/rk3288-popmetal.dts              |  447 ++
 arch/arm/boot/dts/rk3288.dtsi                      |   35 +
 arch/arm/boot/dts/sama5d3.dtsi                     |   36 +-
 arch/arm/boot/dts/sama5d35ek.dts                   |    2 -
 arch/arm/boot/dts/sama5d3_can.dtsi                 |    2 +-
 arch/arm/boot/dts/sama5d3_emac.dtsi                |    2 +-
 arch/arm/boot/dts/sama5d3_gmac.dtsi                |    2 +-
 arch/arm/boot/dts/sama5d3_lcd.dtsi                 |  207 +-
 arch/arm/boot/dts/sama5d3_mci2.dtsi                |    2 +-
 arch/arm/boot/dts/sama5d3_tcb1.dtsi                |    2 +-
 arch/arm/boot/dts/sama5d3_uart.dtsi                |    2 +-
 arch/arm/boot/dts/sama5d4.dtsi                     |  344 +-
 arch/arm/boot/dts/sh7372-mackerel.dts              |   26 -
 arch/arm/boot/dts/sh7372.dtsi                      |   35 -
 arch/arm/boot/dts/sh73a0-kzm9g-reference.dts       |  366 --
 arch/arm/boot/dts/sh73a0-kzm9g.dts                 |  378 +-
 arch/arm/boot/dts/sh73a0.dtsi                      |  245 +-
 arch/arm/boot/dts/tegra124-jetson-tk1-emc.dtsi     | 2421 +++++++++
 arch/arm/boot/dts/tegra124-jetson-tk1.dts          |  559 +-
 arch/arm/boot/dts/tegra124-nyan-big-emc.dtsi       | 2023 ++++++++
 arch/arm/boot/dts/tegra124-nyan-big.dts            | 2121 ++++----
 arch/arm/boot/dts/tegra124-nyan-blaze-emc.dtsi     | 2049 ++++++++
 arch/arm/boot/dts/tegra124-nyan-blaze.dts          | 1334 +++++
 arch/arm/boot/dts/tegra124-nyan.dtsi               |  695 +++
 arch/arm/boot/dts/tegra124.dtsi                    |   19 +
 arch/arm/boot/dts/tegra30-beaver.dts               | 1653 +++++-
 arch/arm/boot/dts/vexpress-v2p-ca15_a7.dts         |    1 -
 arch/arm/boot/dts/vf-colibri-eval-v3.dtsi          |   31 +
 arch/arm/boot/dts/vf-colibri.dtsi                  |   15 +
 arch/arm/boot/dts/vf500.dtsi                       |  137 +-
 arch/arm/boot/dts/vfxxx.dtsi                       |   64 +-
 arch/arm/common/mcpm_entry.c                       |  202 +-
 arch/arm/configs/ape6evm_defconfig                 |  109 -
 arch/arm/configs/at91_dt_defconfig                 |    5 +-
 arch/arm/configs/badge4_defconfig                  |    1 -
 arch/arm/configs/exynos_defconfig                  |   20 +-
 arch/arm/configs/imx_v4_v5_defconfig               |    4 +-
 arch/arm/configs/imx_v6_v7_defconfig               |    4 +
 arch/arm/configs/mackerel_defconfig                |  157 -
 arch/arm/configs/msm_defconfig                     |  121 -
 arch/arm/configs/multi_v5_defconfig                |    2 +-
 arch/arm/configs/multi_v7_defconfig                |   14 +-
 arch/arm/configs/mvebu_v7_defconfig                |    2 +
 arch/arm/configs/mxs_defconfig                     |    1 +
 arch/arm/configs/omap1_defconfig                   |   16 -
 arch/arm/configs/omap2plus_defconfig               |   27 +
 arch/arm/configs/qcom_defconfig                    |    9 +-
 arch/arm/configs/shmobile_defconfig                |    9 +-
 arch/arm/configs/sunxi_defconfig                   |    1 +
 arch/arm/crypto/Kconfig                            |  130 +
 arch/arm/crypto/Makefile                           |   27 +-
 arch/arm/crypto/aes-ce-core.S                      |  518 ++
 arch/arm/crypto/aes-ce-glue.c                      |  524 ++
 arch/arm/crypto/aesbs-glue.c                       |    9 +-
 arch/arm/crypto/ghash-ce-core.S                    |   94 +
 arch/arm/crypto/ghash-ce-glue.c                    |  320 ++
 arch/arm/crypto/sha1-ce-core.S                     |  125 +
 arch/arm/crypto/sha1-ce-glue.c                     |   96 +
 arch/arm/{include/asm =3D> }/crypto/sha1.h           |    3 +
 arch/arm/crypto/sha1_glue.c                        |  112 +-
 arch/arm/crypto/sha1_neon_glue.c                   |  137 +-
 arch/arm/crypto/sha2-ce-core.S                     |  125 +
 arch/arm/crypto/sha2-ce-glue.c                     |  114 +
 arch/arm/crypto/sha256-armv4.pl                    |  716 +++
 arch/arm/crypto/sha256-core.S_shipped              | 2808 ++++++++++
 arch/arm/crypto/sha256_glue.c                      |  128 +
 arch/arm/crypto/sha256_glue.h                      |   14 +
 arch/arm/crypto/sha256_neon_glue.c                 |  101 +
 arch/arm/include/asm/Kbuild                        |    1 +
 arch/arm/include/asm/arm-cci.h                     |   42 +
 arch/arm/include/asm/kvm_mmu.h                     |   10 +
 arch/arm/include/asm/mcpm.h                        |   65 +-
 arch/arm/include/asm/seccomp.h                     |   11 -
 arch/arm/include/asm/thread_info.h                 |    3 -
 arch/arm/include/debug/msm.S                       |   14 -
 arch/arm/include/uapi/asm/kvm.h                    |    8 +-
 arch/arm/kernel/Makefile                           |    1 -
 arch/arm/kernel/arthur.c                           |   94 -
 arch/arm/kernel/asm-offsets.c                      |    1 -
 arch/arm/kernel/head-nommu.S                       |   12 +-
 arch/arm/kernel/signal.c                           |   13 +-
 arch/arm/kernel/traps.c                            |    6 +-
 arch/arm/kernel/vmlinux.lds.S                      |   11 +-
 arch/arm/kvm/arm.c                                 |    3 +-
 arch/arm/kvm/mmu.c                                 |   69 +-
 arch/arm/mach-alpine/Kconfig                       |   12 +
 arch/arm/mach-alpine/Makefile                      |    2 +
 arch/arm/mach-alpine/alpine_cpu_pm.c               |   70 +
 .../mach/io.h =3D> mach-alpine/alpine_cpu_pm.h}      |   21 +-
 arch/arm/mach-alpine/alpine_cpu_resume.h           |   38 +
 .../mach-alpine/alpine_machine.c}                  |   26 +-
 arch/arm/mach-alpine/platsmp.c                     |   49 +
 arch/arm/mach-at91/Kconfig                         |  132 +-
 arch/arm/mach-at91/Makefile                        |   11 +-
 arch/arm/mach-at91/at91rm9200.c                    |   46 +-
 arch/arm/mach-at91/at91sam9.c                      |   76 +-
 arch/arm/mach-at91/generic.h                       |    7 -
 arch/arm/mach-at91/include/mach/at91_dbgu.h        |   63 -
 arch/arm/mach-at91/include/mach/at91_matrix.h      |   23 -
 arch/arm/mach-at91/include/mach/at91_ramc.h        |    4 -
 arch/arm/mach-at91/include/mach/at91_st.h          |   61 -
 arch/arm/mach-at91/include/mach/at91rm9200.h       |  103 -
 arch/arm/mach-at91/include/mach/at91sam9260.h      |  129 -
 .../mach-at91/include/mach/at91sam9260_matrix.h    |   80 -
 arch/arm/mach-at91/include/mach/at91sam9261.h      |   99 -
 .../mach-at91/include/mach/at91sam9261_matrix.h    |   64 -
 arch/arm/mach-at91/include/mach/at91sam9263.h      |  117 -
 .../mach-at91/include/mach/at91sam9263_matrix.h    |  129 -
 arch/arm/mach-at91/include/mach/at91sam9_smc.h     |    2 -
 arch/arm/mach-at91/include/mach/at91sam9g45.h      |  143 -
 .../mach-at91/include/mach/at91sam9g45_matrix.h    |  153 -
 arch/arm/mach-at91/include/mach/at91sam9n12.h      |   65 -
 .../mach-at91/include/mach/at91sam9n12_matrix.h    |   53 -
 arch/arm/mach-at91/include/mach/at91sam9rl.h       |  105 -
 .../arm/mach-at91/include/mach/at91sam9rl_matrix.h |   96 -
 arch/arm/mach-at91/include/mach/at91sam9x5.h       |   71 -
 .../arm/mach-at91/include/mach/at91sam9x5_matrix.h |   53 -
 arch/arm/mach-at91/include/mach/cpu.h              |  216 -
 arch/arm/mach-at91/include/mach/hardware.h         |  134 -
 arch/arm/mach-at91/include/mach/sama5d3.h          |   86 -
 arch/arm/mach-at91/include/mach/sama5d4.h          |   33 -
 arch/arm/mach-at91/include/mach/uncompress.h       |  218 -
 arch/arm/mach-at91/pm.c                            |  238 +-
 arch/arm/mach-at91/pm.h                            |  100 +-
 arch/arm/mach-at91/pm_slowclock.S                  |  335 --
 arch/arm/mach-at91/pm_suspend.S                    |  337 ++
 arch/arm/mach-at91/sama5.c                         |   95 +-
 arch/arm/mach-at91/setup.c                         |  330 --
 arch/arm/mach-at91/soc.c                           |   97 +
 arch/arm/mach-at91/soc.h                           |   78 +
 arch/arm/mach-bcm/bcm_cygnus.c                     |    2 +-
 arch/arm/mach-cns3xxx/pm.c                         |    1 -
 arch/arm/mach-davinci/Kconfig                      |   11 -
 arch/arm/mach-davinci/asp.h                        |    7 +
 arch/arm/mach-davinci/board-da850-evm.c            |  112 -
 arch/arm/mach-davinci/devices-da8xx.c              |   80 +-
 arch/arm/mach-davinci/dm646x.c                     |   24 +-
 arch/arm/mach-davinci/include/mach/irqs.h          |    2 +-
 arch/arm/mach-exynos/Kconfig                       |    2 +-
 arch/arm/mach-exynos/common.h                      |    6 +
 arch/arm/mach-exynos/exynos.c                      |    3 +-
 arch/arm/mach-exynos/firmware.c                    |   33 +-
 arch/arm/mach-exynos/mcpm-exynos.c                 |  247 +-
 arch/arm/mach-exynos/platsmp.c                     |   23 +-
 arch/arm/mach-exynos/pm.c                          |   14 +-
 arch/arm/mach-exynos/pm_domains.c                  |   29 +-
 arch/arm/mach-exynos/regs-pmu.h                    |    3 +
 arch/arm/mach-exynos/smc.h                         |    9 +
 arch/arm/mach-exynos/suspend.c                     |   22 +-
 arch/arm/mach-imx/Kconfig                          |   84 +-
 arch/arm/mach-imx/Makefile                         |    8 +-
 arch/arm/mach-imx/clk-imx25.c                      |   75 -
 arch/arm/mach-imx/clk-imx6q.c                      |    8 +-
 arch/arm/mach-imx/common.h                         |    7 +-
 arch/arm/mach-imx/cpu-imx25.c                      |   11 +-
 arch/arm/mach-imx/devices-imx25.h                  |   85 -
 arch/arm/mach-imx/devices/Kconfig                  |    3 -
 arch/arm/mach-imx/devices/Makefile                 |    1 -
 arch/arm/mach-imx/devices/platform-fec.c           |    5 -
 arch/arm/mach-imx/devices/platform-fsl-usb2-udc.c  |    5 -
 arch/arm/mach-imx/devices/platform-imx-fb.c        |    5 -
 arch/arm/mach-imx/devices/platform-imx-i2c.c       |   10 -
 arch/arm/mach-imx/devices/platform-imx-keypad.c    |    5 -
 arch/arm/mach-imx/devices/platform-imx-ssi.c       |    9 -
 arch/arm/mach-imx/devices/platform-imx-uart.c      |   12 -
 arch/arm/mach-imx/devices/platform-imx2-wdt.c      |    5 -
 arch/arm/mach-imx/devices/platform-imxdi_rtc.c     |   42 -
 arch/arm/mach-imx/devices/platform-mx2-camera.c    |    5 -
 arch/arm/mach-imx/devices/platform-mxc-ehci.c      |    7 -
 arch/arm/mach-imx/devices/platform-mxc_nand.c      |    5 -
 arch/arm/mach-imx/devices/platform-spi_imx.c       |   11 -
 arch/arm/mach-imx/ehci-imx25.c                     |   99 -
 arch/arm/mach-imx/eukrea_mbimxsd25-baseboard.c     |  310 --
 arch/arm/mach-imx/eukrea_mbimxsd35-baseboard.c     |    2 +-
 arch/arm/mach-imx/gpc.c                            |  353 +-
 arch/arm/mach-imx/hardware.h                       |    1 -
 arch/arm/mach-imx/iomux-mx25.h                     |  524 --
 arch/arm/mach-imx/iomux-mx3.h                      |    2 +-
 arch/arm/mach-imx/iomux-v3.c                       |    5 +-
 arch/arm/mach-imx/iomux-v3.h                       |    5 +-
 arch/arm/mach-imx/mach-cpuimx35.c                  |    2 +-
 arch/arm/mach-imx/mach-eukrea_cpuimx25.c           |  172 -
 arch/arm/mach-imx/{imx25-dt.c =3D> mach-imx25.c}     |   20 +-
 arch/arm/mach-imx/mach-imx6q.c                     |    2 +-
 arch/arm/mach-imx/mach-imx6sl.c                    |    2 +-
 arch/arm/mach-imx/mach-imx6sx.c                    |    2 +-
 arch/arm/mach-imx/mach-mx25_3ds.c                  |  270 -
 arch/arm/mach-imx/mach-mx35_3ds.c                  |    2 +-
 arch/arm/mach-imx/mach-pcm043.c                    |    2 +-
 arch/arm/mach-imx/mach-vpr200.c                    |    2 +-
 arch/arm/mach-imx/mm-imx25.c                       |   89 -
 arch/arm/mach-imx/mx25.h                           |  117 -
 arch/arm/mach-imx/pm-imx6.c                        |    6 +-
 arch/arm/mach-mediatek/Kconfig                     |    1 +
 arch/arm/mach-meson/Kconfig                        |    3 +
 arch/arm/mach-msm/Kconfig                          |  109 -
 arch/arm/mach-msm/Makefile                         |   23 -
 arch/arm/mach-msm/Makefile.boot                    |    3 -
 arch/arm/mach-msm/board-halibut.c                  |  110 -
 arch/arm/mach-msm/board-msm7x30.c                  |  191 -
 arch/arm/mach-msm/board-qsd8x50.c                  |  254 -
 arch/arm/mach-msm/board-sapphire.c                 |  114 -
 arch/arm/mach-msm/board-trout-gpio.c               |  233 -
 arch/arm/mach-msm/board-trout-mmc.c                |  185 -
 arch/arm/mach-msm/board-trout-panel.c              |  292 --
 arch/arm/mach-msm/board-trout.c                    |  111 -
 arch/arm/mach-msm/board-trout.h                    |  162 -
 arch/arm/mach-msm/clock-pcom.c                     |  176 -
 arch/arm/mach-msm/clock-pcom.h                     |  145 -
 arch/arm/mach-msm/clock.c                          |   28 -
 arch/arm/mach-msm/clock.h                          |   43 -
 arch/arm/mach-msm/common.h                         |   41 -
 arch/arm/mach-msm/devices-msm7x00.c                |  480 --
 arch/arm/mach-msm/devices-msm7x30.c                |  246 -
 arch/arm/mach-msm/devices-qsd8x50.c                |  388 --
 arch/arm/mach-msm/devices.h                        |   53 -
 arch/arm/mach-msm/dma.c                            |  298 --
 arch/arm/mach-msm/gpiomux-8x50.c                   |   51 -
 arch/arm/mach-msm/gpiomux-v1.h                     |   67 -
 arch/arm/mach-msm/gpiomux.c                        |  111 -
 arch/arm/mach-msm/gpiomux.h                        |   84 -
 arch/arm/mach-msm/include/mach/clk.h               |   31 -
 arch/arm/mach-msm/include/mach/dma.h               |  151 -
 arch/arm/mach-msm/include/mach/entry-macro.S       |   36 -
 arch/arm/mach-msm/include/mach/hardware.h          |   18 -
 arch/arm/mach-msm/include/mach/irqs-7x00.h         |   75 -
 arch/arm/mach-msm/include/mach/irqs-7x30.h         |  153 -
 arch/arm/mach-msm/include/mach/irqs-8x50.h         |   88 -
 arch/arm/mach-msm/include/mach/irqs.h              |   37 -
 arch/arm/mach-msm/include/mach/msm_gpiomux.h       |   38 -
 arch/arm/mach-msm/include/mach/msm_iomap-7x00.h    |  108 -
 arch/arm/mach-msm/include/mach/msm_iomap-7x30.h    |  103 -
 arch/arm/mach-msm/include/mach/msm_iomap-8x50.h    |  125 -
 arch/arm/mach-msm/include/mach/msm_iomap.h         |   53 -
 arch/arm/mach-msm/include/mach/msm_smd.h           |  109 -
 arch/arm/mach-msm/include/mach/sirc.h              |   98 -
 arch/arm/mach-msm/include/mach/vreg.h              |   29 -
 arch/arm/mach-msm/io.c                             |  161 -
 arch/arm/mach-msm/irq-vic.c                        |  363 --
 arch/arm/mach-msm/irq.c                            |  151 -
 arch/arm/mach-msm/last_radio_log.c                 |   71 -
 arch/arm/mach-msm/proc_comm.c                      |  129 -
 arch/arm/mach-msm/proc_comm.h                      |  258 -
 arch/arm/mach-msm/sirc.c                           |  172 -
 arch/arm/mach-msm/smd.c                            | 1034 ----
 arch/arm/mach-msm/smd_debug.c                      |  311 --
 arch/arm/mach-msm/smd_private.h                    |  403 --
 arch/arm/mach-msm/vreg.c                           |  220 -
 arch/arm/mach-mvebu/Kconfig                        |   14 +
 arch/arm/mach-mvebu/board-v7.c                     |   20 +-
 arch/arm/mach-mvebu/dove.c                         |    2 +-
 arch/arm/mach-mvebu/kirkwood.c                     |    2 +-
 arch/arm/mach-mvebu/platsmp-a9.c                   |    2 +
 arch/arm/mach-mvebu/pmsu.c                         |   16 +-
 arch/arm/mach-omap1/pm.c                           |   51 +-
 arch/arm/mach-omap2/Kconfig                        |   41 +-
 arch/arm/mach-omap2/Makefile                       |    4 -
 arch/arm/mach-omap2/board-cm-t35.c                 |   57 +-
 arch/arm/mach-omap2/board-devkit8000.c             |  654 ---
 arch/arm/mach-omap2/board-omap3stalker.c           |  433 --
 arch/arm/mach-omap2/board-omap3touchbook.c         |  395 --
 arch/arm/mach-omap2/clock.c                        |  111 +-
 arch/arm/mach-omap2/clock.h                        |    8 +-
 arch/arm/mach-omap2/cm.h                           |    2 +
 arch/arm/mach-omap2/cm2xxx.c                       |    2 +-
 arch/arm/mach-omap2/cm2xxx.h                       |    2 +-
 arch/arm/mach-omap2/cm33xx.c                       |    2 +-
 arch/arm/mach-omap2/cm33xx.h                       |    3 +-
 arch/arm/mach-omap2/cm3xxx.c                       |    3 +-
 arch/arm/mach-omap2/cm3xxx.h                       |    2 +-
 arch/arm/mach-omap2/cm44xx.h                       |    3 +-
 arch/arm/mach-omap2/cm_common.c                    |  156 +
 arch/arm/mach-omap2/cminst44xx.c                   |    6 +-
 arch/arm/mach-omap2/common.c                       |    1 -
 arch/arm/mach-omap2/common.h                       |    3 -
 arch/arm/mach-omap2/control.c                      |  201 +-
 arch/arm/mach-omap2/control.h                      |   10 +-
 arch/arm/mach-omap2/devices.c                      |   76 +-
 arch/arm/mach-omap2/display.c                      |   15 +-
 arch/arm/mach-omap2/gpmc-nand.c                    |   18 +-
 arch/arm/mach-omap2/gpmc-onenand.c                 |    4 +-
 arch/arm/mach-omap2/id.c                           |    5 +-
 arch/arm/mach-omap2/io.c                           |  114 +-
 arch/arm/mach-omap2/mux.c                          |    2 +-
 arch/arm/mach-omap2/omap-secure.h                  |    7 -
 arch/arm/mach-omap2/omap34xx.h                     |   36 +-
 arch/arm/mach-omap2/omap4-common.c                 |   69 -
 arch/arm/mach-omap2/omap_device.c                  |    3 +
 arch/arm/mach-omap2/omap_hwmod_43xx_data.c         |   36 +
 arch/arm/mach-omap2/omap_hwmod_7xx_data.c          |  113 +-
 arch/arm/mach-omap2/pdata-quirks.c                 |   74 -
 arch/arm/mach-omap2/pm24xx.c                       |   24 +-
 arch/arm/mach-omap2/pm34xx.c                       |   18 +-
 arch/arm/mach-omap2/prcm-common.h                  |   20 +
 arch/arm/mach-omap2/prcm43xx.h                     |    1 +
 arch/arm/mach-omap2/prm.h                          |   27 +-
 arch/arm/mach-omap2/prm2xxx.c                      |    6 +-
 arch/arm/mach-omap2/prm2xxx.h                      |    4 +-
 arch/arm/mach-omap2/prm33xx.c                      |    2 +-
 arch/arm/mach-omap2/prm33xx.h                      |    2 +-
 arch/arm/mach-omap2/prm3xxx.c                      |   20 +-
 arch/arm/mach-omap2/prm3xxx.h                      |    7 +-
 arch/arm/mach-omap2/prm44xx.c                      |   70 +-
 arch/arm/mach-omap2/prm44xx.h                      |    1 -
 arch/arm/mach-omap2/prm44xx_54xx.h                 |    8 +-
 arch/arm/mach-omap2/prm54xx.h                      |    1 -
 arch/arm/mach-omap2/prm7xx.h                       |    2 +-
 arch/arm/mach-omap2/prm_common.c                   |  258 +-
 arch/arm/mach-omap2/prminst44xx.c                  |   18 +-
 arch/arm/mach-omap2/prminst44xx.h                  |    1 +
 arch/arm/mach-omap2/sleep44xx.S                    |    2 -
 arch/arm/mach-omap2/usb-tusb6010.c                 |    4 +-
 arch/arm/mach-omap2/vp.h                           |    9 -
 arch/arm/mach-omap2/vp3xxx_data.c                  |    4 +-
 arch/arm/mach-omap2/vp44xx_data.c                  |    4 +-
 arch/arm/mach-qcom/Kconfig                         |    3 -
 arch/arm/mach-qcom/Makefile                        |    3 -
 arch/arm/mach-qcom/platsmp.c                       |   23 +-
 arch/arm/mach-qcom/scm-boot.c                      |   39 -
 arch/arm/mach-qcom/scm.c                           |  326 --
 arch/arm/mach-rockchip/platsmp.c                   |    4 +-
 arch/arm/mach-rockchip/pm.c                        |   14 +-
 arch/arm/mach-rockchip/pm.h                        |    6 +
 arch/arm/mach-s3c24xx/Kconfig                      |   19 +-
 arch/arm/mach-s3c24xx/Makefile                     |    3 +-
 arch/arm/mach-s3c24xx/include/mach/pm-core.h       |   24 +-
 arch/arm/mach-s3c24xx/pm-s3c2416.c                 |    3 +-
 arch/arm/mach-s3c24xx/pm.c                         |    6 +-
 arch/arm/mach-s3c24xx/s3c2410.c                    |    2 +-
 arch/arm/mach-s3c24xx/s3c2412.c                    |    2 +-
 arch/arm/mach-s3c24xx/s3c2416.c                    |    2 +-
 arch/arm/mach-s3c24xx/s3c2440.c                    |    4 +-
 arch/arm/mach-s3c24xx/s3c2442.c                    |    4 +-
 arch/arm/mach-s3c24xx/s3c244x.c                    |    7 +-
 arch/arm/mach-s3c64xx/Kconfig                      |    4 +-
 arch/arm/mach-s3c64xx/Makefile                     |    3 +-
 arch/arm/mach-s3c64xx/crag6410.h                   |    1 +
 arch/arm/mach-s3c64xx/mach-crag6410.c              |    1 +
 arch/arm/mach-s3c64xx/mach-smdk6410.c              |    2 +-
 arch/arm/mach-s3c64xx/pm.c                         |    2 +
 arch/arm/mach-shmobile/Kconfig                     |   66 +-
 arch/arm/mach-shmobile/Makefile                    |   22 +-
 arch/arm/mach-shmobile/Makefile.boot               |    4 -
 arch/arm/mach-shmobile/board-ape6evm-reference.c   |   60 -
 arch/arm/mach-shmobile/board-ape6evm.c             |  306 --
 arch/arm/mach-shmobile/board-armadillo800eva.c     |   23 +-
 arch/arm/mach-shmobile/board-bockw-reference.c     |    2 +
 arch/arm/mach-shmobile/board-bockw.c               |   14 +-
 arch/arm/mach-shmobile/board-kzm9g-reference.c     |   62 -
 arch/arm/mach-shmobile/board-kzm9g.c               |   20 +-
 arch/arm/mach-shmobile/board-mackerel.c            | 1522 ------
 arch/arm/mach-shmobile/board-marzen.c              |   10 +-
 arch/arm/mach-shmobile/clock-r8a73a4.c             |  659 ---
 arch/arm/mach-shmobile/clock-sh7372.c              |  620 ---
 arch/arm/mach-shmobile/clock.c                     |   11 -
 arch/arm/mach-shmobile/common.h                    |   10 -
 arch/arm/mach-shmobile/cpuidle.c                   |   37 -
 arch/arm/mach-shmobile/entry-intc.S                |   54 -
 arch/arm/mach-shmobile/include/mach/clkdev.h       |    7 -
 .../mach-shmobile/include/mach/head-mackerel.txt   |   93 -
 arch/arm/mach-shmobile/include/mach/mmc-mackerel.h |   38 -
 arch/arm/mach-shmobile/include/mach/mmc.h          |   16 -
 arch/arm/mach-shmobile/include/mach/sdhi-sh7372.h  |   21 -
 arch/arm/mach-shmobile/include/mach/sdhi.h         |   16 -
 arch/arm/mach-shmobile/include/mach/system.h       |   11 -
 arch/arm/mach-shmobile/include/mach/uncompress.h   |   19 -
 arch/arm/mach-shmobile/include/mach/zboot.h        |    5 +-
 arch/arm/mach-shmobile/intc-sh7372.c               |  672 ---
 arch/arm/mach-shmobile/pm-r8a7790.c                |   82 -
 arch/arm/mach-shmobile/pm-r8a7791.c                |   73 -
 arch/arm/mach-shmobile/pm-rcar-gen2.c              |  115 +
 arch/arm/mach-shmobile/pm-sh7372.c                 |  549 --
 arch/arm/mach-shmobile/r8a73a4.h                   |   17 -
 arch/arm/mach-shmobile/r8a7790.h                   |    1 -
 arch/arm/mach-shmobile/r8a7791.h                   |    1 -
 arch/arm/mach-shmobile/rcar-gen2.h                 |    1 +
 arch/arm/mach-shmobile/regulator-quirk-rcar-gen2.c |  147 +
 arch/arm/mach-shmobile/setup-r8a73a4.c             |  273 +-
 arch/arm/mach-shmobile/setup-r8a7740.c             |    8 -
 arch/arm/mach-shmobile/setup-r8a7778.c             |   19 +
 arch/arm/mach-shmobile/setup-rcar-gen2.c           |    7 +-
 arch/arm/mach-shmobile/setup-sh7372.c              | 1016 ----
 arch/arm/mach-shmobile/setup-sh73a0.c              |   19 +-
 arch/arm/mach-shmobile/sh7372.h                    |   84 -
 arch/arm/mach-shmobile/sh73a0.h                    |    1 -
 arch/arm/mach-shmobile/sleep-sh7372.S              |   98 -
 arch/arm/mach-shmobile/smp-r8a7779.c               |    7 -
 arch/arm/mach-shmobile/smp-r8a7790.c               |    7 +-
 arch/arm/mach-shmobile/smp-r8a7791.c               |    4 +-
 arch/arm/mach-shmobile/smp-sh73a0.c                |    2 +-
 arch/arm/mach-vexpress/Kconfig                     |    4 +-
 arch/arm/mach-vexpress/dcscb.c                     |  197 +-
 arch/arm/mach-vexpress/tc2_pm.c                    |  291 +-
 arch/arm/mm/Kconfig                                |    2 +-
 arch/arm/plat-pxa/dma.c                            |  111 +-
 arch/arm/plat-samsung/include/plat/pm.h            |   14 +-
 arch/arm/plat-samsung/pm-debug.c                   |    1 +
 arch/arm/plat-samsung/pm.c                         |   20 -
 arch/arm/tools/mach-types                          |    1 -
 arch/arm/vdso/.gitignore                           |    2 +
 arch/arm/vdso/Makefile                             |    4 +-
 arch/arm/xen/enlighten.c                           |  104 +-
 arch/arm64/Kconfig                                 |   56 +-
 arch/arm64/Kconfig.debug                           |    2 +
 arch/arm64/Makefile                                |    2 +-
 arch/arm64/boot/dts/Makefile                       |    3 +
 arch/arm64/boot/dts/apm/apm-storm.dtsi             |   26 +
 arch/arm64/boot/dts/arm/juno.dts                   |   14 +-
 arch/arm64/boot/dts/mediatek/mt8173-pinfunc.h      |  682 +++
 arch/arm64/boot/dts/mediatek/mt8173.dtsi           |   20 +
 arch/arm64/boot/dts/qcom/Makefile                  |    5 +
 .../boot/dts/qcom/apq8016-sbc.dts}                 |   21 +-
 .../scm.h =3D> arm64/boot/dts/qcom/apq8016-sbc.dtsi} |   30 +-
 arch/arm64/boot/dts/qcom/msm8916-mtp.dts           |   22 +
 arch/arm64/boot/dts/qcom/msm8916-mtp.dtsi          |   33 +
 arch/arm64/boot/dts/qcom/msm8916.dtsi              |  196 +
 arch/arm64/boot/dts/sprd/Makefile                  |    5 +
 arch/arm64/boot/dts/sprd/sc9836-openphone.dts      |   49 +
 arch/arm64/boot/dts/sprd/sc9836.dtsi               |  129 +
 arch/arm64/boot/dts/sprd/sharkl64.dtsi             |   65 +
 arch/arm64/boot/dts/xilinx/Makefile                |    5 +
 arch/arm64/boot/dts/xilinx/zynqmp-ep108.dts        |   47 +
 arch/arm64/boot/dts/xilinx/zynqmp.dtsi             |  305 ++
 arch/arm64/configs/defconfig                       |   24 +-
 arch/arm64/crypto/aes-ce-ccm-core.S                |   12 +-
 arch/arm64/crypto/aes-ce.S                         |   10 +-
 arch/arm64/crypto/aes-glue.c                       |   12 +-
 arch/arm64/crypto/sha1-ce-core.S                   |   33 +-
 arch/arm64/crypto/sha1-ce-glue.c                   |  151 +-
 arch/arm64/crypto/sha2-ce-core.S                   |   29 +-
 arch/arm64/crypto/sha2-ce-glue.c                   |  227 +-
 arch/arm64/include/asm/acenv.h                     |   18 +
 arch/arm64/include/asm/acpi.h                      |   96 +
 arch/arm64/include/asm/{cputable.h =3D> arm-cci.h}   |   21 +-
 arch/arm64/include/asm/assembler.h                 |   48 +
 arch/arm64/include/asm/cpu_ops.h                   |    1 +
 arch/arm64/include/asm/cpufeature.h                |   18 +-
 arch/arm64/include/asm/dma-mapping.h               |    2 +-
 arch/arm64/include/asm/fixmap.h                    |    5 +-
 arch/arm64/include/asm/insn.h                      |    1 +
 arch/arm64/include/asm/irq.h                       |   13 +
 arch/arm64/include/asm/kvm_mmu.h                   |   33 +
 arch/arm64/include/asm/mmu_context.h               |   43 +
 arch/arm64/include/asm/page.h                      |    6 +-
 arch/arm64/include/asm/pci.h                       |    6 +
 arch/arm64/include/asm/pgtable-hwdef.h             |    7 +-
 arch/arm64/include/asm/pmu.h                       |    1 +
 arch/arm64/include/asm/proc-fns.h                  |    9 -
 arch/arm64/include/asm/processor.h                 |    6 +-
 arch/arm64/include/asm/psci.h                      |    3 +-
 arch/arm64/include/asm/smp.h                       |    5 +-
 arch/arm64/include/asm/smp_plat.h                  |    2 +
 arch/arm64/include/asm/thread_info.h               |    3 -
 arch/arm64/include/asm/unistd32.h                  |    2 +-
 arch/arm64/include/uapi/asm/kvm.h                  |    8 +-
 arch/arm64/kernel/Makefile                         |    5 +-
 arch/arm64/kernel/acpi.c                           |  345 ++
 arch/arm64/kernel/alternative.c                    |   55 +-
 arch/arm64/kernel/asm-offsets.c                    |    5 -
 arch/arm64/kernel/cpu_errata.c                     |   47 +-
 arch/arm64/kernel/cpu_ops.c                        |    2 +-
 arch/arm64/kernel/cpufeature.c                     |   47 +
 arch/arm64/kernel/cpuinfo.c                        |    1 +
 arch/arm64/kernel/cputable.c                       |   33 -
 arch/arm64/kernel/entry.S                          |   20 +
 arch/arm64/kernel/entry32.S                        |   18 +
 arch/arm64/kernel/head.S                           |  261 +-
 arch/arm64/kernel/insn.c                           |   81 +-
 arch/arm64/kernel/pci.c                            |   25 +
 arch/arm64/kernel/perf_event.c                     |   78 +-
 arch/arm64/kernel/psci.c                           |  112 +-
 arch/arm64/kernel/setup.c                          |   76 +-
 arch/arm64/kernel/signal.c                         |    7 -
 arch/arm64/kernel/smp.c                            |    7 +-
 arch/arm64/kernel/sys32.c                          |    1 +
 arch/arm64/kernel/time.c                           |    7 +
 arch/arm64/kernel/vmlinux.lds.S                    |   17 +-
 arch/arm64/kvm/hyp-init.S                          |   25 +
 arch/arm64/mm/mmu.c                                |   12 +-
 arch/arm64/mm/pageattr.c                           |    2 -
 arch/arm64/mm/proc-macros.S                        |   10 +
 arch/arm64/mm/proc.S                               |    3 +
 arch/avr32/include/asm/thread_info.h               |    3 -
 arch/avr32/kernel/asm-offsets.c                    |    1 -
 arch/blackfin/configs/BF518F-EZBRD_defconfig       |    1 -
 arch/blackfin/configs/BF527-TLL6527M_defconfig     |    1 -
 arch/blackfin/configs/BF533-EZKIT_defconfig        |    1 -
 arch/blackfin/configs/BF533-STAMP_defconfig        |    1 -
 arch/blackfin/configs/BF537-STAMP_defconfig        |    3 +-
 arch/blackfin/configs/BF538-EZKIT_defconfig        |    1 -
 arch/blackfin/configs/BF561-ACVILON_defconfig      |    1 -
 arch/blackfin/configs/BF561-EZKIT-SMP_defconfig    |    1 -
 arch/blackfin/configs/BF561-EZKIT_defconfig        |    1 -
 arch/blackfin/configs/BF609-EZKIT_defconfig        |    1 +
 arch/blackfin/configs/CM-BF527_defconfig           |    1 -
 arch/blackfin/configs/CM-BF533_defconfig           |    1 -
 arch/blackfin/configs/CM-BF537E_defconfig          |    1 -
 arch/blackfin/configs/CM-BF537U_defconfig          |    1 -
 arch/blackfin/configs/CM-BF548_defconfig           |    1 -
 arch/blackfin/configs/CM-BF561_defconfig           |    1 -
 arch/blackfin/configs/DNP5370_defconfig            |    1 -
 arch/blackfin/configs/IP0X_defconfig               |    1 -
 arch/blackfin/configs/PNAV-10_defconfig            |    1 -
 arch/blackfin/configs/SRV1_defconfig               |    1 -
 arch/blackfin/configs/TCM-BF518_defconfig          |    1 -
 arch/blackfin/configs/TCM-BF537_defconfig          |    1 -
 arch/blackfin/include/asm/io.h                     |   35 +-
 arch/blackfin/include/asm/thread_info.h            |   11 -
 arch/blackfin/include/uapi/asm/unistd.h            |   12 +-
 arch/blackfin/kernel/asm-offsets.c                 |    6 +
 arch/blackfin/kernel/debug-mmrs.c                  |    1 -
 arch/blackfin/kernel/kgdb.c                        |   25 +-
 arch/blackfin/kernel/setup.c                       |    2 +-
 arch/blackfin/kernel/signal.c                      |    6 +-
 arch/blackfin/kernel/traps.c                       |    1 +
 arch/blackfin/mach-bf527/include/mach/cdefBF525.h  |    5 -
 arch/blackfin/mach-bf527/include/mach/defBF525.h   |    4 -
 arch/blackfin/mach-bf548/include/mach/cdefBF542.h  |    4 -
 arch/blackfin/mach-bf548/include/mach/cdefBF547.h  |    4 -
 arch/blackfin/mach-bf548/include/mach/defBF542.h   |    3 -
 arch/blackfin/mach-bf548/include/mach/defBF547.h   |    3 -
 arch/blackfin/mach-bf561/smp.c                     |    2 +-
 arch/blackfin/mach-bf609/boards/ezkit.c            |   90 +-
 arch/blackfin/mach-bf609/clock.c                   |    7 +
 arch/blackfin/mach-common/entry.S                  |   10 +
 arch/blackfin/mach-common/pm.c                     |    2 +
 arch/c6x/Makefile                                  |    2 +-
 arch/c6x/include/asm/Kbuild                        |    1 +
 arch/c6x/include/asm/dma-mapping.h                 |    8 +
 arch/c6x/include/asm/flat.h                        |   12 +
 arch/c6x/include/asm/setup.h                       |    1 +
 arch/c6x/include/asm/thread_info.h                 |    2 -
 arch/c6x/kernel/setup.c                            |   10 +-
 arch/c6x/kernel/time.c                             |    2 +-
 arch/c6x/platforms/cache.c                         |    2 +
 arch/cris/Kconfig                                  |   12 +-
 arch/cris/Makefile                                 |    4 +
 arch/cris/arch-v10/kernel/fasttimer.c              |   85 +-
 arch/cris/arch-v10/kernel/setup.c                  |   58 +-
 arch/cris/arch-v10/kernel/signal.c                 |    2 -
 arch/cris/arch-v32/kernel/Makefile                 |    1 -
 arch/cris/arch-v32/kernel/entry.S                  |   42 +-
 arch/cris/arch-v32/kernel/fasttimer.c              |   85 +-
 arch/cris/arch-v32/kernel/head.S                   |   32 -
 arch/cris/arch-v32/kernel/irq.c                    |   31 +-
 arch/cris/arch-v32/kernel/setup.c                  |   67 +-
 arch/cris/arch-v32/kernel/signal.c                 |    7 +-
 arch/cris/arch-v32/kernel/smp.c                    |  358 --
 arch/cris/arch-v32/kernel/time.c                   |  180 +-
 arch/cris/arch-v32/lib/Makefile                    |    2 +-
 arch/cris/arch-v32/lib/spinlock.S                  |   40 -
 arch/cris/arch-v32/mm/init.c                       |   11 -
 arch/cris/arch-v32/mm/mmu.S                        |    4 -
 arch/cris/boot/dts/Makefile                        |    6 +
 arch/cris/boot/dts/dev88.dts                       |   18 +
 arch/cris/boot/dts/etraxfs.dtsi                    |   38 +
 arch/cris/include/arch-v10/arch/atomic.h           |    7 -
 arch/cris/include/arch-v10/arch/system.h           |    8 -
 arch/cris/include/arch-v32/arch/atomic.h           |   36 -
 arch/cris/include/arch-v32/arch/processor.h        |    3 +-
 arch/cris/include/arch-v32/arch/spinlock.h         |  131 -
 arch/cris/include/asm/Kbuild                       |   15 +-
 arch/cris/include/asm/atomic.h                     |  149 -
 arch/cris/include/asm/bitops.h                     |  111 +-
 arch/cris/include/asm/cmpxchg.h                    |   53 -
 arch/cris/include/asm/device.h                     |    7 -
 arch/cris/include/asm/div64.h                      |    1 -
 arch/cris/include/asm/elf.h                        |    2 +-
 arch/cris/include/asm/emergency-restart.h          |    6 -
 arch/cris/include/asm/futex.h                      |    6 -
 arch/cris/include/asm/hardirq.h                    |    7 -
 arch/cris/include/asm/irq_regs.h                   |    1 -
 arch/cris/include/asm/kdebug.h                     |    1 -
 arch/cris/include/asm/kmap_types.h                 |   10 -
 arch/cris/include/asm/local.h                      |    1 -
 arch/cris/include/asm/local64.h                    |    1 -
 arch/cris/include/asm/percpu.h                     |    6 -
 arch/cris/include/asm/smp.h                        |   10 -
 arch/cris/include/asm/spinlock.h                   |    1 -
 arch/cris/include/asm/thread_info.h                |    2 -
 arch/cris/include/asm/tlbflush.h                   |    7 -
 arch/cris/include/asm/topology.h                   |    6 -
 arch/cris/kernel/Makefile                          |    1 +
 arch/cris/kernel/devicetree.c                      |   14 +
 arch/cris/kernel/ptrace.c                          |   23 +
 arch/cris/kernel/setup.c                           |   15 +
 arch/cris/kernel/time.c                            |    2 +
 arch/frv/include/asm/io.h                          |    5 +
 arch/frv/include/asm/thread_info.h                 |    2 -
 arch/frv/kernel/asm-offsets.c                      |    1 -
 arch/frv/kernel/signal.c                           |   20 +-
 arch/hexagon/include/asm/thread_info.h             |    2 -
 arch/ia64/Kconfig                                  |    1 +
 arch/ia64/include/asm/acpi.h                       |    6 +-
 arch/ia64/include/asm/thread_info.h                |    2 -
 arch/ia64/kernel/Makefile                          |    2 +-
 arch/ia64/kernel/acpi.c                            |    4 +-
 arch/ia64/kernel/iosapic.c                         |    2 +-
 arch/ia64/kernel/irq_ia64.c                        |   36 +-
 arch/ia64/kernel/mca.c                             |   10 +-
 arch/ia64/kernel/msi_ia64.c                        |   10 +-
 arch/ia64/kernel/numa.c                            |   10 +-
 arch/ia64/kernel/perfmon.c                         |    2 +-
 arch/ia64/kernel/salinfo.c                         |   24 +-
 arch/ia64/kernel/setup.c                           |   11 +-
 arch/ia64/kernel/smp.c                             |    6 +-
 arch/ia64/kernel/smpboot.c                         |   42 +-
 arch/ia64/kernel/topology.c                        |    6 +-
 arch/ia64/mm/init.c                                |   25 -
 arch/ia64/pci/pci.c                                |    5 +-
 arch/m32r/include/asm/asm-offsets.h                |    1 +
 arch/m32r/include/asm/io.h                         |    1 +
 arch/m32r/include/asm/thread_info.h                |   15 +-
 arch/m32r/kernel/asm-offsets.c                     |   15 +-
 arch/m32r/kernel/entry.S                           |    1 +
 arch/m32r/kernel/signal.c                          |   12 +-
 arch/m32r/kernel/smpboot.c                         |    2 +-
 arch/m68k/coldfire/m527x.c                         |    3 +-
 arch/m68k/include/asm/m527xsim.h                   |    2 +
 arch/m68k/include/asm/m68360_pram.h                |    4 +-
 arch/m68k/include/asm/thread_info.h                |    2 -
 arch/m68k/kernel/signal.c                          |   14 +-
 arch/metag/include/asm/thread_info.h               |    2 -
 arch/metag/kernel/irq.c                            |    2 -
 arch/metag/kernel/process.c                        |   10 +-
 arch/microblaze/include/asm/seccomp.h              |    8 +-
 arch/microblaze/include/asm/thread_info.h          |    2 -
 arch/microblaze/kernel/cpu/mb.c                    |  149 +-
 arch/microblaze/kernel/signal.c                    |    9 +-
 arch/mips/Kbuild.platforms                         |    3 +-
 arch/mips/Kconfig                                  |  117 +-
 arch/mips/Makefile                                 |   23 +-
 arch/mips/ar7/platform.c                           |    5 +-
 arch/mips/ath79/common.h                           |    2 +-
 arch/mips/bcm3384/Platform                         |    7 -
 arch/mips/bcm3384/dma.c                            |   81 -
 arch/mips/bcm3384/irq.c                            |  193 -
 arch/mips/bcm3384/setup.c                          |   97 -
 arch/mips/bcm47xx/bcm47xx_private.h                |    4 +
 arch/mips/bcm47xx/board.c                          |   61 +-
 arch/mips/bcm47xx/buttons.c                        |   18 +
 arch/mips/bcm47xx/leds.c                           |   10 +
 arch/mips/bcm47xx/nvram.c                          |   77 +-
 arch/mips/bcm47xx/prom.c                           |    3 +-
 arch/mips/bcm47xx/serial.c                         |    8 +-
 arch/mips/bcm47xx/setup.c                          |   13 +-
 arch/mips/bcm47xx/sprom.c                          |  675 +--
 arch/mips/bcm47xx/time.c                           |    2 -
 arch/mips/bcm63xx/irq.c                            |    4 +-
 arch/mips/bcm63xx/prom.c                           |    4 -
 arch/mips/bcm63xx/setup.c                          |    4 +
 arch/mips/bmips/Kconfig                            |   62 +
 arch/mips/{bcm3384 =3D> bmips}/Makefile              |    0
 arch/mips/bmips/Platform                           |    7 +
 arch/mips/bmips/dma.c                              |  117 +
 arch/mips/bmips/irq.c                              |   38 +
 arch/mips/bmips/setup.c                            |  194 +
 arch/mips/boot/compressed/Makefile                 |    9 +-
 arch/mips/boot/compressed/decompress.c             |    5 +
 arch/mips/boot/dts/Makefile                        |   33 +-
 arch/mips/boot/dts/bcm3384.dtsi                    |  109 -
 arch/mips/boot/dts/brcm/Makefile                   |   19 +
 arch/mips/boot/dts/brcm/bcm3384_viper.dtsi         |  108 +
 arch/mips/boot/dts/brcm/bcm3384_zephyr.dtsi        |  126 +
 arch/mips/boot/dts/brcm/bcm6328.dtsi               |   86 +
 arch/mips/boot/dts/brcm/bcm6368.dtsi               |   93 +
 arch/mips/boot/dts/brcm/bcm7125.dtsi               |  139 +
 arch/mips/boot/dts/brcm/bcm7346.dtsi               |  224 +
 arch/mips/boot/dts/brcm/bcm7358.dtsi               |  161 +
 arch/mips/boot/dts/brcm/bcm7360.dtsi               |  161 +
 arch/mips/boot/dts/brcm/bcm7362.dtsi               |  167 +
 arch/mips/boot/dts/brcm/bcm7420.dtsi               |  184 +
 arch/mips/boot/dts/brcm/bcm7425.dtsi               |  225 +
 arch/mips/boot/dts/{ =3D> brcm}/bcm93384wvg.dts      |    9 +-
 arch/mips/boot/dts/brcm/bcm93384wvg_viper.dts      |   25 +
 arch/mips/boot/dts/brcm/bcm96368mvwg.dts           |   31 +
 arch/mips/boot/dts/brcm/bcm97125cbmb.dts           |   31 +
 arch/mips/boot/dts/brcm/bcm97346dbsmb.dts          |   58 +
 arch/mips/boot/dts/brcm/bcm97358svmb.dts           |   34 +
 arch/mips/boot/dts/brcm/bcm97360svmb.dts           |   34 +
 arch/mips/boot/dts/brcm/bcm97362svmb.dts           |   34 +
 arch/mips/boot/dts/brcm/bcm97420c.dts              |   45 +
 arch/mips/boot/dts/brcm/bcm97425svmb.dts           |   60 +
 arch/mips/boot/dts/brcm/bcm9ejtagprb.dts           |   22 +
 arch/mips/boot/dts/cavium-octeon/Makefile          |    9 +
 .../boot/dts/{ =3D> cavium-octeon}/octeon_3xxx.dts   |   12 +
 .../boot/dts/{ =3D> cavium-octeon}/octeon_68xx.dts   |    0
 arch/mips/boot/dts/lantiq/Makefile                 |    9 +
 arch/mips/boot/dts/{ =3D> lantiq}/danube.dtsi        |    0
 arch/mips/boot/dts/{ =3D> lantiq}/easy50712.dts      |    0
 arch/mips/boot/dts/mti/Makefile                    |    9 +
 arch/mips/boot/dts/{ =3D> mti}/sead3.dts             |    0
 arch/mips/boot/dts/netlogic/Makefile               |   13 +
 arch/mips/boot/dts/{ =3D> netlogic}/xlp_evp.dts      |    0
 arch/mips/boot/dts/{ =3D> netlogic}/xlp_fvp.dts      |    0
 arch/mips/boot/dts/{ =3D> netlogic}/xlp_gvp.dts      |    0
 arch/mips/boot/dts/netlogic/xlp_rvp.dts            |   77 +
 arch/mips/boot/dts/{ =3D> netlogic}/xlp_svp.dts      |    0
 arch/mips/boot/dts/ralink/Makefile                 |   12 +
 arch/mips/boot/dts/{ =3D> ralink}/mt7620a.dtsi       |    0
 arch/mips/boot/dts/{ =3D> ralink}/mt7620a_eval.dts   |    0
 arch/mips/boot/dts/{ =3D> ralink}/rt2880.dtsi        |    0
 arch/mips/boot/dts/{ =3D> ralink}/rt2880_eval.dts    |    0
 arch/mips/boot/dts/{ =3D> ralink}/rt3050.dtsi        |    0
 arch/mips/boot/dts/{ =3D> ralink}/rt3052_eval.dts    |    0
 arch/mips/boot/dts/{ =3D> ralink}/rt3883.dtsi        |    0
 arch/mips/boot/dts/{ =3D> ralink}/rt3883_eval.dts    |    0
 arch/mips/cavium-octeon/crypto/Makefile            |    5 +-
 arch/mips/cavium-octeon/crypto/octeon-crypto.c     |    4 +-
 arch/mips/cavium-octeon/crypto/octeon-crypto.h     |  163 +-
 arch/mips/cavium-octeon/crypto/octeon-md5.c        |    8 -
 arch/mips/cavium-octeon/crypto/octeon-sha1.c       |  241 +
 arch/mips/cavium-octeon/crypto/octeon-sha256.c     |  280 +
 arch/mips/cavium-octeon/crypto/octeon-sha512.c     |  277 +
 arch/mips/cavium-octeon/dma-octeon.c               |    2 +-
 arch/mips/cavium-octeon/executive/cvmx-l2c.c       |   45 +
 arch/mips/cavium-octeon/flash_setup.c              |   83 +-
 arch/mips/cavium-octeon/octeon-platform.c          |   19 +
 arch/mips/cavium-octeon/octeon_boot.h              |   23 +
 arch/mips/cavium-octeon/setup.c                    |   10 +-
 arch/mips/cavium-octeon/smp.c                      |    4 +-
 .../{bcm3384_defconfig =3D> bmips_be_defconfig}      |   11 +-
 arch/mips/configs/bmips_stb_defconfig              |   88 +
 arch/mips/configs/ip32_defconfig                   |    3 +-
 arch/mips/configs/lemote2f_defconfig               |    1 +
 arch/mips/configs/loongson3_defconfig              |    1 +
 arch/mips/configs/maltaup_xpa_defconfig            |  439 ++
 arch/mips/configs/pistachio_defconfig              |  336 ++
 arch/mips/dec/int-handler.S                        |    7 +-
 arch/mips/dec/setup.c                              |   16 +-
 arch/mips/include/asm/asm-eva.h                    |  137 +-
 arch/mips/include/asm/asmmacro-32.h                |   96 +-
 arch/mips/include/asm/bitops.h                     |    7 +-
 arch/mips/include/asm/bmips.h                      |   16 +
 arch/mips/include/asm/cacheflush.h                 |   38 +-
 arch/mips/include/asm/cdmm.h                       |   98 +
 arch/mips/include/asm/cevt-r4k.h                   |   19 -
 arch/mips/include/asm/checksum.h                   |    6 +-
 arch/mips/include/asm/cmpxchg.h                    |   11 +-
 arch/mips/include/asm/cpu-features.h               |   48 +-
 arch/mips/include/asm/cpu-info.h                   |    2 +
 arch/mips/include/asm/cpu-type.h                   |    1 +
 arch/mips/include/asm/cpu.h                        |    8 +-
 arch/mips/include/asm/dma-mapping.h                |    2 +-
 arch/mips/include/asm/elf.h                        |   12 +
 arch/mips/include/asm/fpu.h                        |    7 +-
 arch/mips/include/asm/fpu_emulator.h               |    6 +-
 arch/mips/include/asm/irq.h                        |    3 +
 arch/mips/include/asm/mach-ar7/war.h               |   24 -
 arch/mips/include/asm/mach-ath25/dma-coherence.h   |   14 +-
 arch/mips/include/asm/mach-ath25/war.h             |   25 -
 arch/mips/include/asm/mach-ath79/war.h             |   24 -
 arch/mips/include/asm/mach-au1x00/war.h            |   24 -
 arch/mips/include/asm/mach-bcm3384/war.h           |   24 -
 arch/mips/include/asm/mach-bcm47xx/bcm47xx.h       |    1 +
 arch/mips/include/asm/mach-bcm47xx/bcm47xx_board.h |    4 +
 arch/mips/include/asm/mach-bcm47xx/war.h           |   24 -
 arch/mips/include/asm/mach-bcm63xx/bcm63xx_regs.h  |   14 -
 arch/mips/include/asm/mach-bcm63xx/dma-coherence.h |   10 +
 arch/mips/include/asm/mach-bcm63xx/war.h           |   24 -
 .../{mach-bcm3384 =3D> mach-bmips}/dma-coherence.h   |   12 +-
 arch/mips/include/asm/mach-bmips/spaces.h          |   18 +
 .../asm/mach-cavium-octeon/cpu-feature-overrides.h |    1 -
 .../include/asm/mach-cavium-octeon/dma-coherence.h |    4 +
 .../include/asm/mach-cavium-octeon/mangle-port.h   |   74 +
 .../asm/mach-cobalt/cpu-feature-overrides.h        |    1 -
 arch/mips/include/asm/mach-cobalt/war.h            |   24 -
 .../include/asm/mach-dec/cpu-feature-overrides.h   |    1 -
 arch/mips/include/asm/mach-dec/war.h               |   24 -
 arch/mips/include/asm/mach-emma2rh/war.h           |   24 -
 arch/mips/include/asm/mach-generic/dma-coherence.h |    6 +
 .../asm/{mach-ralink =3D> mach-generic}/war.h        |    6 +-
 .../include/asm/mach-ip22/cpu-feature-overrides.h  |    1 -
 arch/mips/include/asm/mach-ip27/dma-coherence.h    |    4 +
 .../include/asm/mach-ip32/cpu-feature-overrides.h  |    1 -
 arch/mips/include/asm/mach-ip32/dma-coherence.h    |    4 +
 arch/mips/include/asm/mach-ip32/mc146818rtc.h      |   36 -
 arch/mips/include/asm/mach-jazz/dma-coherence.h    |    4 +
 arch/mips/include/asm/mach-jazz/war.h              |   24 -
 arch/mips/include/asm/mach-jz4740/war.h            |   24 -
 arch/mips/include/asm/mach-lantiq/war.h            |   23 -
 arch/mips/include/asm/mach-lasat/war.h             |   24 -
 .../asm/mach-loongson/cpu-feature-overrides.h      |    1 -
 .../mips/include/asm/mach-loongson/dma-coherence.h |    4 +
 arch/mips/include/asm/mach-loongson/gpio.h         |   15 +-
 arch/mips/include/asm/mach-loongson/loongson.h     |    4 +
 arch/mips/include/asm/mach-loongson/war.h          |   24 -
 arch/mips/include/asm/mach-loongson1/war.h         |   24 -
 arch/mips/include/asm/mach-netlogic/multi-node.h   |    9 -
 arch/mips/include/asm/mach-netlogic/topology.h     |   15 -
 arch/mips/include/asm/mach-netlogic/war.h          |   25 -
 arch/mips/include/asm/mach-paravirt/war.h          |   25 -
 arch/mips/include/asm/mach-pistachio/gpio.h        |   21 +
 arch/mips/include/asm/mach-pistachio/irq.h         |   18 +
 arch/mips/include/asm/mach-pnx833x/war.h           |   24 -
 .../include/asm/mach-rm/cpu-feature-overrides.h    |    1 -
 arch/mips/include/asm/mach-tx39xx/war.h            |   24 -
 arch/mips/include/asm/mach-vr41xx/war.h            |   24 -
 arch/mips/include/asm/mips-boards/sead3-addr.h     |   83 +
 arch/mips/include/asm/mips-r2-to-r6-emul.h         |    9 +-
 arch/mips/include/asm/mipsregs.h                   |  312 +-
 arch/mips/include/asm/netlogic/common.h            |   21 +-
 arch/mips/include/asm/netlogic/mips-extns.h        |    8 +-
 .../mips/include/asm/netlogic/xlp-hal/cpucontrol.h |    2 +
 arch/mips/include/asm/netlogic/xlp-hal/sys.h       |    3 +
 arch/mips/include/asm/netlogic/xlp-hal/xlp.h       |    3 +-
 arch/mips/include/asm/octeon/cvmx-address.h        |   67 +
 arch/mips/include/asm/octeon/cvmx-bootinfo.h       |   55 +
 arch/mips/include/asm/octeon/cvmx-bootmem.h        |   14 +
 arch/mips/include/asm/octeon/cvmx-fau.h            |   22 +
 arch/mips/include/asm/octeon/cvmx-fpa.h            |    7 +
 arch/mips/include/asm/octeon/cvmx-l2c.h            |    9 +
 arch/mips/include/asm/octeon/cvmx-packet.h         |    8 +
 arch/mips/include/asm/octeon/cvmx-pko.h            |   31 +
 arch/mips/include/asm/octeon/cvmx-pow.h            |  247 +
 arch/mips/include/asm/octeon/cvmx-wqe.h            |   71 +
 arch/mips/include/asm/octeon/cvmx.h                |    8 -
 arch/mips/include/asm/octeon/octeon.h              |    2 +
 arch/mips/include/asm/octeon/pci-octeon.h          |    3 -
 arch/mips/include/asm/page.h                       |    2 -
 arch/mips/include/asm/pci.h                        |    2 +
 arch/mips/include/asm/pci/bridge.h                 |    1 +
 arch/mips/include/asm/pgtable-32.h                 |   15 +-
 arch/mips/include/asm/pgtable-64.h                 |   10 +-
 arch/mips/include/asm/pgtable-bits.h               |   96 +-
 arch/mips/include/asm/pgtable.h                    |   83 +-
 arch/mips/include/asm/r4kcache.h                   |   89 +-
 arch/mips/include/asm/seccomp.h                    |    7 +-
 arch/mips/include/asm/sgi/sgi.h                    |   15 +-
 arch/mips/include/asm/smp.h                        |    2 +-
 arch/mips/include/asm/spinlock.h                   |    2 +-
 arch/mips/include/asm/thread_info.h                |    6 +-
 arch/mips/jz4740/Platform                          |    1 +
 arch/mips/jz4740/time.c                            |    8 +
 arch/mips/kernel/asm-offsets.c                     |    1 -
 arch/mips/kernel/branch.c                          |    6 +-
 arch/mips/kernel/cevt-r4k.c                        |   33 +-
 arch/mips/kernel/cevt-txx9.c                       |    9 +
 arch/mips/kernel/cpu-probe.c                       |  200 +-
 arch/mips/kernel/crash.c                           |    8 +-
 arch/mips/kernel/csrc-bcm1480.c                    |   12 +-
 arch/mips/kernel/csrc-ioasic.c                     |   13 +-
 arch/mips/kernel/csrc-r4k.c                        |    8 +
 arch/mips/kernel/csrc-sb1250.c                     |   23 +-
 arch/mips/kernel/elf.c                             |   14 +-
 arch/mips/kernel/entry.S                           |    3 +-
 arch/mips/kernel/idle.c                            |   13 +-
 arch/mips/kernel/mips-mt-fpaff.c                   |    4 +-
 arch/mips/kernel/mips-r2-to-r6-emul.c              |   15 +-
 arch/mips/kernel/perf_event_mipsxx.c               |   83 +-
 arch/mips/kernel/proc.c                            |    1 +
 arch/mips/kernel/process.c                         |   12 +-
 arch/mips/kernel/prom.c                            |    5 +-
 arch/mips/kernel/ptrace.c                          |   10 +-
 arch/mips/kernel/r2300_switch.S                    |    7 +-
 arch/mips/kernel/r4k_switch.S                      |    7 +-
 arch/mips/kernel/reset.c                           |   25 +
 arch/mips/kernel/setup.c                           |    2 +
 arch/mips/kernel/smp-bmips.c                       |    2 +-
 arch/mips/kernel/smp-cmp.c                         |    4 +-
 arch/mips/kernel/smp-cps.c                         |   10 +-
 arch/mips/kernel/smp-mt.c                          |    4 +-
 arch/mips/kernel/smp.c                             |   32 +-
 arch/mips/kernel/traps.c                           |  282 +-
 arch/mips/kernel/unaligned.c                       |  346 +-
 arch/mips/lantiq/prom.c                            |    2 +-
 arch/mips/lantiq/xway/vmmc.c                       |    1 -
 arch/mips/lasat/sysctl.c                           |   15 -
 arch/mips/lib/csum_partial.S                       |   38 +-
 arch/mips/loongson/common/Makefile                 |    1 -
 arch/mips/loongson/common/env.c                    |    9 +
 arch/mips/loongson/common/pci.c                    |    6 +
 arch/mips/loongson/loongson-3/cop2-ex.c            |    2 +-
 arch/mips/loongson/loongson-3/irq.c                |    1 +
 arch/mips/loongson/loongson-3/numa.c               |    4 +-
 arch/mips/loongson/loongson-3/smp.c                |    2 +-
 arch/mips/math-emu/Makefile                        |   15 +-
 arch/mips/math-emu/cp1emu.c                        |  288 +-
 arch/mips/math-emu/dp_add.c                        |   14 +-
 arch/mips/math-emu/dp_cmp.c                        |   13 +-
 arch/mips/math-emu/dp_div.c                        |    9 +-
 arch/mips/math-emu/dp_fsp.c                        |   16 +-
 arch/mips/math-emu/dp_mul.c                        |    9 +-
 arch/mips/math-emu/dp_simple.c                     |   55 +-
 arch/mips/math-emu/dp_sqrt.c                       |   13 +-
 arch/mips/math-emu/dp_sub.c                        |   14 +-
 arch/mips/math-emu/dsemul.c                        |    6 +-
 arch/mips/math-emu/ieee754.h                       |  111 +-
 arch/mips/math-emu/ieee754dp.c                     |   25 +-
 arch/mips/math-emu/ieee754dp.h                     |    1 -
 arch/mips/math-emu/ieee754int.h                    |    5 +
 arch/mips/math-emu/ieee754sp.c                     |   25 +-
 arch/mips/math-emu/ieee754sp.h                     |    1 -
 arch/mips/math-emu/me-debugfs.c                    |    1 +
 arch/mips/math-emu/sp_add.c                        |   14 +-
 arch/mips/math-emu/sp_cmp.c                        |   13 +-
 arch/mips/math-emu/sp_div.c                        |    9 +-
 arch/mips/math-emu/sp_fdp.c                        |   22 +-
 arch/mips/math-emu/sp_mul.c                        |    9 +-
 arch/mips/math-emu/sp_simple.c                     |   55 +-
 arch/mips/math-emu/sp_sqrt.c                       |   13 +-
 arch/mips/math-emu/sp_sub.c                        |   14 +-
 arch/mips/mm/c-r4k.c                               |   33 +-
 arch/mips/mm/cache.c                               |   39 +-
 arch/mips/mm/dma-default.c                         |    4 +-
 arch/mips/mm/init.c                                |    7 +-
 arch/mips/mm/page.c                                |    1 +
 arch/mips/mm/tlb-r4k.c                             |   15 +-
 arch/mips/mm/tlbex.c                               |  116 +-
 arch/mips/mti-malta/malta-init.c                   |    4 +-
 arch/mips/mti-malta/malta-memory.c                 |   13 +
 arch/mips/mti-malta/malta-time.c                   |   20 +-
 arch/mips/mti-sead3/Makefile                       |    7 +-
 arch/mips/mti-sead3/leds-sead3.c                   |   41 +-
 arch/mips/mti-sead3/sead3-ehci.c                   |   53 -
 arch/mips/mti-sead3/sead3-i2c-dev.c                |   33 -
 arch/mips/mti-sead3/sead3-i2c-drv.c                |  404 --
 arch/mips/mti-sead3/sead3-i2c.c                    |   31 -
 arch/mips/mti-sead3/sead3-init.c                   |    2 +-
 arch/mips/mti-sead3/sead3-leds.c                   |   79 -
 arch/mips/mti-sead3/sead3-mtd.c                    |   53 -
 arch/mips/mti-sead3/sead3-net.c                    |   57 -
 arch/mips/mti-sead3/sead3-platform.c               |  184 +-
 arch/mips/netlogic/Kconfig                         |    9 +
 arch/mips/netlogic/common/irq.c                    |   10 +-
 arch/mips/netlogic/common/reset.S                  |   22 +-
 arch/mips/netlogic/common/smp.c                    |   25 +-
 arch/mips/netlogic/common/time.c                   |    1 -
 arch/mips/netlogic/xlp/ahci-init-xlp2.c            |   13 +
 arch/mips/netlogic/xlp/ahci-init.c                 |    2 +-
 arch/mips/netlogic/xlp/dt.c                        |   10 +-
 arch/mips/netlogic/xlp/nlm_hal.c                   |   57 +-
 arch/mips/netlogic/xlp/setup.c                     |    7 +-
 arch/mips/netlogic/xlp/usb-init-xlp2.c             |   10 +-
 arch/mips/netlogic/xlp/wakeup.c                    |   10 +-
 arch/mips/oprofile/common.c                        |    1 +
 arch/mips/oprofile/op_model_mipsxx.c               |   15 +-
 arch/mips/paravirt/paravirt-smp.c                  |    2 +-
 arch/mips/pci/Makefile                             |    2 +-
 arch/mips/pci/msi-xlp.c                            |   19 +-
 arch/mips/pci/pci-ar2315.c                         |    1 -
 arch/mips/pci/pci-octeon.c                         |    8 +-
 arch/mips/pci/pci-rt2880.c                         |    1 -
 arch/mips/pci/pci.c                                |    5 +-
 arch/mips/pci/pcie-octeon.c                        |    8 -
 arch/mips/pistachio/Makefile                       |    1 +
 arch/mips/pistachio/Platform                       |    8 +
 arch/mips/pistachio/init.c                         |  131 +
 arch/mips/pistachio/irq.c                          |   28 +
 arch/mips/pistachio/time.c                         |   52 +
 arch/mips/power/Makefile                           |    2 +-
 arch/mips/power/hibernate.c                        |   10 +
 arch/mips/power/{hibernate.S =3D> hibernate_asm.S}   |    5 +-
 arch/mips/ralink/Kconfig                           |    5 +
 arch/mips/sgi-ip27/ip27-init.c                     |    2 +-
 arch/mips/sgi-ip27/ip27-klnuma.c                   |   10 +-
 arch/mips/sgi-ip27/ip27-memory.c                   |    2 +-
 arch/mips/sgi-ip27/ip27-timer.c                    |    8 +
 arch/mips/sgi-ip32/ip32-platform.c                 |   51 +-
 arch/mips/sgi-ip32/ip32-reset.c                    |  131 +-
 arch/mn10300/include/asm/io.h                      |    5 +
 arch/mn10300/include/asm/thread_info.h             |    2 -
 arch/mn10300/kernel/asm-offsets.c                  |    2 -
 arch/mn10300/kernel/signal.c                       |   20 +-
 arch/nios2/include/asm/Kbuild                      |    1 -
 arch/nios2/include/asm/shmparam.h                  |   21 +
 arch/nios2/include/asm/thread_info.h               |    2 -
 arch/nios2/include/uapi/asm/ptrace.h               |    2 +
 arch/nios2/kernel/cpuinfo.c                        |   77 +-
 arch/nios2/kernel/entry.S                          |   71 +-
 arch/nios2/kernel/traps.c                          |   34 +-
 arch/nios2/mm/cacheflush.c                         |   55 +-
 arch/openrisc/include/asm/thread_info.h            |    2 -
 arch/openrisc/kernel/setup.c                       |   50 +-
 arch/openrisc/kernel/signal.c                      |    2 -
 arch/parisc/include/asm/Kbuild                     |    2 +
 arch/parisc/include/asm/pgalloc.h                  |    6 +-
 arch/parisc/include/asm/scatterlist.h              |   10 -
 arch/parisc/include/asm/seccomp.h                  |   16 -
 arch/parisc/include/asm/thread_info.h              |    2 -
 arch/parisc/kernel/asm-offsets.c                   |    1 -
 arch/parisc/kernel/irq.c                           |    4 +-
 arch/parisc/kernel/pci-dma.c                       |    8 +-
 arch/powerpc/Kconfig                               |    4 +-
 arch/powerpc/Kconfig.debug                         |    9 +-
 arch/powerpc/Makefile                              |    4 +-
 arch/powerpc/boot/Makefile                         |    4 +-
 arch/powerpc/boot/crt0.S                           |   26 +-
 arch/powerpc/boot/dts/b4860emu.dts                 |  223 -
 arch/powerpc/boot/dts/b4qds.dtsi                   |   17 +-
 arch/powerpc/boot/dts/fsl/b4860si-post.dtsi        |   60 +-
 arch/powerpc/boot/dts/fsl/b4si-post.dtsi           |   89 +-
 arch/powerpc/boot/dts/fsl/p1023si-post.dtsi        |   37 +-
 arch/powerpc/boot/dts/fsl/p2041si-post.dtsi        |   11 +-
 arch/powerpc/boot/dts/fsl/p3041si-post.dtsi        |   11 +-
 arch/powerpc/boot/dts/fsl/p4080si-post.dtsi        |   11 +-
 arch/powerpc/boot/dts/fsl/p5020si-post.dtsi        |   11 +-
 arch/powerpc/boot/dts/fsl/p5040si-post.dtsi        |   11 +-
 arch/powerpc/boot/dts/fsl/t1040si-post.dtsi        |   65 +-
 arch/powerpc/boot/dts/fsl/t2081si-post.dtsi        |  105 +-
 arch/powerpc/boot/dts/fsl/t4240si-post.dtsi        |  265 +-
 arch/powerpc/boot/dts/kmcoge4.dts                  |   15 +
 arch/powerpc/boot/dts/oca4080.dts                  |   15 +
 arch/powerpc/boot/dts/p1023rdb.dts                 |   18 +-
 arch/powerpc/boot/dts/p2041rdb.dts                 |   17 +-
 arch/powerpc/boot/dts/p3041ds.dts                  |   17 +-
 arch/powerpc/boot/dts/p4080ds.dts                  |   17 +-
 arch/powerpc/boot/dts/p5020ds.dts                  |   17 +-
 arch/powerpc/boot/dts/p5040ds.dts                  |   17 +-
 arch/powerpc/boot/dts/t104xqds.dtsi                |   17 +-
 arch/powerpc/boot/dts/t104xrdb.dtsi                |   14 +
 arch/powerpc/boot/dts/t208xqds.dtsi                |   19 +-
 arch/powerpc/boot/dts/t208xrdb.dtsi                |   15 +
 arch/powerpc/boot/dts/t4240qds.dts                 |   17 +-
 arch/powerpc/boot/dts/t4240rdb.dts                 |   15 +
 arch/powerpc/boot/libfdt-wrapper.c                 |    6 +-
 arch/powerpc/boot/libfdt_env.h                     |   14 +-
 arch/powerpc/boot/of.h                             |    8 +
 arch/powerpc/boot/planetcore.c                     |   33 -
 arch/powerpc/boot/planetcore.h                     |    3 -
 arch/powerpc/boot/wrapper                          |    2 +-
 arch/powerpc/configs/cell_defconfig                |    3 -
 arch/powerpc/configs/celleb_defconfig              |  152 -
 arch/powerpc/configs/corenet32_smp_defconfig       |    7 +-
 arch/powerpc/configs/corenet64_smp_defconfig       |   15 +-
 arch/powerpc/configs/mpc85xx_defconfig             |    3 +-
 arch/powerpc/configs/mpc85xx_smp_defconfig         |    2 +-
 arch/powerpc/configs/ppc64_defconfig               |    3 -
 arch/powerpc/crypto/Makefile                       |    8 +
 arch/powerpc/crypto/aes-spe-core.S                 |  351 ++
 arch/powerpc/crypto/aes-spe-glue.c                 |  512 ++
 arch/powerpc/crypto/aes-spe-keys.S                 |  283 +
 arch/powerpc/crypto/aes-spe-modes.S                |  630 +++
 arch/powerpc/crypto/aes-spe-regs.h                 |   42 +
 arch/powerpc/crypto/aes-tab-4k.S                   |  331 ++
 arch/powerpc/crypto/md5-asm.S                      |  243 +
 arch/powerpc/crypto/md5-glue.c                     |  165 +
 arch/powerpc/crypto/sha1-spe-asm.S                 |  299 ++
 arch/powerpc/crypto/sha1-spe-glue.c                |  210 +
 arch/powerpc/crypto/sha256-spe-asm.S               |  323 ++
 arch/powerpc/crypto/sha256-spe-glue.c              |  275 +
 arch/powerpc/include/asm/Kbuild                    |    4 +-
 arch/powerpc/include/asm/archrandom.h              |   11 +-
 arch/powerpc/include/asm/cache.h                   |    3 -
 arch/powerpc/include/asm/cputable.h                |    8 +-
 arch/powerpc/include/asm/cputhreads.h              |    2 +-
 arch/powerpc/include/asm/dbdma.h                   |   12 +-
 arch/powerpc/include/asm/dcr-native.h              |    2 +-
 arch/powerpc/include/asm/device.h                  |    6 +
 arch/powerpc/include/asm/div64.h                   |    1 -
 arch/powerpc/include/asm/dma-mapping.h             |    4 +-
 arch/powerpc/include/asm/eeh.h                     |   29 +-
 arch/powerpc/include/asm/firmware.h                |   10 +-
 arch/powerpc/include/asm/iommu.h                   |    6 +-
 arch/powerpc/include/asm/irq_regs.h                |    2 -
 arch/powerpc/include/asm/kvm_book3s.h              |    3 +
 arch/powerpc/include/asm/kvm_book3s_64.h           |   49 +-
 arch/powerpc/include/asm/kvm_host.h                |   49 +-
 arch/powerpc/include/asm/kvm_ppc.h                 |    2 +
 arch/powerpc/include/asm/local64.h                 |    1 -
 arch/powerpc/include/asm/machdep.h                 |   19 +-
 arch/powerpc/include/asm/mmu-hash64.h              |    1 +
 arch/powerpc/include/asm/mpc85xx.h                 |    1 +
 arch/powerpc/include/asm/mpic.h                    |   17 -
 arch/powerpc/include/asm/nmi.h                     |    4 +
 arch/powerpc/include/asm/nvram.h                   |   50 +-
 arch/powerpc/include/asm/opal-api.h                |  735 +++
 arch/powerpc/include/asm/opal.h                    |  770 +--
 arch/powerpc/include/asm/paca.h                    |    4 +-
 arch/powerpc/include/asm/pci-bridge.h              |   60 +-
 arch/powerpc/include/asm/pci.h                     |    2 +-
 arch/powerpc/include/asm/pgtable.h                 |   28 +-
 arch/powerpc/include/asm/ppc-pci.h                 |    8 +-
 arch/powerpc/include/asm/ppc_asm.h                 |  192 +-
 arch/powerpc/include/asm/rtas.h                    |   33 +-
 arch/powerpc/include/asm/seccomp.h                 |   10 +
 arch/powerpc/include/asm/setup.h                   |    1 -
 arch/powerpc/include/asm/smp.h                     |    5 +-
 arch/powerpc/include/asm/swab.h                    |   26 -
 arch/powerpc/include/asm/systbl.h                  |    1 +
 arch/powerpc/include/asm/thread_info.h             |    2 -
 arch/powerpc/include/asm/time.h                    |    3 +
 arch/powerpc/include/asm/ucc_slow.h                |   13 -
 arch/powerpc/include/asm/unistd.h                  |    2 +-
 arch/powerpc/include/asm/vga.h                     |    4 +-
 arch/powerpc/include/asm/xics.h                    |    2 +-
 arch/powerpc/include/uapi/asm/Kbuild               |    1 -
 arch/powerpc/include/uapi/asm/ptrace.h             |    2 +-
 arch/powerpc/include/uapi/asm/seccomp.h            |   16 -
 arch/powerpc/include/uapi/asm/tm.h                 |    2 +-
 arch/powerpc/include/uapi/asm/unistd.h             |    1 +
 arch/powerpc/kernel/Makefile                       |    4 +-
 arch/powerpc/kernel/asm-offsets.c                  |   20 +-
 arch/powerpc/kernel/cacheinfo.c                    |   44 +-
 arch/powerpc/kernel/cpu_setup_power.S              |   10 +-
 arch/powerpc/kernel/cputable.c                     |    4 +-
 arch/powerpc/kernel/dma-swiotlb.c                  |   11 +-
 arch/powerpc/kernel/eeh.c                          |  182 +-
 arch/powerpc/kernel/eeh_cache.c                    |   25 +-
 arch/powerpc/kernel/eeh_dev.c                      |   14 +-
 arch/powerpc/kernel/eeh_driver.c                   |   22 -
 arch/powerpc/kernel/eeh_pe.c                       |  129 +-
 arch/powerpc/kernel/entry_64.S                     |   24 +
 arch/powerpc/kernel/idle_power7.S                  |    1 +
 arch/powerpc/kernel/io-workarounds.c               |   10 +-
 arch/powerpc/kernel/mce_power.c                    |   53 +-
 arch/powerpc/kernel/nvram_64.c                     |  677 +++
 arch/powerpc/kernel/of_platform.c                  |    2 +-
 arch/powerpc/kernel/pci-common.c                   |   57 +-
 arch/powerpc/kernel/pci-hotplug.c                  |    9 +-
 arch/powerpc/kernel/pci_dn.c                       |  309 +-
 arch/powerpc/kernel/pci_of_scan.c                  |    9 +-
 arch/powerpc/kernel/process.c                      |    9 +-
 arch/powerpc/kernel/prom_init.c                    |    4 +-
 arch/powerpc/kernel/rtas.c                         |   30 +-
 arch/powerpc/kernel/rtas_pci.c                     |   49 +-
 arch/powerpc/kernel/setup_64.c                     |   20 +
 arch/powerpc/kernel/syscalls.c                     |   17 +
 arch/powerpc/kernel/systbl.S                       |    2 +
 arch/powerpc/kernel/systbl_chk.c                   |    2 +
 arch/powerpc/kernel/time.c                         |    6 +
 arch/powerpc/kernel/tm.S                           |    8 +-
 arch/powerpc/kernel/udbg.c                         |    2 -
 arch/powerpc/kernel/vector.S                       |   24 +-
 arch/powerpc/kvm/Kconfig                           |   16 +-
 arch/powerpc/kvm/book3s.c                          |   76 +
 arch/powerpc/kvm/book3s_64_mmu_hv.c                |  203 +-
 arch/powerpc/kvm/book3s_hv.c                       |  435 +-
 arch/powerpc/kvm/book3s_hv_builtin.c               |  100 +-
 arch/powerpc/kvm/book3s_hv_ras.c                   |    4 +-
 arch/powerpc/kvm/book3s_hv_rm_mmu.c                |  111 +-
 arch/powerpc/kvm/book3s_hv_rm_xics.c               |  238 +-
 arch/powerpc/kvm/book3s_hv_rmhandlers.S            |  559 +-
 arch/powerpc/kvm/book3s_pr_papr.c                  |   28 +
 arch/powerpc/kvm/book3s_xics.c                     |  105 +-
 arch/powerpc/kvm/book3s_xics.h                     |   13 +-
 arch/powerpc/kvm/e500_mmu_host.c                   |   32 +-
 arch/powerpc/kvm/powerpc.c                         |   41 +-
 arch/powerpc/lib/alloc.c                           |    2 +-
 arch/powerpc/lib/copy_32.S                         |  127 -
 arch/powerpc/lib/copypage_power7.S                 |   32 +-
 arch/powerpc/lib/copyuser_power7.S                 |  226 +-
 arch/powerpc/lib/crtsavres.S                       |   96 +-
 arch/powerpc/lib/ldstfp.S                          |   32 +-
 arch/powerpc/lib/locks.c                           |    1 +
 arch/powerpc/lib/memcpy_power7.S                   |  226 +-
 arch/powerpc/lib/ppc_ksyms.c                       |    4 -
 arch/powerpc/lib/rheap.c                           |    2 +-
 arch/powerpc/mm/Makefile                           |    1 +
 arch/powerpc/mm/dma-noncoherent.c                  |    2 +-
 arch/powerpc/mm/fsl_booke_mmu.c                    |    2 +-
 arch/powerpc/mm/hash_utils_64.c                    |    3 +-
 arch/powerpc/mm/hugepage-hash64.c                  |    2 +-
 arch/powerpc/mm/hugetlbpage.c                      |   36 +-
 arch/powerpc/mm/init_64.c                          |    1 +
 arch/powerpc/mm/mem.c                              |    3 -
 arch/powerpc/mm/mmu_decl.h                         |    2 +-
 arch/powerpc/mm/numa.c                             |   62 +-
 arch/powerpc/mm/pgtable_32.c                       |   18 +-
 arch/powerpc/mm/pgtable_64.c                       |    6 +-
 arch/powerpc/mm/ppc_mmu_32.c                       |    5 +-
 arch/powerpc/mm/tlb_hash64.c                       |    2 +-
 arch/powerpc/mm/vphn.c                             |   70 +
 arch/powerpc/mm/vphn.h                             |   16 +
 arch/powerpc/oprofile/cell/spu_task_sync.c         |   13 +-
 arch/powerpc/perf/callchain.c                      |   26 +-
 arch/powerpc/perf/core-book3s.c                    |    4 +-
 arch/powerpc/perf/hv-24x7.c                        |  251 +-
 arch/powerpc/perf/hv-24x7.h                        |    8 +-
 arch/powerpc/platforms/85xx/common.c               |    1 +
 arch/powerpc/platforms/85xx/corenet_generic.c      |   12 +
 arch/powerpc/platforms/85xx/smp.c                  |    4 +-
 arch/powerpc/platforms/Kconfig                     |    5 -
 arch/powerpc/platforms/Kconfig.cputype             |    3 +-
 arch/powerpc/platforms/cell/Kconfig                |   11 -
 arch/powerpc/platforms/cell/Makefile               |   15 -
 arch/powerpc/platforms/cell/beat.c                 |  264 -
 arch/powerpc/platforms/cell/beat.h                 |   39 -
 arch/powerpc/platforms/cell/beat_htab.c            |  445 --
 arch/powerpc/platforms/cell/beat_hvCall.S          |  285 -
 arch/powerpc/platforms/cell/beat_interrupt.c       |  253 -
 arch/powerpc/platforms/cell/beat_iommu.c           |  115 -
 arch/powerpc/platforms/cell/beat_spu_priv1.c       |  205 -
 arch/powerpc/platforms/cell/beat_syscall.h         |  164 -
 arch/powerpc/platforms/cell/beat_udbg.c            |   98 -
 arch/powerpc/platforms/cell/beat_wrapper.h         |  290 --
 arch/powerpc/platforms/cell/cell.h                 |   24 +
 arch/powerpc/platforms/cell/celleb_pci.c           |  500 --
 arch/powerpc/platforms/cell/celleb_pci.h           |   46 -
 arch/powerpc/platforms/cell/celleb_scc.h           |  232 -
 arch/powerpc/platforms/cell/celleb_scc_epci.c      |  428 --
 arch/powerpc/platforms/cell/celleb_scc_pciex.c     |  538 --
 arch/powerpc/platforms/cell/celleb_scc_sio.c       |   99 -
 arch/powerpc/platforms/cell/celleb_scc_uhc.c       |   95 -
 arch/powerpc/platforms/cell/celleb_setup.c         |  243 -
 arch/powerpc/platforms/cell/interrupt.c            |    2 +-
 arch/powerpc/platforms/cell/iommu.c                |   11 +-
 arch/powerpc/platforms/cell/setup.c                |    5 +
 arch/powerpc/platforms/cell/smp.c                  |    9 +-
 arch/powerpc/platforms/cell/spu_callbacks.c        |    1 +
 arch/powerpc/platforms/cell/spufs/inode.c          |   22 +-
 arch/powerpc/platforms/chrp/setup.c                |    2 +-
 arch/powerpc/platforms/maple/maple.h               |    2 +
 arch/powerpc/platforms/maple/pci.c                 |    4 +
 arch/powerpc/platforms/maple/setup.c               |    2 +-
 arch/powerpc/platforms/pasemi/iommu.c              |    6 +-
 arch/powerpc/platforms/pasemi/pasemi.h             |    1 +
 arch/powerpc/platforms/pasemi/pci.c                |    5 +
 arch/powerpc/platforms/powermac/bootx_init.c       |    2 +-
 arch/powerpc/platforms/powermac/pci.c              |   38 +-
 arch/powerpc/platforms/powermac/pic.c              |    3 +
 arch/powerpc/platforms/powermac/pmac.h             |    3 +-
 arch/powerpc/platforms/powermac/setup.c            |   22 +-
 arch/powerpc/platforms/powermac/smp.c              |   18 +-
 arch/powerpc/platforms/powernv/Kconfig             |    7 -
 arch/powerpc/platforms/powernv/Makefile            |    2 +-
 arch/powerpc/platforms/powernv/eeh-ioda.c          | 1149 -----
 arch/powerpc/platforms/powernv/eeh-powernv.c       | 1300 ++++-
 arch/powerpc/platforms/powernv/opal-dump.c         |    3 +-
 arch/powerpc/platforms/powernv/opal-elog.c         |    3 +-
 arch/powerpc/platforms/powernv/opal-flash.c        |    8 +-
 arch/powerpc/platforms/powernv/opal-nvram.c        |   10 +
 arch/powerpc/platforms/powernv/opal-power.c        |    5 +-
 arch/powerpc/platforms/powernv/opal-sensor.c       |   30 +-
 arch/powerpc/platforms/powernv/opal-wrappers.S     |    5 +-
 arch/powerpc/platforms/powernv/opal.c              |   92 +-
 arch/powerpc/platforms/powernv/pci-ioda.c          |  797 ++-
 arch/powerpc/platforms/powernv/pci-p5ioc2.c        |    1 +
 arch/powerpc/platforms/powernv/pci.c               |  190 +-
 arch/powerpc/platforms/powernv/pci.h               |   38 +-
 arch/powerpc/platforms/powernv/powernv.h           |    2 +
 arch/powerpc/platforms/powernv/rng.c               |   29 +
 arch/powerpc/platforms/powernv/setup.c             |   54 +-
 arch/powerpc/platforms/powernv/smp.c               |   13 -
 arch/powerpc/platforms/ps3/smp.c                   |    4 +-
 arch/powerpc/platforms/pseries/Kconfig             |    1 -
 arch/powerpc/platforms/pseries/dlpar.c             |  118 +-
 arch/powerpc/platforms/pseries/eeh_pseries.c       |   98 +-
 arch/powerpc/platforms/pseries/hotplug-memory.c    |  489 ++
 arch/powerpc/platforms/pseries/iommu.c             |    9 +-
 arch/powerpc/platforms/pseries/mobility.c          |   26 +-
 arch/powerpc/platforms/pseries/msi.c               |    6 +-
 arch/powerpc/platforms/pseries/nvram.c             |  674 +--
 arch/powerpc/platforms/pseries/pci_dlpar.c         |    5 +-
 arch/powerpc/platforms/pseries/pseries.h           |   14 +
 arch/powerpc/platforms/pseries/setup.c             |   48 +-
 arch/powerpc/platforms/pseries/smp.c               |    6 +-
 arch/powerpc/relocs_check.pl                       |   66 -
 arch/powerpc/relocs_check.sh                       |   59 +
 arch/powerpc/sysdev/dart_iommu.c                   |   10 +-
 arch/powerpc/sysdev/dcr.c                          |    2 +-
 arch/powerpc/sysdev/fsl_msi.c                      |   29 +-
 arch/powerpc/sysdev/fsl_msi.h                      |    2 +
 arch/powerpc/sysdev/fsl_pci.c                      |   15 +
 arch/powerpc/sysdev/mpic.c                         |   30 +-
 arch/powerpc/sysdev/qe_lib/qe_io.c                 |   25 -
 arch/powerpc/sysdev/qe_lib/ucc_slow.c              |    5 -
 arch/powerpc/sysdev/xics/xics-common.c             |    4 +-
 arch/s390/Kconfig                                  |    3 +-
 arch/s390/hypfs/inode.c                            |   20 +-
 arch/s390/include/asm/dma-mapping.h                |    2 +-
 arch/s390/include/asm/pci.h                        |   10 +-
 arch/s390/include/asm/thread_info.h                |    2 -
 arch/s390/kernel/asm-offsets.c                     |    1 -
 arch/s390/kernel/compat_signal.c                   |   14 +-
 arch/s390/kernel/signal.c                          |   14 +-
 arch/s390/kvm/kvm-s390.c                           |    2 +-
 arch/s390/net/bpf_jit.S                            |  197 +-
 arch/s390/net/bpf_jit.h                            |   58 +
 arch/s390/net/bpf_jit_comp.c                       | 1780 ++++---
 arch/s390/pci/pci.c                                |    6 +
 arch/s390/pci/pci_debug.c                          |   39 +-
 arch/s390/pci/pci_dma.c                            |    8 +-
 arch/score/include/asm/thread_info.h               |    2 -
 arch/score/kernel/asm-offsets.c                    |    1 -
 arch/sh/boards/board-sh7757lcr.c                   |    9 +-
 arch/sh/boards/mach-ap325rxa/setup.c               |    9 +-
 arch/sh/boards/mach-ecovec24/setup.c               |   20 +-
 arch/sh/boards/mach-kfr2r09/setup.c                |   10 +-
 arch/sh/boards/mach-migor/setup.c                  |    9 +-
 arch/sh/boards/mach-se/7724/setup.c                |   17 +-
 arch/sh/include/asm/mmu_context.h                  |    2 +-
 arch/sh/include/asm/thread_info.h                  |    2 -
 arch/sh/kernel/asm-offsets.c                       |    1 -
 arch/sh/kernel/irq.c                               |    2 -
 arch/sh/kernel/signal_32.c                         |   18 +-
 arch/sh/kernel/signal_64.c                         |   21 +-
 arch/sh/kernel/smp.c                               |    6 +-
 arch/sparc/include/asm/iommu_64.h                  |    7 +-
 arch/sparc/include/asm/seccomp.h                   |   11 +-
 arch/sparc/include/asm/thread_info_32.h            |   15 +-
 arch/sparc/include/asm/thread_info_64.h            |   26 +-
 arch/sparc/kernel/iommu.c                          |  172 +-
 arch/sparc/kernel/iommu_common.h                   |    8 -
 arch/sparc/kernel/ldc.c                            |  155 +-
 arch/sparc/kernel/pci_sun4v.c                      |  183 +-
 arch/sparc/kernel/perf_event.c                     |   35 +-
 arch/sparc/kernel/time_32.c                        |    4 +-
 arch/sparc/kernel/traps_32.c                       |    1 -
 arch/sparc/kernel/traps_64.c                       |    2 -
 arch/tile/Kconfig                                  |    1 +
 arch/tile/include/asm/Kbuild                       |    1 -
 arch/tile/include/asm/ftrace.h                     |    2 +
 arch/tile/include/asm/irq_work.h                   |   14 +
 arch/tile/include/asm/smp.h                        |    1 +
 arch/tile/include/asm/thread_info.h                |   11 +-
 arch/tile/include/hv/hypervisor.h                  |    6 +-
 arch/tile/kernel/compat_signal.c                   |   20 +-
 arch/tile/kernel/ftrace.c                          |    6 +-
 arch/tile/kernel/mcount_64.S                       |    7 +-
 arch/tile/kernel/process.c                         |   12 +-
 arch/tile/kernel/ptrace.c                          |   22 +-
 arch/tile/kernel/setup.c                           |   25 +-
 arch/tile/kernel/signal.c                          |    9 +-
 arch/tile/kernel/single_step.c                     |    3 +
 arch/tile/kernel/smp.c                             |   32 +-
 arch/tile/kernel/stack.c                           |   15 +-
 arch/tile/kernel/traps.c                           |   16 +-
 arch/tile/kernel/unaligned.c                       |   22 +-
 arch/tile/mm/elf.c                                 |   47 +-
 arch/tile/mm/fault.c                               |   10 +-
 arch/tile/mm/init.c                                |    7 +-
 arch/um/Kconfig.um                                 |   42 -
 arch/um/Makefile                                   |    6 +-
 arch/um/Makefile-ia64                              |    1 -
 arch/um/Makefile-ppc                               |    9 -
 arch/um/include/asm/fixmap.h                       |    4 -
 arch/um/include/asm/pgtable.h                      |    6 +-
 arch/um/include/asm/processor-generic.h            |    8 -
 arch/um/include/asm/smp.h                          |   26 -
 arch/um/include/asm/thread_info.h                  |    2 -
 arch/um/include/shared/as-layout.h                 |    1 +
 arch/um/include/shared/os.h                        |    2 -
 arch/um/include/shared/skas/proc_mm.h              |   44 -
 arch/um/include/shared/skas/skas.h                 |    3 -
 arch/um/include/shared/skas_ptrace.h               |   14 -
 arch/um/kernel/Makefile                            |    4 +-
 arch/um/kernel/irq.c                               |    3 -
 arch/um/kernel/kmsg_dump.c                         |   43 +
 arch/um/kernel/mem.c                               |   66 -
 arch/um/kernel/physmem.c                           |   41 +-
 arch/um/kernel/process.c                           |   11 -
 arch/um/kernel/ptrace.c                            |   32 -
 arch/um/kernel/reboot.c                            |   35 +-
 arch/um/kernel/skas/mmu.c                          |   68 +-
 arch/um/kernel/skas/process.c                      |   31 +-
 arch/um/kernel/smp.c                               |  238 -
 arch/um/kernel/sysrq.c                             |    6 +-
 arch/um/kernel/trap.c                              |    2 +-
 arch/um/kernel/um_arch.c                           |   67 +-
 arch/um/os-Linux/process.c                         |   16 -
 arch/um/os-Linux/skas/mem.c                        |  100 +-
 arch/um/os-Linux/skas/process.c                    |  202 +-
 arch/um/os-Linux/start_up.c                        |  154 -
 arch/um/sys-ia64/Makefile                          |   11 -
 arch/um/sys-ia64/sysdep/ptrace.h                   |   16 -
 arch/um/sys-ia64/sysdep/sigcontext.h               |   10 -
 arch/um/sys-ia64/sysdep/skas_ptrace.h              |   22 -
 arch/um/sys-ia64/sysdep/syscalls.h                 |   10 -
 arch/um/sys-ppc/Makefile                           |   65 -
 arch/um/sys-ppc/asm/archparam.h                    |    8 -
 arch/um/sys-ppc/asm/elf.h                          |   51 -
 arch/um/sys-ppc/asm/processor.h                    |   15 -
 arch/um/sys-ppc/misc.S                             |  111 -
 arch/um/sys-ppc/miscthings.c                       |   42 -
 arch/um/sys-ppc/ptrace.c                           |   58 -
 arch/um/sys-ppc/ptrace_user.c                      |   29 -
 arch/um/sys-ppc/shared/sysdep/ptrace.h             |   93 -
 arch/um/sys-ppc/shared/sysdep/sigcontext.h         |   52 -
 arch/um/sys-ppc/shared/sysdep/skas_ptrace.h        |   22 -
 arch/um/sys-ppc/shared/sysdep/syscalls.h           |   43 -
 arch/um/sys-ppc/sigcontext.c                       |    4 -
 arch/um/sys-ppc/sysrq.c                            |   33 -
 arch/unicore32/include/asm/thread_info.h           |    3 -
 arch/unicore32/kernel/asm-offsets.c                |    1 -
 arch/unicore32/kernel/signal.c                     |    7 -
 arch/x86/Kconfig                                   |   13 +-
 arch/x86/Kconfig.debug                             |    4 -
 arch/x86/Makefile                                  |    2 +-
 arch/x86/Makefile.um                               |    2 +-
 arch/x86/crypto/aesni-intel_glue.c                 |  187 +-
 arch/x86/crypto/camellia_aesni_avx2_glue.c         |   15 +-
 arch/x86/crypto/camellia_aesni_avx_glue.c          |   15 +-
 arch/x86/crypto/cast5_avx_glue.c                   |    9 +-
 arch/x86/crypto/cast6_avx_glue.c                   |   15 +-
 arch/x86/crypto/ghash-clmulni-intel_glue.c         |    7 +-
 arch/x86/crypto/glue_helper.c                      |    1 -
 arch/x86/crypto/serpent_avx2_glue.c                |   15 +-
 arch/x86/crypto/serpent_avx_glue.c                 |   15 +-
 arch/x86/crypto/serpent_sse2_glue.c                |   15 +-
 arch/x86/crypto/sha-mb/sha1_mb.c                   |    9 +-
 arch/x86/crypto/sha-mb/sha1_mb_mgr_init_avx2.c     |    2 +-
 arch/x86/crypto/sha1_ssse3_glue.c                  |  139 +-
 arch/x86/crypto/sha256-avx-asm.S                   |   10 +-
 arch/x86/crypto/sha256-avx2-asm.S                  |   10 +-
 arch/x86/crypto/sha256-ssse3-asm.S                 |   10 +-
 arch/x86/crypto/sha256_ssse3_glue.c                |  193 +-
 arch/x86/crypto/sha512-avx-asm.S                   |    6 +-
 arch/x86/crypto/sha512-avx2-asm.S                  |    8 +-
 arch/x86/crypto/sha512-ssse3-asm.S                 |    6 +-
 arch/x86/crypto/sha512_ssse3_glue.c                |  202 +-
 arch/x86/crypto/twofish_avx_glue.c                 |   15 +-
 arch/x86/ia32/ia32entry.S                          |    7 +
 arch/x86/include/asm/cpufeature.h                  |    1 +
 arch/x86/include/asm/intel-mid.h                   |    3 -
 arch/x86/include/asm/lguest.h                      |    7 +-
 arch/x86/include/asm/seccomp.h                     |   21 +-
 arch/x86/include/asm/seccomp_32.h                  |   11 -
 arch/x86/include/asm/seccomp_64.h                  |   17 -
 arch/x86/include/asm/serial.h                      |    8 +-
 arch/x86/include/asm/thread_info.h                 |    3 -
 arch/x86/include/uapi/asm/e820.h                   |   10 +
 arch/x86/include/uapi/asm/hyperv.h                 |    2 +
 arch/x86/include/uapi/asm/msr-index.h              |    8 +
 arch/x86/kernel/Makefile                           |    1 +
 arch/x86/kernel/acpi/boot.c                        |    2 +-
 arch/x86/kernel/apic/x2apic_cluster.c              |    4 +-
 arch/x86/kernel/cpu/amd.c                          |    3 +
 arch/x86/kernel/cpu/mtrr/if.c                      |   12 +-
 arch/x86/kernel/cpu/perf_event.h                   |   18 +-
 arch/x86/kernel/cpu/perf_event_intel.c             |    2 +-
 arch/x86/kernel/cpu/perf_event_intel_ds.c          |    8 +
 arch/x86/kernel/cpu/perf_event_intel_pt.c          |   33 +-
 arch/x86/kernel/cpu/perf_event_intel_rapl.c        |   94 +-
 arch/x86/kernel/e820.c                             |   26 +-
 arch/x86/kernel/early_printk.c                     |    6 -
 arch/x86/kernel/entry_64.S                         |    9 +
 arch/x86/kernel/i387.c                             |    8 +-
 arch/x86/kernel/pmem.c                             |   53 +
 arch/x86/kernel/process_64.c                       |   28 +
 arch/x86/kernel/signal.c                           |   38 +-
 arch/x86/kvm/assigned-dev.c                        |    2 +-
 arch/x86/kvm/lapic.c                               |   11 +-
 arch/x86/kvm/mmu.c                                 |   20 +-
 arch/x86/kvm/vmx.c                                 |   12 +-
 arch/x86/kvm/x86.c                                 |   10 +-
 arch/x86/lguest/boot.c                             |    7 +-
 arch/x86/lguest/head_32.S                          |   30 +-
 arch/x86/lib/usercopy_64.c                         |    2 +-
 arch/x86/platform/intel-mid/Makefile               |    1 -
 .../platform/intel-mid/early_printk_intel_mid.c    |  112 -
 arch/x86/syscalls/Makefile                         |    9 +
 arch/x86/um/Makefile                               |    1 -
 arch/x86/um/asm/barrier.h                          |   11 -
 arch/x86/um/asm/elf.h                              |    2 +-
 arch/x86/um/ldt.c                                  |  227 +-
 arch/x86/um/shared/sysdep/faultinfo_32.h           |    3 -
 arch/x86/um/shared/sysdep/faultinfo_64.h           |    3 -
 arch/x86/um/shared/sysdep/skas_ptrace.h            |   22 -
 arch/x86/um/signal.c                               |    7 -
 arch/x86/xen/apic.c                                |  180 +
 arch/x86/xen/enlighten.c                           |   90 +-
 arch/x86/xen/mmu.c                                 |  207 +-
 arch/x86/xen/trace.c                               |   50 +-
 arch/x86/xen/xen-head.S                            |   63 +-
 arch/xtensa/Kconfig                                |   30 +
 arch/xtensa/boot/dts/xtfpga.dtsi                   |   64 +
 arch/xtensa/configs/audio_kc705_defconfig          |  142 +
 arch/xtensa/include/asm/thread_info.h              |   13 -
 arch/xtensa/include/uapi/asm/unistd.h              |    8 +-
 arch/xtensa/kernel/Makefile                        |    1 +
 arch/xtensa/kernel/asm-offsets.c                   |    8 +
 arch/xtensa/kernel/signal.c                        |   11 +-
 arch/xtensa/platforms/iss/network.c                |   29 +-
 arch/xtensa/platforms/xtfpga/Makefile              |    3 +-
 .../platforms/xtfpga/include/platform/hardware.h   |    6 +-
 .../xtensa/platforms/xtfpga/include/platform/lcd.h |   15 +
 arch/xtensa/platforms/xtfpga/lcd.c                 |   55 +-
 arch/xtensa/platforms/xtfpga/setup.c               |   34 +
 block/blk-core.c                                   |   19 +-
 block/blk-mq-sysfs.c                               |    1 +
 block/blk-mq.c                                     |   71 +-
 crypto/Kconfig                                     |  142 +-
 crypto/Makefile                                    |    1 +
 crypto/ablk_helper.c                               |    3 +-
 crypto/algapi.c                                    |   42 +-
 crypto/algif_aead.c                                |  664 +++
 crypto/algif_rng.c                                 |    2 +-
 crypto/ansi_cprng.c                                |    6 +-
 crypto/api.c                                       |   10 +
 crypto/async_tx/async_pq.c                         |   19 +-
 crypto/cryptd.c                                    |   49 +-
 crypto/crypto_user.c                               |   39 +-
 crypto/drbg.c                                      |   64 +-
 crypto/mcryptd.c                                   |   25 +-
 crypto/proc.c                                      |    3 +
 crypto/sha1_generic.c                              |  102 +-
 crypto/sha256_generic.c                            |  133 +-
 crypto/sha512_generic.c                            |  123 +-
 crypto/tcrypt.c                                    |    4 +-
 crypto/testmgr.c                                   |   24 +-
 drivers/Makefile                                   |    2 +-
 drivers/acpi/Kconfig                               |   10 +-
 drivers/acpi/Makefile                              |    3 +-
 drivers/acpi/acpi_processor.c                      |    7 +-
 drivers/acpi/acpica/acapps.h                       |    8 +-
 drivers/acpi/acpica/acglobal.h                     |    5 +-
 drivers/acpi/acpica/aclocal.h                      |    2 +-
 drivers/acpi/acpica/acmacros.h                     |   13 +-
 drivers/acpi/acpica/acopcode.h                     |    2 +
 drivers/acpi/acpica/acresrc.h                      |    6 +-
 drivers/acpi/acpica/acstruct.h                     |    5 -
 drivers/acpi/acpica/actables.h                     |    9 +-
 drivers/acpi/acpica/acutils.h                      |   22 +-
 drivers/acpi/acpica/amlcode.h                      |    2 +-
 drivers/acpi/acpica/dsopcode.c                     |    7 +-
 drivers/acpi/acpica/dsutils.c                      |   11 +
 drivers/acpi/acpica/evgpe.c                        |    5 +-
 drivers/acpi/acpica/evregion.c                     |    2 +-
 drivers/acpi/acpica/evxfevnt.c                     |    5 +-
 drivers/acpi/acpica/exdump.c                       |    4 +-
 drivers/acpi/acpica/exfldio.c                      |   10 +-
 drivers/acpi/acpica/exoparg3.c                     |   13 +-
 drivers/acpi/acpica/exregion.c                     |   17 +-
 drivers/acpi/acpica/hwgpe.c                        |   24 +-
 drivers/acpi/acpica/hwvalid.c                      |   16 +-
 drivers/acpi/acpica/nsdump.c                       |   12 +-
 drivers/acpi/acpica/psopcode.c                     |    8 +-
 drivers/acpi/acpica/psopinfo.c                     |    2 +-
 drivers/acpi/acpica/rsdump.c                       |  227 +-
 drivers/acpi/acpica/tbdata.c                       |   35 +-
 drivers/acpi/acpica/tbinstal.c                     |   67 +-
 drivers/acpi/acpica/tbprint.c                      |   19 +-
 drivers/acpi/acpica/tbxfroot.c                     |    7 +-
 drivers/acpi/acpica/utaddress.c                    |   34 +-
 drivers/acpi/acpica/utbuffer.c                     |    8 +
 drivers/acpi/acpica/utglobal.c                     |   13 +-
 drivers/acpi/acpica/utmisc.c                       |    2 +
 drivers/acpi/acpica/utosi.c                        |    1 +
 drivers/acpi/acpica/utprint.c                      |   13 +-
 drivers/acpi/acpica/utstate.c                      |   34 -
 drivers/acpi/acpica/utuuid.c                       |    2 +
 drivers/acpi/bus.c                                 |    3 +
 drivers/acpi/ec.c                                  |    2 +-
 drivers/acpi/gsi.c                                 |  105 +
 drivers/acpi/internal.h                            |    4 +
 drivers/acpi/osl.c                                 |    6 +-
 drivers/acpi/processor_core.c                      |   60 +-
 drivers/acpi/scan.c                                |   39 +-
 drivers/acpi/tables.c                              |   52 +-
 drivers/ata/pata_macio.c                           |   10 +-
 drivers/ata/sata_svw.c                             |   11 +-
 drivers/base/devtmpfs.c                            |   32 +-
 drivers/base/power/wakeup.c                        |   16 +-
 drivers/bcma/driver_gpio.c                         |   20 +-
 drivers/bcma/driver_mips.c                         |    2 +-
 drivers/block/Kconfig                              |   11 +
 drivers/block/Makefile                             |    1 +
 drivers/block/drbd/drbd_debugfs.c                  |    8 +-
 drivers/block/drbd/drbd_main.c                     |    7 +-
 drivers/block/drbd/drbd_req.c                      |    3 +-
 drivers/block/loop.c                               |  298 +-
 drivers/block/nbd.c                                |  140 +-
 drivers/block/nvme-core.c                          |  159 +-
 drivers/block/nvme-scsi.c                          |   28 +-
 drivers/block/paride/pg.c                          |    4 +-
 drivers/block/pmem.c                               |  262 +
 drivers/block/rbd.c                                |   26 +-
 drivers/block/swim3.c                              |   12 +-
 drivers/block/virtio_blk.c                         |    9 +-
 drivers/block/xen-blkback/blkback.c                |   62 +-
 drivers/block/xen-blkback/common.h                 |    6 -
 drivers/block/xen-blkback/xenbus.c                 |   43 +-
 drivers/block/xen-blkfront.c                       |    5 +-
 drivers/block/zram/zram_drv.c                      |   73 +
 drivers/block/zram/zram_drv.h                      |    1 +
 drivers/bus/Kconfig                                |   86 +-
 drivers/bus/Makefile                               |   16 +-
 drivers/bus/arm-cci.c                              |  517 +-
 drivers/bus/imx-weim.c                             |   13 +-
 drivers/bus/mips_cdmm.c                            |  716 +++
 drivers/bus/omap-ocp2scp.c                         |   34 +
 drivers/bus/simple-pm-bus.c                        |   58 +
 drivers/char/hw_random/Kconfig                     |   13 +
 drivers/char/hw_random/Makefile                    |    1 +
 drivers/char/hw_random/bcm63xx-rng.c               |  120 +-
 drivers/char/hw_random/core.c                      |   79 +-
 drivers/char/hw_random/exynos-rng.c                |   12 +-
 drivers/char/hw_random/iproc-rng200.c              |  239 +
 drivers/char/hw_random/msm-rng.c                   |   11 +-
 drivers/char/hw_random/octeon-rng.c                |    4 +-
 drivers/char/hw_random/omap-rng.c                  |   23 +-
 drivers/char/hw_random/pasemi-rng.c                |    2 +-
 drivers/char/hw_random/powernv-rng.c               |    2 +-
 drivers/char/hw_random/ppc4xx-rng.c                |    2 +-
 drivers/char/hw_random/pseries-rng.c               |    4 +-
 drivers/char/hw_random/xgene-rng.c                 |   10 +
 drivers/char/i8k.c                                 |   16 +-
 drivers/char/ipmi/ipmi_si_intf.c                   |    4 +-
 drivers/char/mem.c                                 |   20 +-
 drivers/char/misc.c                                |   20 +-
 drivers/char/raw.c                                 |    2 -
 drivers/char/tpm/Kconfig                           |   20 +-
 drivers/char/tpm/Makefile                          |    2 +-
 drivers/char/tpm/st33zp24/Kconfig                  |   30 +
 drivers/char/tpm/st33zp24/Makefile                 |   12 +
 drivers/char/tpm/st33zp24/i2c.c                    |  276 +
 drivers/char/tpm/st33zp24/spi.c                    |  399 ++
 drivers/char/tpm/st33zp24/st33zp24.c               |  698 +++
 drivers/char/tpm/st33zp24/st33zp24.h               |   37 +
 drivers/char/tpm/tpm-chip.c                        |   66 +-
 drivers/char/tpm/tpm_i2c_stm_st33.c                |  911 ----
 drivers/char/tpm/tpm_infineon.c                    |   34 +-
 drivers/char/tpm/xen-tpmfront.c                    |    5 +-
 drivers/char/virtio_console.c                      |    2 +-
 drivers/char/xillybus/xillybus_core.c              |    2 +
 drivers/char/xillybus/xillybus_of.c                |    2 +-
 drivers/clk/Kconfig                                |    7 +
 drivers/clk/Makefile                               |    3 +
 drivers/clk/at91/clk-usb.c                         |   64 +-
 drivers/clk/bcm/clk-kona.c                         |   28 +-
 drivers/clk/bcm/clk-kona.h                         |    1 -
 drivers/clk/clk-cdce706.c                          |    2 +-
 drivers/clk/clk-conf.c                             |    7 +-
 drivers/clk/clk-fractional-divider.c               |    3 +
 drivers/clk/clk-gpio-gate.c                        |   31 +-
 drivers/clk/clk-mb86s7x.c                          |  386 ++
 drivers/clk/clk-palmas.c                           |    2 +-
 drivers/clk/clk-pwm.c                              |  136 +
 drivers/clk/clk-si5351.c                           |   10 +-
 drivers/clk/clk-si570.c                            |    2 +-
 drivers/clk/clk.c                                  |  157 +-
 drivers/clk/clk.h                                  |    3 -
 drivers/clk/clkdev.c                               |   30 +-
 drivers/clk/hisilicon/clk-hi3620.c                 |   70 +-
 drivers/clk/hisilicon/clk-hix5hd2.c                |    6 +-
 drivers/clk/mvebu/Kconfig                          |    4 +
 drivers/clk/mvebu/Makefile                         |    1 +
 drivers/clk/mvebu/armada-39x.c                     |  156 +
 drivers/clk/mvebu/common.c                         |   17 +
 drivers/clk/mvebu/common.h                         |    1 +
 drivers/clk/mxs/clk-imx23.c                        |   12 +-
 drivers/clk/mxs/clk-imx28.c                        |   18 +-
 drivers/clk/pistachio/Makefile                     |    3 +
 drivers/clk/pistachio/clk-pistachio.c              |  329 ++
 drivers/clk/pistachio/clk-pll.c                    |  401 ++
 drivers/clk/pistachio/clk.c                        |  140 +
 drivers/clk/pistachio/clk.h                        |  174 +
 drivers/clk/pxa/clk-pxa.h                          |    2 +-
 drivers/clk/pxa/clk-pxa3xx.c                       |    3 +
 drivers/clk/qcom/Kconfig                           |    9 +
 drivers/clk/qcom/Makefile                          |    1 +
 drivers/clk/qcom/clk-pll.c                         |    6 +-
 drivers/clk/qcom/clk-rcg.c                         |  188 +-
 drivers/clk/qcom/clk-rcg.h                         |   15 +-
 drivers/clk/qcom/clk-rcg2.c                        |   43 +-
 drivers/clk/qcom/common.c                          |   12 +
 drivers/clk/qcom/common.h                          |    4 +
 drivers/clk/qcom/gcc-apq8084.c                     |   62 +-
 drivers/clk/qcom/gcc-ipq806x.c                     |   80 +-
 drivers/clk/qcom/gcc-msm8660.c                     |   22 +-
 drivers/clk/qcom/gcc-msm8916.c                     | 2868 +++++++++++
 drivers/clk/qcom/gcc-msm8960.c                     |   32 +-
 drivers/clk/qcom/gcc-msm8974.c                     |   30 +-
 drivers/clk/qcom/lcc-ipq806x.c                     |   35 +-
 drivers/clk/qcom/lcc-msm8960.c                     |   12 +-
 drivers/clk/qcom/mmcc-apq8084.c                    |  168 +-
 drivers/clk/qcom/mmcc-msm8960.c                    |   49 +-
 drivers/clk/qcom/mmcc-msm8974.c                    |  134 +-
 drivers/clk/rockchip/clk-rk3188.c                  |    2 +-
 drivers/clk/rockchip/clk-rk3288.c                  |    2 +-
 drivers/clk/rockchip/clk.c                         |    3 +-
 drivers/clk/rockchip/clk.h                         |    4 +-
 drivers/clk/samsung/Makefile                       |    1 +
 drivers/clk/samsung/clk-exynos-clkout.c            |    4 +
 drivers/clk/samsung/clk-exynos3250.c               |  163 +
 drivers/clk/samsung/clk-exynos4.c                  |   11 +-
 drivers/clk/samsung/clk-exynos5433.c               | 5423 ++++++++++++=
++++++++
 drivers/clk/samsung/clk-s5pv210.c                  |   56 +-
 drivers/clk/shmobile/Makefile                      |    1 +
 drivers/clk/shmobile/clk-r8a7778.c                 |  143 +
 drivers/clk/st/clkgen-fsyn.c                       |    2 +-
 drivers/clk/st/clkgen-mux.c                        |    8 +-
 drivers/clk/st/clkgen-pll.c                        |    4 +-
 drivers/clk/sunxi/Makefile                         |    1 +
 drivers/clk/sunxi/clk-sunxi.c                      |  185 +-
 drivers/clk/sunxi/clk-usb.c                        |  233 +
 drivers/clk/tegra/clk-pll.c                        |    7 +-
 drivers/clk/tegra/clk-tegra-fixed.c                |   24 +-
 drivers/clk/tegra/clk-tegra-periph.c               |    2 +-
 drivers/clk/tegra/clk-tegra114.c                   |   36 +-
 drivers/clk/tegra/clk-tegra124.c                   |   22 +-
 drivers/clk/tegra/clk-tegra30.c                    |   23 +-
 drivers/clk/tegra/clk.c                            |   16 +-
 drivers/clk/tegra/clk.h                            |   10 +-
 drivers/clk/ti/apll.c                              |    5 +-
 drivers/clk/ti/autoidle.c                          |    2 +-
 drivers/clk/ti/clk-3xxx-legacy.c                   |   16 +-
 drivers/clk/ti/clk-3xxx.c                          |   19 +-
 drivers/clk/ti/clk-44xx.c                          |   11 -
 drivers/clk/ti/clk-54xx.c                          |   22 +-
 drivers/clk/ti/clk-7xx.c                           |   18 +-
 drivers/clk/ti/clk-dra7-atl.c                      |    2 +-
 drivers/clk/ti/clk.c                               |    7 +-
 drivers/clk/ti/clockdomain.c                       |    2 +-
 drivers/clk/ti/composite.c                         |    2 +-
 drivers/clk/ti/divider.c                           |    4 +-
 drivers/clk/ti/dpll.c                              |    6 +-
 drivers/clk/ti/fapll.c                             |  270 +-
 drivers/clk/ti/gate.c                              |    4 +-
 drivers/clk/ti/interface.c                         |    2 +-
 drivers/clk/ti/mux.c                               |    4 +-
 drivers/clk/versatile/clk-versatile.c              |    2 +-
 drivers/clk/versatile/clk-vexpress-osc.c           |    2 +-
 drivers/clk/zynq/clkc.c                            |   24 +-
 drivers/clocksource/Kconfig                        |    7 +-
 drivers/clocksource/Makefile                       |    1 +
 drivers/clocksource/arm_arch_timer.c               |  132 +-
 drivers/clocksource/dw_apb_timer.c                 |    3 +-
 drivers/clocksource/mips-gic-timer.c               |   13 +-
 .../clocksource/timer-atmel-st.c                   |  117 +-
 drivers/cpufreq/intel_pstate.c                     |   14 +-
 drivers/cpuidle/coupled.c                          |    6 +-
 drivers/cpuidle/cpuidle-exynos.c                   |    3 +-
 drivers/cpuidle/governors/menu.c                   |    8 +-
 drivers/crypto/Kconfig                             |   25 +-
 drivers/crypto/Makefile                            |    2 +
 drivers/crypto/amcc/crypto4xx_core.c               |    6 +-
 drivers/crypto/atmel-aes.c                         |   26 +-
 drivers/crypto/atmel-sha.c                         |   37 +-
 drivers/crypto/atmel-tdes.c                        |    3 +-
 drivers/crypto/caam/caamhash.c                     |    1 +
 drivers/crypto/caam/caamrng.c                      |    6 +-
 drivers/crypto/ccp/Makefile                        |    9 +-
 drivers/crypto/ccp/ccp-crypto-aes-cmac.c           |   12 +-
 drivers/crypto/ccp/ccp-crypto-aes-xts.c            |    4 +-
 drivers/crypto/ccp/ccp-crypto-aes.c                |    3 +-
 drivers/crypto/ccp/ccp-crypto-main.c               |    5 +-
 drivers/crypto/ccp/ccp-crypto-sha.c                |   12 +-
 drivers/crypto/ccp/ccp-crypto.h                    |    3 -
 drivers/crypto/ccp/ccp-dev.c                       |    7 +-
 drivers/crypto/ccp/ccp-dev.h                       |   12 +-
 drivers/crypto/ccp/ccp-ops.c                       |   24 +-
 drivers/crypto/ccp/ccp-pci.c                       |   21 +-
 drivers/crypto/ccp/ccp-platform.c                  |  111 +-
 drivers/crypto/img-hash.c                          | 1029 ++++
 drivers/crypto/mxs-dcp.c                           |    2 +-
 drivers/crypto/n2_core.c                           |    4 +-
 drivers/crypto/omap-aes.c                          |   14 +-
 drivers/crypto/omap-sham.c                         |    2 +
 drivers/crypto/qat/qat_common/adf_accel_devices.h  |    1 -
 drivers/crypto/qat/qat_common/adf_accel_engine.c   |   35 +-
 drivers/crypto/qat/qat_common/adf_aer.c            |   21 +-
 drivers/crypto/qat/qat_common/adf_cfg.c            |    5 +-
 drivers/crypto/qat/qat_common/adf_cfg_strings.h    |   10 +-
 drivers/crypto/qat/qat_common/adf_common_drv.h     |    2 +-
 drivers/crypto/qat/qat_common/adf_ctl_drv.c        |   66 +-
 drivers/crypto/qat/qat_common/adf_dev_mgr.c        |    3 +-
 drivers/crypto/qat/qat_common/adf_init.c           |   88 +-
 drivers/crypto/qat/qat_common/adf_transport.c      |   31 +-
 .../crypto/qat/qat_common/adf_transport_debug.c    |    2 +
 drivers/crypto/qat/qat_common/icp_qat_hw.h         |    2 +-
 drivers/crypto/qat/qat_common/qat_crypto.c         |    9 +-
 drivers/crypto/qat/qat_common/qat_hal.c            |    6 +-
 drivers/crypto/qat/qat_dh895xcc/adf_admin.c        |    3 +-
 .../crypto/qat/qat_dh895xcc/adf_dh895xcc_hw_data.c |    3 +-
 .../crypto/qat/qat_dh895xcc/adf_dh895xcc_hw_data.h |    6 +-
 drivers/crypto/qat/qat_dh895xcc/adf_drv.c          |    4 +-
 drivers/crypto/qat/qat_dh895xcc/adf_isr.c          |   15 +-
 drivers/crypto/sahara.c                            |   51 +-
 drivers/crypto/talitos.c                           |   17 +-
 drivers/crypto/ux500/hash/hash_core.c              |    2 +-
 drivers/crypto/vmx/Kconfig                         |    8 +
 drivers/crypto/vmx/Makefile                        |   19 +
 drivers/crypto/vmx/aes.c                           |  139 +
 drivers/crypto/vmx/aes_cbc.c                       |  184 +
 drivers/crypto/vmx/aes_ctr.c                       |  167 +
 drivers/crypto/vmx/aesp8-ppc.h                     |   20 +
 drivers/crypto/vmx/aesp8-ppc.pl                    | 1930 +++++++
 drivers/crypto/vmx/ghash.c                         |  214 +
 drivers/crypto/vmx/ghashp8-ppc.pl                  |  228 +
 drivers/crypto/vmx/ppc-xlate.pl                    |  207 +
 drivers/crypto/vmx/vmx.c                           |   88 +
 drivers/dma-buf/dma-buf.c                          |   47 +-
 drivers/dma/Kconfig                                |   31 +
 drivers/dma/Makefile                               |    4 +
 drivers/dma/amba-pl08x.c                           |   11 -
 drivers/dma/at_hdmac.c                             |  175 +-
 drivers/dma/at_xdmac.c                             |    4 +-
 drivers/dma/bestcomm/bestcomm.c                    |    4 +-
 drivers/dma/dma-jz4740.c                           |   12 +-
 drivers/dma/dma-jz4780.c                           |  877 ++++
 drivers/dma/dmaengine.c                            |   18 -
 drivers/dma/dw/Kconfig                             |    2 +-
 drivers/dma/dw/core.c                              |   18 +-
 drivers/dma/edma.c                                 |    2 +-
 drivers/dma/fsl_raid.c                             |  904 ++++
 drivers/dma/fsl_raid.h                             |  306 ++
 drivers/dma/hsu/Kconfig                            |   14 +
 drivers/dma/hsu/Makefile                           |    5 +
 drivers/dma/hsu/hsu.c                              |  495 ++
 drivers/dma/hsu/hsu.h                              |  118 +
 drivers/dma/hsu/pci.c                              |  124 +
 drivers/dma/img-mdc-dma.c                          |    6 -
 drivers/dma/imx-sdma.c                             |    4 +
 drivers/dma/ioat/dca.c                             |    4 -
 drivers/dma/ioat/dma.c                             |    4 -
 drivers/dma/ioat/dma.h                             |    4 -
 drivers/dma/ioat/dma_v2.c                          |    4 -
 drivers/dma/ioat/dma_v2.h                          |    4 -
 drivers/dma/ioat/dma_v3.c                          |    4 -
 drivers/dma/ioat/hw.h                              |    4 -
 drivers/dma/ioat/pci.c                             |    4 -
 drivers/dma/ioat/registers.h                       |    4 -
 drivers/dma/iop-adma.c                             |    4 -
 drivers/dma/k3dma.c                                |    8 +-
 drivers/dma/mmp_pdma.c                             |    2 +-
 drivers/dma/mmp_tdma.c                             |    2 +-
 drivers/dma/mpc512x_dma.c                          |    6 +-
 drivers/dma/mv_xor.c                               |    6 +-
 drivers/dma/mv_xor.h                               |    4 -
 drivers/dma/of-dma.c                               |    1 +
 drivers/dma/pch_dma.c                              |    1 +
 drivers/dma/pl330.c                                |   26 +-
 drivers/dma/ppc4xx/adma.c                          |    4 -
 drivers/dma/qcom_bam_dma.c                         |   44 +-
 drivers/dma/s3c24xx-dma.c                          |   13 +-
 drivers/dma/sa11x0-dma.c                           |   12 +-
 drivers/dma/sh/Kconfig                             |   15 +-
 drivers/dma/sh/Makefile                            |    2 +-
 drivers/dma/sh/rcar-audmapp.c                      |  376 --
 drivers/dma/sh/shdma-base.c                        |   73 +-
 drivers/dma/sh/shdmac.c                            |    4 +-
 drivers/dma/sh/usb-dmac.c                          |  910 ++++
 drivers/dma/sirf-dma.c                             |    2 +-
 drivers/dma/ste_dma40.c                            |    6 +-
 drivers/dma/sun6i-dma.c                            |    8 +-
 drivers/dma/xgene-dma.c                            | 2089 ++++++++
 drivers/dma/xilinx/xilinx_vdma.c                   |    2 +-
 drivers/extcon/Kconfig                             |   17 +
 drivers/extcon/Makefile                            |    4 +-
 drivers/extcon/extcon-arizona.c                    |   49 +-
 drivers/extcon/extcon-max14577.c                   |    5 +-
 drivers/extcon/extcon-max77693.c                   |   37 +-
 drivers/extcon/extcon-max77843.c                   |  881 ++++
 drivers/extcon/extcon-max8997.c                    |    5 +-
 drivers/extcon/extcon-rt8973a.c                    |    6 +-
 drivers/extcon/extcon-sm5502.c                     |    6 +-
 drivers/extcon/extcon-usb-gpio.c                   |  237 +
 drivers/extcon/{extcon-class.c =3D> extcon.c}        |   36 +-
 drivers/firmware/Kconfig                           |    4 +
 drivers/firmware/Makefile                          |    2 +
 drivers/firmware/pcdp.c                            |    4 +-
 drivers/firmware/qcom_scm.c                        |  494 ++
 drivers/gpio/Kconfig                               |  732 +--
 drivers/gpio/Makefile                              |    3 +-
 drivers/gpio/devres.c                              |  107 +-
 drivers/gpio/gpio-adp5588.c                        |    8 +-
 drivers/gpio/gpio-altera.c                         |  374 ++
 drivers/gpio/gpio-arizona.c                        |    3 +-
 drivers/gpio/gpio-crystalcove.c                    |    7 +-
 drivers/gpio/gpio-da9052.c                         |    2 +-
 drivers/gpio/gpio-da9055.c                         |    2 +-
 drivers/gpio/gpio-f7188x.c                         |   47 +-
 drivers/gpio/gpio-ich.c                            |    6 +
 drivers/gpio/gpio-kempld.c                         |    2 +-
 .../common/gpio.c =3D> drivers/gpio/gpio-loongson.c  |  120 +-
 drivers/gpio/gpio-max7300.c                        |    4 +-
 drivers/gpio/gpio-max732x.c                        |  134 +-
 drivers/gpio/gpio-mb86s7x.c                        |    5 +
 drivers/gpio/gpio-mc33880.c                        |    2 +-
 drivers/gpio/gpio-mcp23s08.c                       |    9 +-
 drivers/gpio/gpio-msm-v1.c                         |  714 ---
 drivers/gpio/gpio-mvebu.c                          |   24 +-
 drivers/gpio/gpio-omap.c                           |  131 +-
 drivers/gpio/gpio-pcf857x.c                        |  134 +-
 drivers/gpio/gpio-pxa.c                            |    3 +-
 drivers/gpio/gpio-rcar.c                           |   63 +-
 drivers/gpio/gpio-tb10x.c                          |    2 +-
 drivers/gpio/gpio-vf610.c                          |   16 +-
 drivers/gpio/gpio-xgene-sb.c                       |    2 +-
 drivers/gpio/gpiolib-acpi.c                        |   86 +-
 drivers/gpio/gpiolib-of.c                          |  111 +
 drivers/gpio/gpiolib.c                             |  299 +-
 drivers/gpio/gpiolib.h                             |   13 +
 drivers/gpu/drm/Kconfig                            |    9 +
 drivers/gpu/drm/Makefile                           |    1 +
 drivers/gpu/drm/amd/amdkfd/kfd_chardev.c           |   13 +-
 drivers/gpu/drm/amd/amdkfd/kfd_device.c            |   17 +-
 .../gpu/drm/amd/amdkfd/kfd_device_queue_manager.c  |   18 +-
 drivers/gpu/drm/amd/amdkfd/kfd_doorbell.c          |   17 +-
 drivers/gpu/drm/amd/amdkfd/kfd_module.c            |   12 +-
 drivers/gpu/drm/amd/amdkfd/kfd_mqd_manager_cik.c   |   13 +-
 drivers/gpu/drm/amd/amdkfd/kfd_priv.h              |   14 +-
 drivers/gpu/drm/amd/amdkfd/kfd_process.c           |    6 +
 drivers/gpu/drm/amd/amdkfd/kfd_topology.c          |   12 +-
 drivers/gpu/drm/amd/include/kgd_kfd_interface.h    |   64 +-
 drivers/gpu/drm/armada/armada_gem.c                |   10 +-
 drivers/gpu/drm/armada/armada_output.h             |    2 +-
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_crtc.c     |  311 +-
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_dc.c       |   40 +
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_dc.h       |   62 +-
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_layer.c    |    4 +-
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_layer.h    |    3 +-
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_output.c   |   41 +-
 drivers/gpu/drm/atmel-hlcdc/atmel_hlcdc_plane.c    |  640 ++-
 drivers/gpu/drm/bochs/bochs_hw.c                   |    1 +
 drivers/gpu/drm/bridge/Kconfig                     |   11 +
 drivers/gpu/drm/bridge/Makefile                    |    1 +
 drivers/gpu/drm/bridge/dw_hdmi.c                   |   54 +-
 drivers/gpu/drm/bridge/ps8622.c                    |  684 +++
 drivers/gpu/drm/bridge/ptn3460.c                   |    2 +-
 drivers/gpu/drm/drm_atomic.c                       |  205 +-
 drivers/gpu/drm/drm_atomic_helper.c                |  660 +--
 drivers/gpu/drm/drm_bridge.c                       |    2 +-
 drivers/gpu/drm/drm_crtc.c                         |  114 +-
 drivers/gpu/drm/drm_crtc_helper.c                  |   34 +-
 drivers/gpu/drm/drm_dp_helper.c                    |   80 +-
 drivers/gpu/drm/drm_dp_mst_topology.c              |   13 +
 drivers/gpu/drm/drm_drv.c                          |    2 +-
 drivers/gpu/drm/drm_fb_cma_helper.c                |    2 +-
 drivers/gpu/drm/drm_fb_helper.c                    |   62 +-
 drivers/gpu/drm/drm_info.c                         |    1 +
 drivers/gpu/drm/drm_ioc32.c                        |    2 +-
 drivers/gpu/drm/drm_ioctl.c                        |   63 +-
 drivers/gpu/drm/drm_irq.c                          |   58 +-
 drivers/gpu/drm/drm_modes.c                        |   12 +-
 drivers/gpu/drm/drm_of.c                           |   10 +-
 drivers/gpu/drm/drm_pci.c                          |    1 +
 drivers/gpu/drm/drm_plane_helper.c                 |   39 +-
 drivers/gpu/drm/drm_prime.c                        |   12 +-
 drivers/gpu/drm/drm_probe_helper.c                 |    2 +-
 drivers/gpu/drm/drm_sysfs.c                        |   61 +-
 drivers/gpu/drm/drm_vm.c                           |    1 +
 drivers/gpu/drm/exynos/exynos7_drm_decon.c         |  178 +-
 drivers/gpu/drm/exynos/exynos_dp_core.c            |   10 +
 drivers/gpu/drm/exynos/exynos_drm_crtc.c           |  101 +-
 drivers/gpu/drm/exynos/exynos_drm_crtc.h           |    7 +-
 drivers/gpu/drm/exynos/exynos_drm_dmabuf.c         |    9 +-
 drivers/gpu/drm/exynos/exynos_drm_drv.c            |   27 -
 drivers/gpu/drm/exynos/exynos_drm_drv.h            |   40 +-
 drivers/gpu/drm/exynos/exynos_drm_dsi.c            |    7 -
 drivers/gpu/drm/exynos/exynos_drm_fb.c             |   10 +-
 drivers/gpu/drm/exynos/exynos_drm_fbdev.c          |    5 +-
 drivers/gpu/drm/exynos/exynos_drm_fimd.c           |  251 +-
 drivers/gpu/drm/exynos/exynos_drm_fimd.h           |   15 +
 drivers/gpu/drm/exynos/exynos_drm_ipp.c            |   44 +
 drivers/gpu/drm/exynos/exynos_drm_plane.c          |   78 +-
 drivers/gpu/drm/exynos/exynos_drm_plane.h          |    7 +-
 drivers/gpu/drm/exynos/exynos_drm_vidi.c           |  136 +-
 drivers/gpu/drm/exynos/exynos_hdmi.c               |    4 +-
 drivers/gpu/drm/exynos/exynos_mixer.c              |  260 +-
 drivers/gpu/drm/exynos/regs-mixer.h                |    2 +-
 drivers/gpu/drm/gma500/cdv_intel_display.c         |    2 +-
 drivers/gpu/drm/gma500/cdv_intel_hdmi.c            |    2 +-
 drivers/gpu/drm/gma500/cdv_intel_lvds.c            |    2 +-
 drivers/gpu/drm/gma500/gma_display.c               |   10 +-
 drivers/gpu/drm/gma500/mdfld_dsi_output.c          |    2 +-
 drivers/gpu/drm/gma500/mdfld_intel_display.c       |    2 +-
 drivers/gpu/drm/gma500/oaktrail_crtc.c             |    2 +-
 drivers/gpu/drm/gma500/oaktrail_hdmi.c             |    2 +-
 drivers/gpu/drm/gma500/psb_intel_display.c         |    2 +-
 drivers/gpu/drm/gma500/psb_intel_lvds.c            |    2 +-
 drivers/gpu/drm/i2c/adv7511.c                      |  197 +-
 drivers/gpu/drm/i2c/tda998x_drv.c                  |  101 +-
 drivers/gpu/drm/i915/Makefile                      |    7 +-
 drivers/gpu/drm/i915/i915_cmd_parser.c             |   75 +-
 drivers/gpu/drm/i915/i915_debugfs.c                |  352 +-
 drivers/gpu/drm/i915/i915_dma.c                    |  242 +-
 drivers/gpu/drm/i915/i915_drv.c                    |  182 +-
 drivers/gpu/drm/i915/i915_drv.h                    |  392 +-
 drivers/gpu/drm/i915/i915_gem.c                    |  548 +-
 drivers/gpu/drm/i915/i915_gem_context.c            |  115 +-
 drivers/gpu/drm/i915/i915_gem_dmabuf.c             |   10 +-
 drivers/gpu/drm/i915/i915_gem_evict.c              |    4 +
 drivers/gpu/drm/i915/i915_gem_execbuffer.c         |  194 +-
 drivers/gpu/drm/i915/i915_gem_gtt.c                | 1068 ++--
 drivers/gpu/drm/i915/i915_gem_gtt.h                |  160 +-
 drivers/gpu/drm/i915/i915_gem_shrinker.c           |  335 ++
 drivers/gpu/drm/i915/i915_gem_stolen.c             |    8 +-
 drivers/gpu/drm/i915/i915_gpu_error.c              |   22 +-
 drivers/gpu/drm/i915/i915_irq.c                    |  294 +-
 drivers/gpu/drm/i915/i915_params.c                 |   19 +-
 drivers/gpu/drm/i915/i915_reg.h                    |  200 +-
 drivers/gpu/drm/i915/i915_suspend.c                |  215 +-
 drivers/gpu/drm/i915/i915_sysfs.c                  |   78 +-
 drivers/gpu/drm/i915/i915_trace.h                  |  107 +-
 drivers/gpu/drm/i915/i915_ums.c                    |  552 --
 drivers/gpu/drm/i915/i915_vgpu.c                   |  264 +
 drivers/gpu/drm/i915/i915_vgpu.h                   |   91 +
 drivers/gpu/drm/i915/intel_atomic.c                |   16 +-
 drivers/gpu/drm/i915/intel_atomic_plane.c          |   24 +-
 drivers/gpu/drm/i915/intel_bios.c                  |    7 +
 drivers/gpu/drm/i915/intel_bios.h                  |    1 +
 drivers/gpu/drm/i915/intel_crt.c                   |   11 +-
 drivers/gpu/drm/i915/intel_ddi.c                   |  111 +-
 drivers/gpu/drm/i915/intel_display.c               | 1788 ++++---
 drivers/gpu/drm/i915/intel_dp.c                    |  459 +-
 drivers/gpu/drm/i915/intel_dp_mst.c                |   38 +-
 drivers/gpu/drm/i915/intel_drv.h                   |  129 +-
 drivers/gpu/drm/i915/intel_dsi.c                   |    5 +-
 drivers/gpu/drm/i915/intel_dvo.c                   |    3 +-
 drivers/gpu/drm/i915/intel_fbc.c                   |  184 +-
 drivers/gpu/drm/i915/intel_fbdev.c                 |   32 +-
 drivers/gpu/drm/i915/intel_frontbuffer.c           |   21 +-
 drivers/gpu/drm/i915/intel_hdmi.c                  |   29 +-
 drivers/gpu/drm/i915/intel_i2c.c                   |   66 +-
 drivers/gpu/drm/i915/intel_lrc.c                   |  243 +-
 drivers/gpu/drm/i915/intel_lrc.h                   |   12 +-
 drivers/gpu/drm/i915/intel_lvds.c                  |   11 +-
 drivers/gpu/drm/i915/intel_opregion.c              |    6 +-
 drivers/gpu/drm/i915/intel_overlay.c               |    5 +-
 drivers/gpu/drm/i915/intel_panel.c                 |    1 +
 drivers/gpu/drm/i915/intel_pm.c                    | 1286 ++---
 drivers/gpu/drm/i915/intel_psr.c                   |    2 -
 drivers/gpu/drm/i915/intel_ringbuffer.c            |  351 +-
 drivers/gpu/drm/i915/intel_ringbuffer.h            |   13 +-
 drivers/gpu/drm/i915/intel_runtime_pm.c            |  266 +-
 drivers/gpu/drm/i915/intel_sdvo.c                  |   25 +-
 drivers/gpu/drm/i915/intel_sprite.c                |  476 +-
 drivers/gpu/drm/i915/intel_tv.c                    |    5 +-
 drivers/gpu/drm/i915/intel_uncore.c                |   69 +-
 drivers/gpu/drm/imx/Kconfig                        |    1 +
 drivers/gpu/drm/imx/dw_hdmi-imx.c                  |   14 +-
 drivers/gpu/drm/imx/imx-drm-core.c                 |   34 +-
 drivers/gpu/drm/imx/imx-drm.h                      |   10 +-
 drivers/gpu/drm/imx/imx-ldb.c                      |  196 +-
 drivers/gpu/drm/imx/imx-tve.c                      |    6 +-
 drivers/gpu/drm/imx/ipuv3-crtc.c                   |   24 +-
 drivers/gpu/drm/imx/ipuv3-plane.c                  |    7 +-
 drivers/gpu/drm/imx/ipuv3-plane.h                  |    2 +-
 drivers/gpu/drm/imx/parallel-display.c             |   13 +-
 drivers/gpu/drm/mgag200/mgag200_mode.c             |    2 +-
 drivers/gpu/drm/msm/Kconfig                        |   11 +
 drivers/gpu/drm/msm/Makefile                       |    5 +
 drivers/gpu/drm/msm/dsi/dsi.c                      |  212 +
 drivers/gpu/drm/msm/dsi/dsi.h                      |  117 +
 drivers/gpu/drm/msm/dsi/dsi.xml.h                  |  418 +-
 drivers/gpu/drm/msm/dsi/dsi_host.c                 | 1993 +++++++
 drivers/gpu/drm/msm/dsi/dsi_manager.c              |  705 +++
 drivers/gpu/drm/msm/dsi/dsi_phy.c                  |  352 ++
 drivers/gpu/drm/msm/hdmi/hdmi_phy_8960.c           |   34 +
 drivers/gpu/drm/msm/mdp/mdp4/mdp4_plane.c          |    6 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5.xml.h            |  399 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_cfg.c            |  102 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_cfg.h            |   18 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_cmd_encoder.c    |  343 ++
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_crtc.c           |   86 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_ctl.c            |  315 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_ctl.h            |   75 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_encoder.c        |   83 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_irq.c            |   26 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_kms.c            |  200 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_kms.h            |   75 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_plane.c          |   10 +-
 drivers/gpu/drm/msm/mdp/mdp5/mdp5_smp.c            |   64 +-
 drivers/gpu/drm/msm/msm_atomic.c                   |    4 +-
 drivers/gpu/drm/msm/msm_drv.c                      |  100 +-
 drivers/gpu/drm/msm/msm_drv.h                      |   29 +
 drivers/gpu/drm/msm/msm_fbdev.c                    |    3 +-
 drivers/gpu/drm/msm/msm_gem.c                      |   25 +-
 drivers/gpu/drm/msm/msm_gem.h                      |    5 +-
 drivers/gpu/drm/msm/msm_kms.h                      |    4 +
 drivers/gpu/drm/nouveau/dispnv04/crtc.c            |    4 +-
 drivers/gpu/drm/nouveau/dispnv04/dac.c             |    4 +-
 drivers/gpu/drm/nouveau/dispnv04/dfp.c             |    4 +-
 drivers/gpu/drm/nouveau/dispnv04/disp.c            |    6 +-
 drivers/gpu/drm/nouveau/dispnv04/tvnv04.c          |    4 +-
 drivers/gpu/drm/nouveau/dispnv04/tvnv17.c          |    4 +-
 drivers/gpu/drm/nouveau/include/nvif/class.h       |   10 +
 drivers/gpu/drm/nouveau/include/nvkm/engine/ce.h   |    3 +
 drivers/gpu/drm/nouveau/include/nvkm/engine/fifo.h |    1 +
 drivers/gpu/drm/nouveau/include/nvkm/engine/gr.h   |    4 +-
 .../gpu/drm/nouveau/include/nvkm/subdev/instmem.h  |    1 +
 drivers/gpu/drm/nouveau/include/nvkm/subdev/pmu.h  |    1 +
 drivers/gpu/drm/nouveau/nouveau_bo.c               |    2 +
 drivers/gpu/drm/nouveau/nouveau_chan.c             |    3 +-
 drivers/gpu/drm/nouveau/nouveau_connector.c        |    4 +-
 drivers/gpu/drm/nouveau/nouveau_display.c          |    9 +-
 drivers/gpu/drm/nouveau/nouveau_drm.c              |    1 +
 drivers/gpu/drm/nouveau/nouveau_drm.h              |    4 +-
 drivers/gpu/drm/nouveau/nouveau_gem.c              |    3 +
 drivers/gpu/drm/nouveau/nouveau_platform.c         |   79 +-
 drivers/gpu/drm/nouveau/nouveau_platform.h         |   18 +
 drivers/gpu/drm/nouveau/nouveau_ttm.c              |    3 +
 drivers/gpu/drm/nouveau/nv84_fence.c               |   14 +-
 drivers/gpu/drm/nouveau/nvkm/engine/ce/Kbuild      |    1 +
 drivers/gpu/drm/nouveau/nvkm/engine/ce/gm204.c     |  173 +
 drivers/gpu/drm/nouveau/nvkm/engine/device/base.c  |   10 +-
 drivers/gpu/drm/nouveau/nvkm/engine/device/gk104.c |    6 +-
 drivers/gpu/drm/nouveau/nvkm/engine/device/gm100.c |   16 +-
 drivers/gpu/drm/nouveau/nvkm/engine/disp/gf110.c   |    4 +-
 drivers/gpu/drm/nouveau/nvkm/engine/disp/nv50.c    |    2 +-
 drivers/gpu/drm/nouveau/nvkm/engine/fifo/Kbuild    |    1 +
 drivers/gpu/drm/nouveau/nvkm/engine/fifo/gk104.c   |    7 +-
 drivers/gpu/drm/nouveau/nvkm/engine/fifo/gk104.h   |    2 +
 drivers/gpu/drm/nouveau/nvkm/engine/fifo/gm204.c   |   57 +
 drivers/gpu/drm/nouveau/nvkm/engine/gr/Kbuild      |    4 +
 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgf100.h  |   29 +
 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgk104.c  |   16 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgm107.c  |   20 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgm204.c  | 1054 ++++
 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgm206.c  |   83 +
 drivers/gpu/drm/nouveau/nvkm/engine/gr/fuc/gpc.fuc |  114 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgf100.fuc3.h |  294 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgf117.fuc3.h |  354 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgk104.fuc3.h |  354 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgk110.fuc3.h |  354 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgk208.fuc5.h |  230 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgm107.fuc5   |    2 +-
 .../drm/nouveau/nvkm/engine/gr/fuc/gpcgm107.fuc5.h |  480 +-
 .../gpu/drm/nouveau/nvkm/engine/gr/fuc/macros.fuc  |   32 +
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gf100.c     |   22 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gf100.h     |   20 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gf108.c     |    4 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gf110.c     |    4 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gk104.c     |   17 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gk110.c     |   45 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gk110b.c    |    4 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gk208.c     |   47 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gk20a.c     |    4 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gm107.c     |   26 +-
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gm204.c     |  387 ++
 drivers/gpu/drm/nouveau/nvkm/engine/gr/gm206.c     |   40 +
 .../gpu/drm/nouveau/nvkm/subdev/bios/shadowacpi.c  |    4 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/bus/hwsq.c     |    2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/bus/hwsq.h     |   44 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/clk/base.c     |    2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/devinit/nv04.h |    2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/fb/Kbuild      |    1 -
 drivers/gpu/drm/nouveau/nvkm/subdev/fb/base.c      |   26 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/fb/gk20a.c     |    1 -
 drivers/gpu/drm/nouveau/nvkm/subdev/fb/priv.h      |    1 -
 drivers/gpu/drm/nouveau/nvkm/subdev/fb/ramgk20a.c  |  149 -
 drivers/gpu/drm/nouveau/nvkm/subdev/fuse/gm107.c   |    4 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/instmem/Kbuild |    1 +
 .../gpu/drm/nouveau/nvkm/subdev/instmem/gk20a.c    |  440 ++
 drivers/gpu/drm/nouveau/nvkm/subdev/ltc/gf100.c    |   10 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/mxm/nv50.c     |    2 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/pmu/Kbuild     |    1 +
 drivers/gpu/drm/nouveau/nvkm/subdev/pmu/gk110.c    |   95 +
 drivers/gpu/drm/nouveau/nvkm/subdev/pmu/gk208.c    |    1 +
 drivers/gpu/drm/nouveau/nvkm/subdev/pmu/gk20a.c    |    7 +-
 drivers/gpu/drm/nouveau/nvkm/subdev/pmu/priv.h     |    2 +
 drivers/gpu/drm/omapdrm/omap_connector.c           |   14 +-
 drivers/gpu/drm/omapdrm/omap_crtc.c                |  622 +--
 drivers/gpu/drm/omapdrm/omap_dmm_priv.h            |    8 +-
 drivers/gpu/drm/omapdrm/omap_dmm_tiler.c           |   80 +-
 drivers/gpu/drm/omapdrm/omap_dmm_tiler.h           |    1 +
 drivers/gpu/drm/omapdrm/omap_drv.c                 |  241 +-
 drivers/gpu/drm/omapdrm/omap_drv.h                 |   23 +-
 drivers/gpu/drm/omapdrm/omap_fb.c                  |   66 +-
 drivers/gpu/drm/omapdrm/omap_fbdev.c               |   57 +-
 drivers/gpu/drm/omapdrm/omap_gem.c                 |   10 +-
 drivers/gpu/drm/omapdrm/omap_gem_dmabuf.c          |   29 +-
 drivers/gpu/drm/omapdrm/omap_irq.c                 |    2 +-
 drivers/gpu/drm/omapdrm/omap_plane.c               |  146 +-
 drivers/gpu/drm/panel/Kconfig                      |    1 +
 drivers/gpu/drm/panel/panel-simple.c               |  256 +-
 drivers/gpu/drm/qxl/qxl_drv.c                      |    2 +-
 drivers/gpu/drm/radeon/Kconfig                     |    8 +
 drivers/gpu/drm/radeon/Makefile                    |    2 +-
 drivers/gpu/drm/radeon/atombios_crtc.c             |   25 +-
 drivers/gpu/drm/radeon/atombios_dp.c               |   17 +-
 drivers/gpu/drm/radeon/atombios_encoders.c         |  171 +-
 drivers/gpu/drm/radeon/btc_dpm.c                   |   55 +-
 drivers/gpu/drm/radeon/ci_dpm.c                    |   14 +
 drivers/gpu/drm/radeon/cik.c                       |  132 +-
 drivers/gpu/drm/radeon/cikd.h                      |    2 +
 drivers/gpu/drm/radeon/evergreen.c                 |  129 +-
 drivers/gpu/drm/radeon/evergreend.h                |    1 +
 drivers/gpu/drm/radeon/kv_dpm.c                    |   23 +
 drivers/gpu/drm/radeon/ni.c                        |   29 +
 drivers/gpu/drm/radeon/ni_dpm.c                    |   36 +
 drivers/gpu/drm/radeon/ni_reg.h                    |   44 +
 drivers/gpu/drm/radeon/nid.h                       |   47 +
 drivers/gpu/drm/radeon/r600.c                      |   26 +
 drivers/gpu/drm/radeon/radeon.h                    |   12 +-
 drivers/gpu/drm/radeon/radeon_asic.c               |   49 +
 drivers/gpu/drm/radeon/radeon_asic.h               |   30 +
 drivers/gpu/drm/radeon/radeon_atombios.c           |    1 +
 drivers/gpu/drm/radeon/radeon_audio.c              |   24 +
 drivers/gpu/drm/radeon/radeon_connectors.c         |  132 +-
 drivers/gpu/drm/radeon/radeon_device.c             |    5 +
 drivers/gpu/drm/radeon/radeon_display.c            |   15 +-
 drivers/gpu/drm/radeon/radeon_dp_auxch.c           |  206 +
 drivers/gpu/drm/radeon/radeon_dp_mst.c             |  782 +++
 drivers/gpu/drm/radeon/radeon_drv.c                |   13 +-
 drivers/gpu/drm/radeon/radeon_encoders.c           |   14 +-
 drivers/gpu/drm/radeon/radeon_fb.c                 |   11 +
 drivers/gpu/drm/radeon/radeon_irq_kms.c            |   15 +
 drivers/gpu/drm/radeon/radeon_kfd.c                |   10 +-
 drivers/gpu/drm/radeon/radeon_kms.c                |   29 +
 drivers/gpu/drm/radeon/radeon_legacy_encoders.c    |    2 +-
 drivers/gpu/drm/radeon/radeon_mn.c                 |  102 +-
 drivers/gpu/drm/radeon/radeon_mode.h               |   72 +
 drivers/gpu/drm/radeon/radeon_vce.c                |    1 +
 drivers/gpu/drm/radeon/rs780_dpm.c                 |   22 +
 drivers/gpu/drm/radeon/rv6xx_dpm.c                 |   46 +
 drivers/gpu/drm/radeon/rv770_dpm.c                 |   44 +
 drivers/gpu/drm/radeon/si.c                        |  130 +-
 drivers/gpu/drm/radeon/si_dpm.c                    |   36 +
 drivers/gpu/drm/radeon/sid.h                       |    1 +
 drivers/gpu/drm/radeon/sumo_dpm.c                  |   28 +
 drivers/gpu/drm/radeon/trinity_dpm.c               |   25 +
 drivers/gpu/drm/rcar-du/rcar_du_crtc.c             |  400 +-
 drivers/gpu/drm/rcar-du/rcar_du_crtc.h             |    8 +-
 drivers/gpu/drm/rcar-du/rcar_du_drv.c              |   20 +-
 drivers/gpu/drm/rcar-du/rcar_du_drv.h              |   16 +-
 drivers/gpu/drm/rcar-du/rcar_du_encoder.c          |   71 +-
 drivers/gpu/drm/rcar-du/rcar_du_group.h            |    5 +
 drivers/gpu/drm/rcar-du/rcar_du_hdmicon.c          |    9 +-
 drivers/gpu/drm/rcar-du/rcar_du_hdmienc.c          |   65 +-
 drivers/gpu/drm/rcar-du/rcar_du_kms.c              |  358 +-
 drivers/gpu/drm/rcar-du/rcar_du_lvdscon.c          |    9 +-
 drivers/gpu/drm/rcar-du/rcar_du_lvdsenc.c          |   18 +-
 drivers/gpu/drm/rcar-du/rcar_du_lvdsenc.h          |    8 +-
 drivers/gpu/drm/rcar-du/rcar_du_plane.c            |  422 +-
 drivers/gpu/drm/rcar-du/rcar_du_plane.h            |   69 +-
 drivers/gpu/drm/rcar-du/rcar_du_vgacon.c           |    9 +-
 drivers/gpu/drm/rockchip/dw_hdmi-rockchip.c        |   14 +-
 drivers/gpu/drm/rockchip/rockchip_drm_drv.c        |   30 +-
 drivers/gpu/drm/rockchip/rockchip_drm_fbdev.c      |    7 +-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.c        |   17 +-
 drivers/gpu/drm/rockchip/rockchip_drm_gem.h        |    3 +-
 drivers/gpu/drm/rockchip/rockchip_drm_vop.c        |  143 +-
 drivers/gpu/drm/sti/sti_drm_crtc.c                 |  175 +-
 drivers/gpu/drm/sti/sti_drm_drv.c                  |   86 +-
 drivers/gpu/drm/sti/sti_drm_drv.h                  |    6 +
 drivers/gpu/drm/sti/sti_drm_plane.c                |   66 +-
 drivers/gpu/drm/sti/sti_dvo.c                      |    6 +-
 drivers/gpu/drm/sti/sti_hda.c                      |    6 +-
 drivers/gpu/drm/sti/sti_hdmi.c                     |    6 +-
 drivers/gpu/drm/tegra/dc.c                         |  105 +-
 drivers/gpu/drm/tegra/dc.h                         |    7 +-
 drivers/gpu/drm/tegra/drm.c                        |   22 +-
 drivers/gpu/drm/tegra/drm.h                        |    4 +-
 drivers/gpu/drm/tegra/gem.c                        |   10 +-
 drivers/gpu/drm/tegra/hdmi.c                       |    4 +-
 drivers/gpu/drm/tegra/hdmi.h                       |    2 +-
 drivers/gpu/drm/tegra/sor.c                        |  202 +-
 drivers/gpu/drm/ttm/ttm_object.c                   |    9 +-
 drivers/gpu/drm/udl/udl_dmabuf.c                   |    9 +-
 drivers/gpu/drm/vgem/Makefile                      |    4 +
 drivers/gpu/drm/vgem/vgem_dma_buf.c                |   94 +
 drivers/gpu/drm/vgem/vgem_drv.c                    |  364 ++
 .../drm/{i915/intel_dsi_cmd.h =3D> vgem/vgem_drv.h}  |   46 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_drv.c                |    4 +-
 drivers/gpu/host1x/syncpt.c                        |    6 +
 drivers/gpu/ipu-v3/ipu-dc.c                        |   18 +-
 drivers/gpu/ipu-v3/ipu-di.c                        |    9 +-
 drivers/gpu/ipu-v3/ipu-ic.c                        |    4 +-
 drivers/hv/channel.c                               |  125 +-
 drivers/hv/channel_mgmt.c                          |  223 +-
 drivers/hv/connection.c                            |   40 +-
 drivers/hv/hv.c                                    |   34 +-
 drivers/hv/hv_balloon.c                            |  143 +-
 drivers/hv/hv_util.c                               |   13 +-
 drivers/hv/hyperv_vmbus.h                          |   31 +
 drivers/hv/vmbus_drv.c                             |  136 +-
 drivers/hwmon/ina2xx.c                             |   17 +-
 drivers/hwmon/lm85.c                               |   26 +-
 drivers/hwmon/w83795.c                             |    8 +-
 drivers/hwtracing/coresight/Kconfig                |   61 +
 drivers/{ =3D> hwtracing}/coresight/Makefile         |    0
 .../{ =3D> hwtracing}/coresight/coresight-etb10.c    |    4 +-
 .../{ =3D> hwtracing}/coresight/coresight-etm-cp14.c |    0
 drivers/{ =3D> hwtracing}/coresight/coresight-etm.h  |    0
 .../{ =3D> hwtracing}/coresight/coresight-etm3x.c    |    0
 .../{ =3D> hwtracing}/coresight/coresight-funnel.c   |    0
 drivers/{ =3D> hwtracing}/coresight/coresight-priv.h |    0
 .../coresight/coresight-replicator.c               |    2 +-
 drivers/{ =3D> hwtracing}/coresight/coresight-tmc.c  |   60 +-
 drivers/{ =3D> hwtracing}/coresight/coresight-tpiu.c |    0
 drivers/{ =3D> hwtracing}/coresight/coresight.c      |    4 +-
 drivers/{ =3D> hwtracing}/coresight/of_coresight.c   |   31 +-
 drivers/i2c/busses/i2c-cros-ec-tunnel.c            |   51 +-
 drivers/i2c/busses/i2c-digicolor.c                 |    3 +-
 drivers/i2c/busses/i2c-jz4780.c                    |    1 +
 drivers/i2c/busses/i2c-mxs.c                       |    2 +-
 drivers/i2c/busses/i2c-pca-platform.c              |    2 +-
 drivers/i2c/busses/i2c-rk3x.c                      |    2 +-
 drivers/i2c/busses/i2c-st.c                        |   13 +-
 drivers/i2c/i2c-core.c                             |    5 +
 drivers/i2c/i2c-mux.c                              |    8 +-
 drivers/ide/cs5520.c                               |    2 +-
 drivers/ide/pmac.c                                 |   15 +-
 drivers/ide/setup-pci.c                            |    2 +-
 drivers/ide/sgiioc4.c                              |    4 +-
 drivers/infiniband/core/umem.c                     |    7 +-
 drivers/infiniband/core/uverbs_main.c              |   22 +-
 drivers/infiniband/hw/cxgb4/mem.c                  |    2 +-
 drivers/infiniband/hw/ipath/ipath_file_ops.c       |   18 +-
 drivers/infiniband/hw/ipath/ipath_fs.c             |   16 +-
 drivers/infiniband/hw/mlx4/alias_GUID.c            |  457 +-
 drivers/infiniband/hw/mlx4/mad.c                   |    9 +
 drivers/infiniband/hw/mlx4/main.c                  |   26 +-
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |   14 +-
 drivers/infiniband/hw/mlx4/qp.c                    |    7 +-
 drivers/infiniband/hw/mlx4/sysfs.c                 |   44 +-
 drivers/infiniband/hw/qib/qib_file_ops.c           |   20 +-
 drivers/infiniband/hw/qib/qib_fs.c                 |   20 +-
 drivers/infiniband/ulp/ipoib/ipoib.h               |   31 +-
 drivers/infiniband/ulp/ipoib/ipoib_cm.c            |   18 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c            |  195 +-
 drivers/infiniband/ulp/ipoib/ipoib_main.c          |   78 +-
 drivers/infiniband/ulp/ipoib/ipoib_multicast.c     |  520 +-
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c         |   44 +-
 drivers/infiniband/ulp/ipoib/ipoib_vlan.c          |    3 +-
 drivers/infiniband/ulp/iser/iscsi_iser.h           |   66 +-
 drivers/infiniband/ulp/iser/iser_initiator.c       |   66 +-
 drivers/infiniband/ulp/iser/iser_memory.c          |  523 +-
 drivers/infiniband/ulp/iser/iser_verbs.c           |  220 +-
 drivers/infiniband/ulp/isert/ib_isert.c            |  691 +--
 drivers/infiniband/ulp/isert/ib_isert.h            |   37 +-
 drivers/infiniband/ulp/srp/ib_srp.c                |    9 +-
 drivers/infiniband/ulp/srpt/ib_srpt.c              |  233 +-
 drivers/input/ff-core.c                            |   10 +-
 drivers/input/ff-memless.c                         |   18 +-
 drivers/input/joystick/xpad.c                      |   21 +-
 drivers/input/keyboard/cros_ec_keyb.c              |   13 +-
 drivers/input/keyboard/gpio_keys_polled.c          |    2 +-
 drivers/input/keyboard/lm8333.c                    |    4 +-
 drivers/input/mouse/Kconfig                        |   12 +
 drivers/input/mouse/Makefile                       |    1 +
 drivers/input/mouse/cyapa.c                        |    4 +-
 drivers/input/mouse/elan_i2c.h                     |    3 +
 drivers/input/mouse/elan_i2c_core.c                |   38 +-
 drivers/input/mouse/elan_i2c_i2c.c                 |   27 +-
 drivers/input/mouse/elan_i2c_smbus.c               |   12 +-
 drivers/input/mouse/psmouse-base.c                 |   17 +
 drivers/input/mouse/psmouse.h                      |    1 +
 drivers/input/mouse/vmmouse.c                      |  508 ++
 drivers/input/mouse/vmmouse.h                      |   30 +
 drivers/input/touchscreen/Kconfig                  |    2 +
 drivers/input/touchscreen/atmel_mxt_ts.c           |  141 +-
 drivers/input/touchscreen/elants_i2c.c             |    2 +-
 drivers/input/touchscreen/sur40.c                  |  434 +-
 drivers/iommu/amd_iommu.c                          |  250 +-
 drivers/iommu/amd_iommu_types.h                    |   13 +-
 drivers/iommu/amd_iommu_v2.c                       |    2 +-
 drivers/iommu/arm-smmu.c                           |  171 +-
 drivers/iommu/exynos-iommu.c                       |   87 +-
 drivers/iommu/fsl_pamu_domain.c                    |   60 +-
 drivers/iommu/fsl_pamu_domain.h                    |    2 +-
 drivers/iommu/intel-iommu.c                        |  203 +-
 drivers/iommu/intel_irq_remapping.c                |   17 +-
 drivers/iommu/io-pgtable-arm.c                     |    5 +
 drivers/iommu/iommu.c                              |   26 +-
 drivers/iommu/ipmmu-vmsa.c                         |   41 +-
 drivers/iommu/msm_iommu.c                          |   73 +-
 drivers/iommu/omap-iommu.c                         |   49 +-
 drivers/iommu/rockchip-iommu.c                     |   40 +-
 drivers/iommu/shmobile-iommu.c                     |   39 +-
 drivers/iommu/tegra-gart.c                         |   88 +-
 drivers/iommu/tegra-smmu.c                         |   59 +-
 drivers/irqchip/Kconfig                            |    5 +
 drivers/irqchip/Makefile                           |    1 +
 drivers/irqchip/irq-bcm7038-l1.c                   |  335 ++
 drivers/irqchip/irq-bcm7120-l2.c                   |  193 +-
 drivers/irqchip/irq-brcmstb-l2.c                   |    9 +-
 drivers/irqchip/irq-gic-v3.c                       |    2 +-
 drivers/irqchip/irq-gic.c                          |  104 +
 drivers/irqchip/irq-mips-gic.c                     |   46 +-
 drivers/irqchip/irqchip.c                          |    3 +
 drivers/leds/Kconfig                               |    8 +
 drivers/leds/Makefile                              |    1 +
 drivers/leds/led-class-flash.c                     |   82 -
 drivers/leds/led-class.c                           |   96 +-
 drivers/leds/leds-gpio.c                           |    2 +-
 drivers/leds/leds-lp8501.c                         |    2 +-
 drivers/leds/leds-lp8860.c                         |   14 +-
 drivers/leds/leds-pca963x.c                        |    2 +-
 drivers/leds/leds-pm8941-wled.c                    |  435 ++
 drivers/leds/leds-pwm.c                            |    3 -
 drivers/lguest/hypercalls.c                        |    5 +-
 drivers/lguest/interrupts_and_traps.c              |  105 +-
 drivers/lguest/lg.h                                |    2 +-
 drivers/lguest/lguest_user.c                       |    8 +
 drivers/macintosh/rack-meter.c                     |   30 +-
 drivers/macintosh/smu.c                            |    3 +-
 drivers/macintosh/via-pmu.c                        |   25 +-
 drivers/mailbox/Kconfig                            |    9 +
 drivers/mailbox/Makefile                           |    2 +
 drivers/mailbox/arm_mhu.c                          |  195 +
 drivers/mailbox/pcc.c                              |  122 +-
 drivers/mcb/mcb-pci.c                              |    4 +-
 drivers/md/Kconfig                                 |   43 +
 drivers/md/Makefile                                |    2 +
 drivers/md/bitmap.c                                |  189 +-
 drivers/md/bitmap.h                                |   10 +-
 drivers/md/dm-cache-policy-mq.c                    |  251 +-
 drivers/md/dm-crypt.c                              |   25 +-
 drivers/md/dm-delay.c                              |    2 +-
 drivers/md/dm-log-userspace-base.c                 |   91 +-
 drivers/md/dm-log-userspace-transfer.c             |    5 +-
 drivers/md/dm-log-writes.c                         |  825 +++
 drivers/md/dm-mpath.c                              |    6 +-
 drivers/md/dm-sysfs.c                              |   43 +-
 drivers/md/dm-table.c                              |   71 +-
 drivers/md/dm-verity.c                             |  147 +-
 drivers/md/dm.c                                    |  556 +-
 drivers/md/dm.h                                    |   10 +-
 drivers/md/md-cluster.c                            |  965 ++++
 drivers/md/md-cluster.h                            |   29 +
 drivers/md/md.c                                    |  382 +-
 drivers/md/md.h                                    |   26 +-
 drivers/md/raid0.c                                 |   48 +-
 drivers/md/raid1.c                                 |   29 +-
 drivers/md/raid10.c                                |    8 +-
 drivers/md/raid5.c                                 |  826 ++-
 drivers/md/raid5.h                                 |   59 +-
 drivers/media/Kconfig                              |   10 +-
 drivers/media/common/saa7146/saa7146_fops.c        |   19 +-
 drivers/media/common/saa7146/saa7146_vbi.c         |    4 +-
 drivers/media/common/siano/sms-cards.c             |    8 +-
 drivers/media/common/siano/sms-cards.h             |    3 +-
 drivers/media/common/siano/smscoreapi.c            |  164 +-
 drivers/media/common/siano/smscoreapi.h            |   32 +-
 drivers/media/common/siano/smsdvb-debugfs.c        |    6 +-
 drivers/media/common/siano/smsdvb-main.c           |   74 +-
 drivers/media/common/siano/smsir.c                 |   18 +-
 drivers/media/dvb-core/dmxdev.c                    |   11 +-
 drivers/media/dvb-core/dvb-usb-ids.h               |    3 +
 drivers/media/dvb-core/dvb_ca_en50221.c            |   30 +-
 drivers/media/dvb-core/dvb_frontend.c              |  124 +-
 drivers/media/dvb-core/dvb_net.c                   |    6 +-
 drivers/media/dvb-core/dvbdev.c                    |  144 +-
 drivers/media/dvb-core/dvbdev.h                    |   27 +
 drivers/media/dvb-frontends/Kconfig                |    8 +
 drivers/media/dvb-frontends/Makefile               |    1 +
 drivers/media/dvb-frontends/a8293.h                |    2 +-
 drivers/media/dvb-frontends/af9013.h               |    2 +-
 drivers/media/dvb-frontends/atbm8830.h             |    2 +-
 drivers/media/dvb-frontends/au8522.h               |    2 +-
 drivers/media/dvb-frontends/bcm3510.h              |    2 +-
 drivers/media/dvb-frontends/cx22700.h              |    2 +-
 drivers/media/dvb-frontends/cx22702.h              |    2 +-
 drivers/media/dvb-frontends/cx24110.h              |    2 +-
 drivers/media/dvb-frontends/cx24113.h              |    2 +-
 drivers/media/dvb-frontends/cx24116.h              |    2 +-
 drivers/media/dvb-frontends/cx24117.h              |    2 +-
 drivers/media/dvb-frontends/cx24123.h              |    2 +-
 drivers/media/dvb-frontends/cxd2820r.h             |    2 +-
 drivers/media/dvb-frontends/cxd2820r_c.c           |    2 +-
 drivers/media/dvb-frontends/cxd2820r_core.c        |    6 -
 drivers/media/dvb-frontends/cxd2820r_priv.h        |    2 -
 drivers/media/dvb-frontends/cxd2820r_t.c           |    2 +-
 drivers/media/dvb-frontends/cxd2820r_t2.c          |    2 +-
 drivers/media/dvb-frontends/dib0070.h              |    2 +-
 drivers/media/dvb-frontends/dib0090.h              |    2 +-
 drivers/media/dvb-frontends/dib3000.h              |    2 +-
 drivers/media/dvb-frontends/dib3000mc.h            |    2 +-
 drivers/media/dvb-frontends/dib7000m.h             |    2 +-
 drivers/media/dvb-frontends/dib7000p.h             |    2 +-
 drivers/media/dvb-frontends/dib8000.h              |    2 +-
 drivers/media/dvb-frontends/dib9000.h              |    2 +-
 drivers/media/dvb-frontends/drx39xyj/drx39xxj.h    |    2 +-
 drivers/media/dvb-frontends/drxd.h                 |    2 +-
 drivers/media/dvb-frontends/drxk.h                 |    2 +-
 drivers/media/dvb-frontends/ds3000.h               |    2 +-
 drivers/media/dvb-frontends/dvb-pll.h              |    2 +-
 drivers/media/dvb-frontends/dvb_dummy_fe.h         |    2 +-
 drivers/media/dvb-frontends/ec100.h                |    2 +-
 drivers/media/dvb-frontends/hd29l2.h               |    2 +-
 drivers/media/dvb-frontends/isl6405.h              |    2 +-
 drivers/media/dvb-frontends/isl6421.h              |    2 +-
 drivers/media/dvb-frontends/isl6423.h              |    2 +-
 drivers/media/dvb-frontends/itd1000.h              |    2 +-
 drivers/media/dvb-frontends/ix2505v.h              |    2 +-
 drivers/media/dvb-frontends/l64781.h               |    2 +-
 drivers/media/dvb-frontends/lg2160.h               |    2 +-
 drivers/media/dvb-frontends/lgdt3305.h             |    2 +-
 drivers/media/dvb-frontends/lgdt3306a.c            | 2144 ++++++++
 drivers/media/dvb-frontends/lgdt3306a.h            |   74 +
 drivers/media/dvb-frontends/lgdt330x.h             |    2 +-
 drivers/media/dvb-frontends/lgs8gl5.h              |    2 +-
 drivers/media/dvb-frontends/lgs8gxx.h              |    2 +-
 drivers/media/dvb-frontends/lnbh24.h               |    2 +-
 drivers/media/dvb-frontends/lnbp21.h               |    2 +-
 drivers/media/dvb-frontends/lnbp22.h               |    2 +-
 drivers/media/dvb-frontends/m88rs2000.h            |    2 +-
 drivers/media/dvb-frontends/mb86a16.h              |    2 +-
 drivers/media/dvb-frontends/mb86a20s.h             |    2 +-
 drivers/media/dvb-frontends/mn88472.h              |   12 +
 drivers/media/dvb-frontends/mn88473.h              |    6 +
 drivers/media/dvb-frontends/mt312.h                |    2 +-
 drivers/media/dvb-frontends/mt352.h                |    2 +-
 drivers/media/dvb-frontends/nxt200x.h              |    2 +-
 drivers/media/dvb-frontends/nxt6000.h              |    2 +-
 drivers/media/dvb-frontends/or51132.h              |    2 +-
 drivers/media/dvb-frontends/or51211.h              |    2 +-
 drivers/media/dvb-frontends/rtl2832.c              |    2 +-
 drivers/media/dvb-frontends/s5h1409.h              |    2 +-
 drivers/media/dvb-frontends/s5h1411.h              |    2 +-
 drivers/media/dvb-frontends/s5h1420.h              |    2 +-
 drivers/media/dvb-frontends/s5h1432.h              |    2 +-
 drivers/media/dvb-frontends/s921.h                 |    2 +-
 drivers/media/dvb-frontends/si2165.c               |    2 +-
 drivers/media/dvb-frontends/si2165.h               |    2 +-
 drivers/media/dvb-frontends/si21xx.h               |    2 +-
 drivers/media/dvb-frontends/sp2.c                  |    5 +-
 drivers/media/dvb-frontends/sp8870.h               |    2 +-
 drivers/media/dvb-frontends/sp887x.h               |    2 +-
 drivers/media/dvb-frontends/stb0899_drv.h          |    2 +-
 drivers/media/dvb-frontends/stb6000.h              |    2 +-
 drivers/media/dvb-frontends/stb6100.h              |    2 +-
 drivers/media/dvb-frontends/stv0288.h              |    2 +-
 drivers/media/dvb-frontends/stv0297.h              |    2 +-
 drivers/media/dvb-frontends/stv0299.h              |    2 +-
 drivers/media/dvb-frontends/stv0367.h              |    2 +-
 drivers/media/dvb-frontends/stv0900.h              |    2 +-
 drivers/media/dvb-frontends/stv090x.h              |    2 +-
 drivers/media/dvb-frontends/stv6110.h              |    2 +-
 drivers/media/dvb-frontends/stv6110x.h             |    2 +-
 drivers/media/dvb-frontends/tda1002x.h             |    4 +-
 drivers/media/dvb-frontends/tda10048.h             |    2 +-
 drivers/media/dvb-frontends/tda1004x.h             |    2 +-
 drivers/media/dvb-frontends/tda10071.h             |    2 +-
 drivers/media/dvb-frontends/tda10086.h             |    2 +-
 drivers/media/dvb-frontends/tda18271c2dd.h         |    2 +-
 drivers/media/dvb-frontends/tda665x.h              |    2 +-
 drivers/media/dvb-frontends/tda8083.h              |    2 +-
 drivers/media/dvb-frontends/tda8261.h              |    2 +-
 drivers/media/dvb-frontends/tda826x.h              |    2 +-
 drivers/media/dvb-frontends/ts2020.c               |  302 +-
 drivers/media/dvb-frontends/ts2020.h               |   27 +-
 drivers/media/dvb-frontends/tua6100.h              |    2 +-
 drivers/media/dvb-frontends/ves1820.h              |    2 +-
 drivers/media/dvb-frontends/ves1x93.h              |    2 +-
 drivers/media/dvb-frontends/zl10036.h              |    2 +-
 drivers/media/dvb-frontends/zl10039.h              |    2 +-
 drivers/media/dvb-frontends/zl10353.h              |    2 +-
 drivers/media/i2c/Kconfig                          |   11 +
 drivers/media/i2c/Makefile                         |    1 +
 drivers/media/i2c/ad9389b.c                        |   10 +-
 drivers/media/i2c/adv7180.c                        |   10 +-
 drivers/media/i2c/adv7343.c                        |    1 -
 drivers/media/i2c/adv7511.c                        |   26 +-
 drivers/media/i2c/adv7604.c                        |  945 ++--
 drivers/media/i2c/adv7842.c                        |    5 +-
 drivers/media/i2c/cx25840/cx25840-core.c           |   30 +
 drivers/media/i2c/cx25840/cx25840-core.h           |   11 +
 drivers/media/i2c/m5mols/m5mols_core.c             |   16 +-
 drivers/media/i2c/mt9m032.c                        |   34 +-
 drivers/media/i2c/mt9p031.c                        |   81 +-
 drivers/media/i2c/mt9t001.c                        |   36 +-
 drivers/media/i2c/mt9v032.c                        |  115 +-
 drivers/media/i2c/noon010pc30.c                    |   17 +-
 drivers/media/i2c/ov2659.c                         | 1509 ++++++
 drivers/media/i2c/ov7670.c                         |   37 +-
 drivers/media/i2c/ov9650.c                         |   16 +-
 drivers/media/i2c/s5c73m3/s5c73m3-core.c           |   72 +-
 drivers/media/i2c/s5c73m3/s5c73m3-spi.c            |    2 +-
 drivers/media/i2c/s5k4ecgx.c                       |   16 +-
 drivers/media/i2c/s5k5baf.c                        |   40 +-
 drivers/media/i2c/s5k6a3.c                         |   18 +-
 drivers/media/i2c/s5k6aa.c                         |   34 +-
 drivers/media/i2c/smiapp/smiapp-core.c             |  118 +-
 drivers/media/i2c/soc_camera/mt9m111.c             |    1 -
 drivers/media/i2c/soc_camera/ov2640.c              |  125 +-
 drivers/media/i2c/ths7303.c                        |    4 -
 drivers/media/i2c/ths8200.c                        |    1 -
 drivers/media/i2c/tvp514x.c                        |   13 +-
 drivers/media/i2c/tvp7002.c                        |   15 +-
 drivers/media/mmc/siano/smssdio.c                  |   17 +-
 drivers/media/pci/bt8xx/bt878.c                    |   12 -
 drivers/media/pci/bt8xx/bt878.h                    |   11 -
 drivers/media/pci/bt8xx/bttv-driver.c              |   73 +-
 drivers/media/pci/bt8xx/bttvp.h                    |    6 +-
 drivers/media/pci/cx18/cx18-alsa-main.c            |    2 +-
 drivers/media/pci/cx18/cx18-driver.h               |    3 +-
 drivers/media/pci/cx18/cx18-fileops.c              |   27 +-
 drivers/media/pci/cx18/cx18-ioctl.c                |   58 +-
 drivers/media/pci/cx18/cx18-streams.c              |   66 +-
 drivers/media/pci/cx18/cx18-streams.h              |    2 +-
 drivers/media/pci/cx23885/Kconfig                  |    1 -
 drivers/media/pci/cx23885/altera-ci.c              |    3 -
 drivers/media/pci/cx23885/altera-ci.h              |    2 +-
 drivers/media/pci/cx23885/cx23885-core.c           |    1 +
 drivers/media/pci/cx23885/cx23885-dvb.c            |   30 +-
 drivers/media/pci/cx23885/cx23885-video.c          |    1 -
 drivers/media/pci/cx88/cx88-blackbird.c            |   22 +-
 drivers/media/pci/cx88/cx88-core.c                 |   18 +-
 drivers/media/pci/cx88/cx88-mpeg.c                 |    3 +-
 drivers/media/pci/cx88/cx88-video.c                |   61 +-
 drivers/media/pci/cx88/cx88.h                      |   17 +-
 drivers/media/pci/ivtv/ivtv-alsa-main.c            |    2 +-
 drivers/media/pci/ivtv/ivtv-alsa-pcm.c             |    2 +-
 drivers/media/pci/ivtv/ivtv-driver.c               |    4 +-
 drivers/media/pci/ivtv/ivtv-driver.h               |    2 +-
 drivers/media/pci/ivtv/ivtv-fileops.c              |    2 +-
 drivers/media/pci/ivtv/ivtv-ioctl.c                |  159 +-
 drivers/media/pci/ivtv/ivtv-irq.c                  |    8 +-
 drivers/media/pci/ivtv/ivtv-streams.c              |  113 +-
 drivers/media/pci/ivtv/ivtv-streams.h              |    2 +-
 drivers/media/pci/meye/meye.c                      |   21 +-
 drivers/media/pci/meye/meye.h                      |    2 +-
 drivers/media/pci/saa7146/hexium_gemini.c          |    2 +-
 drivers/media/pci/saa7146/hexium_orion.c           |    2 +-
 drivers/media/pci/saa7146/mxb.c                    |    4 +-
 drivers/media/pci/saa7164/saa7164-core.c           |    4 +-
 drivers/media/pci/smipcie/Kconfig                  |    2 +-
 drivers/media/pci/smipcie/smipcie.c                |   12 +-
 drivers/media/pci/sta2x11/sta2x11_vip.c            |   35 +-
 drivers/media/pci/ttpci/av7110.h                   |    4 +-
 drivers/media/pci/ttpci/budget-av.c                |    2 +-
 drivers/media/platform/Kconfig                     |    4 +-
 drivers/media/platform/Makefile                    |    2 +
 drivers/media/platform/am437x/Kconfig              |    2 +-
 drivers/media/platform/am437x/am437x-vpfe.c        |   60 +-
 drivers/media/platform/am437x/am437x-vpfe.h        |    3 +-
 drivers/media/platform/blackfin/bfin_capture.c     |  348 +-
 drivers/media/platform/coda/Makefile               |    2 +
 drivers/media/platform/coda/coda-bit.c             |  205 +-
 drivers/media/platform/coda/coda-common.c          |  113 +-
 drivers/media/platform/coda/coda-jpeg.c            |    1 +
 drivers/media/platform/coda/coda.h                 |   18 +-
 drivers/media/platform/coda/trace.h                |  203 +
 drivers/media/platform/davinci/vpfe_capture.c      |   26 +-
 drivers/media/platform/davinci/vpif_capture.c      |   52 +-
 drivers/media/platform/davinci/vpif_capture.h      |    2 +-
 drivers/media/platform/davinci/vpif_display.c      |   49 +-
 drivers/media/platform/davinci/vpif_display.h      |    2 +-
 drivers/media/platform/exynos4-is/fimc-capture.c   |   22 +-
 drivers/media/platform/exynos4-is/fimc-isp.c       |   28 +-
 drivers/media/platform/exynos4-is/fimc-lite.c      |   33 +-
 drivers/media/platform/exynos4-is/mipi-csis.c      |   16 +-
 drivers/media/platform/m2m-deinterlace.c           |   21 +-
 drivers/media/platform/marvell-ccic/mcam-core.c    |   48 +-
 drivers/media/platform/omap/omap_vout.c            |    2 +-
 drivers/media/platform/omap/omap_vout_vrfb.c       |    1 +
 drivers/media/platform/omap/omap_vout_vrfb.h       |    4 +-
 drivers/media/platform/omap3isp/isp.c              |  563 +-
 drivers/media/platform/omap3isp/isp.h              |   43 +-
 drivers/media/platform/omap3isp/ispccdc.c          |  112 +-
 drivers/media/platform/omap3isp/ispccp2.c          |   68 +-
 drivers/media/platform/omap3isp/ispcsi2.c          |   56 +-
 drivers/media/platform/omap3isp/ispcsiphy.c        |   48 +-
 drivers/media/platform/omap3isp/isph3a_aewb.c      |    1 -
 drivers/media/platform/omap3isp/isph3a_af.c        |    1 -
 drivers/media/platform/omap3isp/isphist.c          |  127 +-
 drivers/media/platform/omap3isp/isppreview.c       |   70 +-
 drivers/media/platform/omap3isp/ispresizer.c       |   80 +-
 drivers/media/platform/omap3isp/ispstat.c          |    2 +-
 drivers/media/platform/omap3isp/ispstat.h          |    5 +-
 drivers/media/platform/omap3isp/ispvideo.c         |   20 +-
 drivers/media/platform/s3c-camif/camif-capture.c   |   18 +-
 drivers/media/platform/s5p-jpeg/jpeg-core.c        |   63 +-
 drivers/media/platform/s5p-jpeg/jpeg-core.h        |   12 +-
 drivers/media/platform/s5p-jpeg/jpeg-hw-s5p.c      |   32 -
 drivers/media/platform/s5p-jpeg/jpeg-hw-s5p.h      |    3 -
 drivers/media/platform/s5p-mfc/s5p_mfc.c           |    7 +
 drivers/media/platform/s5p-tv/mixer_video.c        |    2 +-
 drivers/media/platform/sh_vou.c                    |   30 +-
 drivers/media/platform/soc_camera/rcar_vin.c       |   15 -
 drivers/media/platform/soc_camera/sh_mobile_csi2.c |    1 -
 drivers/media/platform/soc_camera/soc_camera.c     |  111 +-
 drivers/media/platform/via-camera.c                |   15 +-
 drivers/media/platform/vim2m.c                     |   23 +-
 drivers/media/platform/vivid/vivid-core.c          |   93 +-
 drivers/media/platform/vivid/vivid-core.h          |    8 +-
 drivers/media/platform/vivid/vivid-ctrls.c         |    2 +-
 drivers/media/platform/vivid/vivid-kthread-cap.c   |  125 +-
 drivers/media/platform/vivid/vivid-sdr-cap.c       |   66 +-
 drivers/media/platform/vivid/vivid-tpg.c           | 1082 +++-
 drivers/media/platform/vivid/vivid-tpg.h           |  112 +-
 drivers/media/platform/vivid/vivid-vid-cap.c       |  180 +-
 drivers/media/platform/vivid/vivid-vid-common.c    |  378 +-
 drivers/media/platform/vivid/vivid-vid-out.c       |   85 +-
 drivers/media/platform/vsp1/vsp1_bru.c             |   42 +-
 drivers/media/platform/vsp1/vsp1_entity.c          |   16 +-
 drivers/media/platform/vsp1/vsp1_entity.h          |    4 +-
 drivers/media/platform/vsp1/vsp1_hsit.c            |   18 +-
 drivers/media/platform/vsp1/vsp1_lif.c             |   22 +-
 drivers/media/platform/vsp1/vsp1_lut.c             |   22 +-
 drivers/media/platform/vsp1/vsp1_rwpf.c            |   37 +-
 drivers/media/platform/vsp1/vsp1_rwpf.h            |   12 +-
 drivers/media/platform/vsp1/vsp1_sru.c             |   30 +-
 drivers/media/platform/vsp1/vsp1_uds.c             |   30 +-
 drivers/media/platform/xilinx/Kconfig              |   23 +
 drivers/media/platform/xilinx/Makefile             |    5 +
 drivers/media/platform/xilinx/xilinx-dma.c         |  766 +++
 drivers/media/platform/xilinx/xilinx-dma.h         |  109 +
 drivers/media/platform/xilinx/xilinx-tpg.c         |  931 ++++
 drivers/media/platform/xilinx/xilinx-vip.c         |  323 ++
 drivers/media/platform/xilinx/xilinx-vip.h         |  238 +
 drivers/media/platform/xilinx/xilinx-vipp.c        |  669 +++
 drivers/media/platform/xilinx/xilinx-vipp.h        |   49 +
 drivers/media/platform/xilinx/xilinx-vtc.c         |  380 ++
 drivers/media/platform/xilinx/xilinx-vtc.h         |   42 +
 drivers/media/radio/radio-wl1273.c                 |   27 +-
 drivers/media/radio/si470x/radio-si470x-common.c   |   14 +-
 drivers/media/radio/si4713/si4713.c                |   18 +-
 drivers/media/radio/wl128x/Kconfig                 |    2 +-
 drivers/media/radio/wl128x/fmdrv_v4l2.c            |   28 +-
 drivers/media/rc/img-ir/img-ir-core.c              |   31 +-
 drivers/media/rc/img-ir/img-ir.h                   |    2 +
 drivers/media/rc/ir-hix5hd2.c                      |    8 -
 drivers/media/tuners/Kconfig                       |    8 -
 drivers/media/tuners/Makefile                      |    1 -
 drivers/media/tuners/fc0011.h                      |    2 +-
 drivers/media/tuners/fc0012.h                      |    2 +-
 drivers/media/tuners/fc0013.h                      |    2 +-
 drivers/media/tuners/fc2580.h                      |    2 +-
 drivers/media/tuners/m88ts2022.c                   |  579 ---
 drivers/media/tuners/m88ts2022.h                   |   54 -
 drivers/media/tuners/m88ts2022_priv.h              |   35 -
 drivers/media/tuners/max2165.h                     |    2 +-
 drivers/media/tuners/mc44s803.h                    |    2 +-
 drivers/media/tuners/mt2060.h                      |    2 +-
 drivers/media/tuners/mt2063.h                      |    2 +-
 drivers/media/tuners/mt20xx.h                      |    2 +-
 drivers/media/tuners/mt2131.h                      |    2 +-
 drivers/media/tuners/mt2266.h                      |    2 +-
 drivers/media/tuners/mxl5005s.h                    |    2 +-
 drivers/media/tuners/mxl5007t.h                    |    2 +-
 drivers/media/tuners/qt1010.h                      |    2 +-
 drivers/media/tuners/r820t.c                       |   29 +-
 drivers/media/tuners/r820t.h                       |    2 +-
 drivers/media/tuners/si2157.c                      |   25 +-
 drivers/media/tuners/si2157_priv.h                 |    1 +
 drivers/media/tuners/tda18218.h                    |    2 +-
 drivers/media/tuners/tda18271.h                    |    2 +-
 drivers/media/tuners/tda827x.h                     |    2 +-
 drivers/media/tuners/tda8290.h                     |    2 +-
 drivers/media/tuners/tda9887.h                     |    2 +-
 drivers/media/tuners/tea5761.h                     |    2 +-
 drivers/media/tuners/tea5767.h                     |    2 +-
 drivers/media/tuners/tua9001.h                     |    2 +-
 drivers/media/tuners/tuner-simple.h                |    2 +-
 drivers/media/tuners/tuner-xc2028.h                |    2 +-
 drivers/media/tuners/xc4000.h                      |    2 +-
 drivers/media/tuners/xc5000.c                      |    5 +-
 drivers/media/tuners/xc5000.h                      |    2 +-
 drivers/media/usb/au0828/au0828-video.c            |  104 +-
 drivers/media/usb/au0828/au0828.h                  |    4 +-
 drivers/media/usb/cx231xx/Kconfig                  |    1 +
 drivers/media/usb/cx231xx/cx231xx-417.c            |   33 +-
 drivers/media/usb/cx231xx/cx231xx-cards.c          |  144 +-
 drivers/media/usb/cx231xx/cx231xx-core.c           |   13 +-
 drivers/media/usb/cx231xx/cx231xx-dvb.c            |   71 +
 drivers/media/usb/cx231xx/cx231xx-video.c          |  176 +-
 drivers/media/usb/cx231xx/cx231xx.h                |   21 +-
 drivers/media/usb/dvb-usb-v2/Kconfig               |    2 +-
 drivers/media/usb/dvb-usb-v2/dvb_usb.h             |    1 +
 drivers/media/usb/dvb-usb-v2/dvb_usb_core.c        |   58 +
 drivers/media/usb/dvb-usb-v2/dvbsky.c              |   26 +-
 drivers/media/usb/dvb-usb-v2/rtl28xxu.c            |    8 +-
 drivers/media/usb/dvb-usb/Kconfig                  |    5 +-
 drivers/media/usb/dvb-usb/cxusb.c                  |  155 +-
 drivers/media/usb/dvb-usb/dib0700_core.c           |    3 -
 drivers/media/usb/dvb-usb/dib0700_devices.c        |    3 -
 drivers/media/usb/dvb-usb/dvb-usb-dvb.c            |   69 +-
 drivers/media/usb/dvb-usb/dw2102.c                 |  192 +-
 drivers/media/usb/em28xx/Kconfig                   |    2 +-
 drivers/media/usb/em28xx/em28xx-camera.c           |    2 +-
 drivers/media/usb/em28xx/em28xx-cards.c            |   13 +-
 drivers/media/usb/em28xx/em28xx-dvb.c              |   14 +-
 drivers/media/usb/em28xx/em28xx-video.c            |  119 +-
 drivers/media/usb/em28xx/em28xx.h                  |    7 +-
 drivers/media/usb/gspca/ov534.c                    |   11 +-
 drivers/media/usb/gspca/topro.c                    |    4 +-
 drivers/media/usb/hdpvr/hdpvr-core.c               |   10 +-
 drivers/media/usb/hdpvr/hdpvr-video.c              |   19 +-
 drivers/media/usb/hdpvr/hdpvr.h                    |    2 +-
 drivers/media/usb/pvrusb2/pvrusb2-v4l2.c           |   84 +-
 drivers/media/usb/siano/smsusb.c                   |  136 +-
 drivers/media/usb/stk1160/stk1160-v4l.c            |   17 +-
 drivers/media/usb/stkwebcam/stk-webcam.c           |    6 +-
 drivers/media/usb/tm6000/tm6000-video.c            |   59 +-
 drivers/media/usb/tm6000/tm6000.h                  |    4 +-
 drivers/media/usb/usbvision/usbvision-video.c      |   94 +-
 drivers/media/usb/usbvision/usbvision.h            |    4 +-
 drivers/media/usb/uvc/uvc_driver.c                 |   30 +-
 drivers/media/usb/uvc/uvc_queue.c                  |   15 +-
 drivers/media/usb/uvc/uvc_v4l2.c                   |   70 +-
 drivers/media/usb/uvc/uvcvideo.h                   |    2 +-
 drivers/media/v4l2-core/tuner-core.c               |   22 +
 drivers/media/v4l2-core/v4l2-clk.c                 |   81 +-
 drivers/media/v4l2-core/v4l2-ctrls.c               |   22 +-
 drivers/media/v4l2-core/v4l2-dev.c                 |   55 +-
 drivers/media/v4l2-core/v4l2-device.c              |    5 +-
 drivers/media/v4l2-core/v4l2-dv-timings.c          |    6 +-
 drivers/media/v4l2-core/v4l2-ioctl.c               |   12 +-
 drivers/media/v4l2-core/v4l2-mem2mem.c             |    4 +-
 drivers/media/v4l2-core/v4l2-of.c                  |  102 +-
 drivers/media/v4l2-core/v4l2-subdev.c              |   33 +-
 drivers/media/v4l2-core/videobuf2-core.c           |   61 +-
 drivers/media/v4l2-core/videobuf2-dma-contig.c     |    8 +-
 drivers/media/v4l2-core/videobuf2-dma-sg.c         |    8 +-
 drivers/media/v4l2-core/videobuf2-vmalloc.c        |    8 +-
 drivers/memory/Kconfig                             |    9 +
 drivers/memory/Makefile                            |    1 +
 drivers/memory/jz4780-nemc.c                       |  391 ++
 drivers/memory/omap-gpmc.c                         |  358 +-
 drivers/memstick/core/mspro_block.c                |    3 +-
 drivers/mfd/cros_ec.c                              |   19 +-
 drivers/misc/bh1780gli.c                           |    2 +
 drivers/misc/carma/carma-fpga-program.c            |   12 +-
 drivers/misc/carma/carma-fpga.c                    |    2 +-
 drivers/misc/lis3lv02d/lis3lv02d.c                 |   56 +-
 drivers/misc/lis3lv02d/lis3lv02d_i2c.c             |    2 +-
 drivers/misc/lis3lv02d/lis3lv02d_spi.c             |    2 +-
 drivers/misc/mei/Makefile                          |    3 +
 drivers/misc/mei/amthif.c                          |  423 +-
 drivers/misc/mei/bus.c                             |  105 +-
 drivers/misc/mei/client.c                          |  478 +-
 drivers/misc/mei/client.h                          |   42 +-
 drivers/misc/mei/debugfs.c                         |   21 +-
 drivers/misc/mei/hbm.c                             |    8 +-
 drivers/misc/mei/hw-me.c                           |  170 +-
 drivers/misc/mei/hw-me.h                           |    4 +-
 drivers/misc/mei/hw-txe.c                          |    2 +-
 drivers/misc/mei/init.c                            |    2 +-
 drivers/misc/mei/interrupt.c                       |  171 +-
 drivers/misc/mei/main.c                            |  146 +-
 drivers/misc/mei/mei-trace.c                       |   25 +
 drivers/misc/mei/mei-trace.h                       |   74 +
 drivers/misc/mei/mei_dev.h                         |   40 +-
 drivers/misc/mei/nfc.c                             |   43 +-
 drivers/misc/mei/pci-me.c                          |    4 +-
 drivers/misc/mei/pci-txe.c                         |    4 +-
 drivers/misc/mei/wd.c                              |   36 +-
 drivers/misc/mic/host/mic_boot.c                   |   14 +-
 drivers/misc/mic/host/mic_intr.c                   |    2 -
 drivers/misc/sram.c                                |   19 +-
 drivers/misc/tifm_7xx1.c                           |    5 +-
 drivers/misc/vmw_vmci/vmci_driver.c                |    2 +-
 drivers/misc/vmw_vmci/vmci_host.c                  |    6 +
 drivers/misc/vmw_vmci/vmci_queue_pair.c            |   37 +-
 drivers/mmc/card/block.c                           |   38 +-
 drivers/mmc/card/mmc_test.c                        |   18 +-
 drivers/mmc/core/bus.c                             |   41 +-
 drivers/mmc/core/pwrseq.c                          |    2 +-
 drivers/mmc/host/Kconfig                           |    8 -
 drivers/mmc/host/Makefile                          |    1 -
 drivers/mmc/host/msm_sdcc.c                        | 1474 ------
 drivers/mmc/host/msm_sdcc.h                        |  256 -
 drivers/mmc/host/mxcmmc.c                          |    2 +-
 drivers/mmc/host/sh_mmcif.c                        |   13 +-
 drivers/mmc/host/sh_mobile_sdhi.c                  |   26 +-
 drivers/mmc/host/tmio_mmc.h                        |    4 -
 drivers/mmc/host/tmio_mmc_dma.c                    |   10 +-
 drivers/mtd/Kconfig                                |   13 +
 drivers/mtd/chips/cfi_cmdset_0020.c                |   30 +-
 drivers/mtd/devices/block2mtd.c                    |   58 +-
 drivers/mtd/devices/docg3.c                        |   11 +-
 drivers/mtd/devices/m25p80.c                       |   21 +-
 drivers/mtd/maps/Kconfig                           |    2 +-
 drivers/mtd/maps/sa1100-flash.c                    |    4 +-
 drivers/mtd/maps/ts5500_flash.c                    |    2 +-
 drivers/mtd/mtd_blkdevs.c                          |    3 -
 drivers/mtd/mtdcore.c                              |   52 +-
 drivers/mtd/mtdpart.c                              |   68 +-
 drivers/mtd/nand/atmel_nand.c                      |   26 +-
 drivers/mtd/nand/atmel_nand_ecc.h                  |    3 +
 drivers/mtd/nand/atmel_nand_nfc.h                  |    1 +
 drivers/mtd/nand/denali.c                          |    6 +-
 drivers/mtd/nand/fsl_ifc_nand.c                    |    4 +-
 drivers/mtd/nand/fsmc_nand.c                       |    7 +-
 drivers/mtd/nand/gpmi-nand/gpmi-nand.c             |   16 +-
 drivers/mtd/nand/mxc_nand.c                        |  146 +-
 drivers/mtd/nand/nand_base.c                       |   41 +-
 drivers/mtd/nand/pxa3xx_nand.c                     |   48 +-
 drivers/mtd/nand/s3c2410.c                         |    3 -
 drivers/mtd/nand/sh_flctl.c                        |    2 -
 drivers/mtd/onenand/onenand_base.c                 |   12 +-
 drivers/mtd/spi-nor/fsl-quadspi.c                  |   11 +-
 drivers/mtd/spi-nor/spi-nor.c                      |   61 +-
 drivers/mtd/tests/mtd_nandecctest.c                |    6 +
 drivers/mtd/tests/mtd_test.h                       |   12 +
 drivers/mtd/tests/nandbiterrs.c                    |    4 +
 drivers/mtd/tests/oobtest.c                        |   90 +-
 drivers/mtd/tests/pagetest.c                       |   10 +-
 drivers/mtd/tests/readtest.c                       |    5 +-
 drivers/mtd/tests/speedtest.c                      |   38 +-
 drivers/mtd/tests/stresstest.c                     |    9 +-
 drivers/mtd/tests/subpagetest.c                    |   29 +-
 drivers/mtd/tests/torturetest.c                    |   23 +-
 drivers/mtd/ubi/attach.c                           |   73 +-
 drivers/mtd/ubi/build.c                            |   35 +-
 drivers/mtd/ubi/cdev.c                             |    2 +-
 drivers/mtd/ubi/debug.c                            |  100 +-
 drivers/mtd/ubi/debug.h                            |   12 +
 drivers/mtd/ubi/eba.c                              |   54 +-
 drivers/mtd/ubi/fastmap-wl.c                       |  362 ++
 drivers/mtd/ubi/fastmap.c                          |  443 +-
 drivers/mtd/ubi/io.c                               |    6 +
 drivers/mtd/ubi/kapi.c                             |    2 +-
 drivers/mtd/ubi/ubi-media.h                        |    2 -
 drivers/mtd/ubi/ubi.h                              |   85 +-
 drivers/mtd/ubi/wl.c                               |  587 +--
 drivers/mtd/ubi/wl.h                               |   28 +
 drivers/net/bonding/bond_main.c                    |    2 +
 drivers/net/bonding/bond_procfs.c                  |    1 +
 drivers/net/bonding/bonding_priv.h                 |   25 +
 drivers/net/can/Kconfig                            |    2 +-
 drivers/net/can/usb/kvaser_usb.c                   |    2 +-
 drivers/net/dsa/mv88e6xxx.c                        |   14 +-
 drivers/net/ethernet/8390/etherh.c                 |    2 +-
 drivers/net/ethernet/altera/altera_msgdmahw.h      |    6 +-
 drivers/net/ethernet/altera/altera_tse_main.c      |   46 +-
 drivers/net/ethernet/amd/Kconfig                   |    2 +-
 drivers/net/ethernet/apple/bmac.c                  |   30 +-
 drivers/net/ethernet/apple/mace.c                  |   44 +-
 drivers/net/ethernet/arc/Kconfig                   |    5 +-
 drivers/net/ethernet/broadcom/b44.c                |    2 +-
 drivers/net/ethernet/broadcom/bgmac.c              |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |  137 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   58 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   17 +
 drivers/net/ethernet/broadcom/tg3.c                |    4 +-
 drivers/net/ethernet/cadence/macb.c                |    4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   21 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.h |    2 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |   15 +-
 drivers/net/ethernet/hisilicon/hip04_eth.c         |   18 +-
 drivers/net/ethernet/ibm/ehea/ehea_main.c          |    6 +-
 drivers/net/ethernet/ibm/emac/core.c               |   12 +-
 drivers/net/ethernet/ibm/ibmveth.c                 |    4 +-
 drivers/net/ethernet/intel/i40e/i40e_common.c      |   65 +
 drivers/net/ethernet/intel/i40e/i40e_dcb.c         |    6 +-
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c     |   45 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     |   29 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c        |   16 +-
 drivers/net/ethernet/intel/i40e/i40e_nvm.c         |    3 +-
 drivers/net/ethernet/intel/i40e/i40e_prototype.h   |    5 +
 drivers/net/ethernet/intel/i40e/i40e_type.h        |    1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  244 +-
 drivers/net/ethernet/intel/i40evf/i40e_type.h      |    1 +
 drivers/net/ethernet/intel/i40evf/i40evf.h         |    1 -
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |    9 +-
 .../net/ethernet/intel/i40evf/i40evf_virtchnl.c    |   42 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |   16 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   42 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |   29 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |    2 +
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/main.c          |   31 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    1 +
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |   10 +-
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c   |   38 +-
 drivers/net/ethernet/qualcomm/qca_spi.c            |    1 -
 drivers/net/ethernet/rocker/rocker.c               |    1 +
 drivers/net/ethernet/sfc/efx.c                     |    4 +-
 drivers/net/ethernet/sfc/selftest.c                |    2 +-
 drivers/net/ethernet/sfc/siena.c                   |    3 +-
 drivers/net/ethernet/stmicro/stmmac/common.h       |    5 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h    |   51 +
 .../net/ethernet/stmicro/stmmac/dwmac1000_core.c   |    5 +-
 .../net/ethernet/stmicro/stmmac/dwmac1000_dma.c    |   26 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac100_dma.c |    2 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   22 +-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |    4 +
 drivers/net/ethernet/tile/tilegx.c                 |    4 +-
 drivers/net/ifb.c                                  |    2 +-
 drivers/net/macvtap.c                              |    4 +-
 drivers/net/phy/mdio-gpio.c                        |   14 +-
 drivers/net/phy/mdio-mux-gpio.c                    |   60 +-
 drivers/net/ppp/ppp_generic.c                      |    1 +
 drivers/net/ppp/ppp_mppe.c                         |   36 +-
 drivers/net/ppp/pppoe.c                            |    3 +
 drivers/net/tun.c                                  |    2 -
 drivers/net/vxlan.c                                |    6 +-
 drivers/net/wireless/ath/ath.h                     |    2 +
 drivers/net/wireless/ath/ath10k/Makefile           |    4 +-
 drivers/net/wireless/ath/ath10k/core.c             |  161 +-
 drivers/net/wireless/ath/ath10k/core.h             |   48 +-
 drivers/net/wireless/ath/ath10k/debug.c            |  127 +-
 drivers/net/wireless/ath/ath10k/htc.c              |   50 +-
 drivers/net/wireless/ath/ath10k/htt.c              |   98 +
 drivers/net/wireless/ath/ath10k/htt.h              |  132 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |  194 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |   34 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   53 +-
 drivers/net/wireless/ath/ath10k/mac.c              | 2826 +++++++---
 drivers/net/wireless/ath/ath10k/mac.h              |   29 +
 drivers/net/wireless/ath/ath10k/p2p.c              |  156 +
 drivers/net/wireless/ath/ath10k/p2p.h              |   28 +
 drivers/net/wireless/ath/ath10k/pci.c              |  101 +-
 drivers/net/wireless/ath/ath10k/rx_desc.h          |   22 +
 drivers/net/wireless/ath/ath10k/thermal.c          |  134 +-
 drivers/net/wireless/ath/ath10k/thermal.h          |   10 +-
 drivers/net/wireless/ath/ath10k/trace.h            |   22 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    9 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |  194 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |  579 ++-
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |  168 +
 drivers/net/wireless/ath/ath10k/wmi.c              |  272 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |  230 +-
 drivers/net/wireless/ath/ath10k/wow.c              |  321 ++
 drivers/net/wireless/ath/ath10k/wow.h              |   40 +
 drivers/net/wireless/ath/ath9k/common-spectral.c   |  740 ++-
 drivers/net/wireless/ath/ath9k/common-spectral.h   |   35 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    2 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c    |   72 +-
 drivers/net/wireless/ath/dfs_pattern_detector.h    |    4 +
 drivers/net/wireless/ath/dfs_pri_detector.c        |    4 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   18 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |  202 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/feature.c  |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/feature.h  |    4 +
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |  189 +-
 drivers/net/wireless/brcm80211/brcmfmac/firmware.h |    6 +
 drivers/net/wireless/brcm80211/brcmfmac/pcie.c     |   27 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c     |   11 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |    9 +-
 .../net/wireless/brcm80211/include/brcm_hw_ids.h   |    3 +
 drivers/net/wireless/iwlwifi/Kconfig               |   12 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   23 +
 drivers/net/wireless/iwlwifi/iwl-config.h          |   44 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    3 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |    7 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |   56 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |    7 -
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   15 -
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  157 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  109 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |    9 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   20 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |    2 -
 drivers/net/wireless/iwlwifi/mvm/scan.c            |  988 ++--
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   40 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   77 +-
 drivers/net/wireless/mwifiex/join.c                |   12 +-
 drivers/net/wireless/mwifiex/main.c                |   11 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    2 +
 drivers/net/wireless/mwifiex/tdls.c                |    2 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |    2 +-
 drivers/net/wireless/mwifiex/util.c                |    7 +-
 drivers/net/wireless/mwifiex/wmm.c                 |    9 +
 drivers/net/wireless/rtlwifi/rtl8192ee/fw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/fw.c        |    2 +-
 drivers/net/wireless/ti/wilink_platform_data.c     |   25 -
 drivers/net/wireless/ti/wl12xx/main.c              |   63 +-
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |   28 +
 drivers/net/wireless/ti/wl18xx/main.c              |   71 +-
 drivers/net/wireless/ti/wl18xx/reg.h               |    1 +
 drivers/net/wireless/ti/wlcore/boot.c              |    1 -
 drivers/net/wireless/ti/wlcore/debugfs.c           |    2 +-
 drivers/net/wireless/ti/wlcore/main.c              |   55 +-
 drivers/net/wireless/ti/wlcore/sdio.c              |   63 +-
 drivers/net/wireless/ti/wlcore/spi.c               |    6 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    5 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |    6 +-
 drivers/net/xen-netback/netback.c                  |    4 +-
 drivers/net/xen-netfront.c                         |   11 +-
 drivers/of/Kconfig                                 |   13 +-
 drivers/of/Makefile                                |    5 +-
 drivers/of/base.c                                  |   69 +-
 drivers/of/fdt.c                                   |   24 +-
 drivers/of/of_net.c                                |   29 +-
 drivers/of/unittest-data/.gitignore                |    2 +
 drivers/of/unittest-data/Makefile                  |    7 +
 drivers/of/unittest-data/tests-overlay.dtsi        |  108 +-
 drivers/of/unittest.c                              |  806 +--
 drivers/oprofile/buffer_sync.c                     |   30 +-
 drivers/oprofile/oprofilefs.c                      |   16 +-
 drivers/parisc/ccio-dma.c                          |   60 +-
 drivers/parisc/iommu-helpers.h                     |   26 +-
 drivers/parisc/sba_iommu.c                         |   93 +-
 drivers/pci/hotplug/rpadlpar_core.c                |    2 +-
 drivers/pci/iov.c                                  |  155 +-
 drivers/pci/pci.h                                  |    2 +
 drivers/pci/setup-bus.c                            |   95 +-
 drivers/pci/xen-pcifront.c                         |    5 +-
 drivers/pcmcia/Kconfig                             |    1 +
 drivers/pcmcia/at91_cf.c                           |   13 +-
 drivers/pcmcia/omap_cf.c                           |    4 +-
 drivers/pcmcia/pd6729.c                            |    8 +-
 drivers/pcmcia/soc_common.c                        |    5 +-
 drivers/pcmcia/yenta_socket.c                      |    8 +-
 drivers/pinctrl/Kconfig                            |    5 +-
 drivers/pinctrl/mediatek/Kconfig                   |    3 +
 drivers/pinctrl/nomadik/Kconfig                    |    2 +-
 drivers/platform/Kconfig                           |    3 +
 drivers/platform/Makefile                          |    1 +
 drivers/platform/chrome/Kconfig                    |   26 +-
 drivers/platform/chrome/Makefile                   |    3 +
 drivers/platform/chrome/chromeos_laptop.c          |   35 +-
 drivers/platform/chrome/cros_ec_dev.c              |  274 +
 drivers/platform/chrome/cros_ec_dev.h              |   53 +
 drivers/platform/chrome/cros_ec_lightbar.c         |  367 ++
 drivers/platform/chrome/cros_ec_lpc.c              |  319 ++
 drivers/platform/chrome/cros_ec_sysfs.c            |  271 +
 drivers/platform/mips/Kconfig                      |   30 +
 drivers/platform/mips/Makefile                     |    2 +
 drivers/platform/mips/acpi_init.c                  |  150 +
 drivers/platform/mips/cpu_hwmon.c                  |  207 +
 drivers/platform/x86/Kconfig                       |    1 +
 drivers/platform/x86/apple-gmux.c                  |   48 +-
 drivers/platform/x86/dell-laptop.c                 | 1089 +++-
 drivers/platform/x86/intel_oaktrail.c              |    2 +-
 drivers/platform/x86/thinkpad_acpi.c               |  320 +-
 drivers/platform/x86/toshiba_acpi.c                |  256 +-
 drivers/platform/x86/toshiba_bluetooth.c           |  133 +-
 drivers/platform/x86/wmi.c                         |    5 +-
 drivers/powercap/intel_rapl.c                      |    1 +
 drivers/ps3/ps3-lpm.c                              |    4 +-
 drivers/pwm/core.c                                 |    2 +-
 drivers/pwm/pwm-atmel-hlcdc.c                      |    4 +
 drivers/pwm/pwm-mxs.c                              |    8 +-
 drivers/pwm/pwm-pca9685.c                          |    2 +-
 drivers/pwm/pwm-samsung.c                          |   32 +-
 drivers/remoteproc/da8xx_remoteproc.c              |    1 +
 drivers/remoteproc/omap_remoteproc.c               |    2 +
 drivers/remoteproc/remoteproc_core.c               |   15 +-
 drivers/remoteproc/ste_modem_rproc.c               |    1 +
 drivers/rtc/Kconfig                                |   16 +-
 drivers/rtc/Makefile                               |    1 +
 drivers/rtc/class.c                                |    6 +-
 drivers/rtc/hctosys.c                              |    6 +-
 drivers/rtc/interface.c                            |    5 +-
 drivers/rtc/rtc-ab-b5ze-s3.c                       |    2 +-
 drivers/rtc/rtc-at91rm9200.c                       |    4 +-
 drivers/rtc/rtc-cmos.c                             |   42 +-
 drivers/rtc/rtc-da9052.c                           |   97 +-
 drivers/rtc/rtc-digicolor.c                        |  227 +
 drivers/rtc/rtc-ds1305.c                           |    6 +-
 drivers/rtc/rtc-ds1374.c                           |    8 +-
 drivers/rtc/rtc-ds1685.c                           |    9 +-
 drivers/rtc/rtc-ds3232.c                           |    6 +-
 drivers/rtc/rtc-efi-platform.c                     |    3 +
 drivers/rtc/rtc-em3027.c                           |   11 +
 drivers/rtc/rtc-hym8563.c                          |   12 +-
 drivers/rtc/rtc-m41t80.c                           |    6 +-
 drivers/rtc/rtc-max77686.c                         |    6 +-
 drivers/rtc/rtc-max8997.c                          |    8 +-
 drivers/rtc/rtc-mrst.c                             |   16 +-
 drivers/rtc/rtc-msm6242.c                          |    4 +-
 drivers/rtc/rtc-omap.c                             |   68 +-
 drivers/rtc/rtc-opal.c                             |    3 +-
 drivers/rtc/rtc-pcf8563.c                          |    7 +-
 drivers/rtc/rtc-s3c.c                              |  193 +-
 drivers/rtc/rtc-s5m.c                              |   34 +-
 drivers/rtc/rtc-stmp3xxx.c                         |   66 +-
 drivers/rtc/rtc-tegra.c                            |    4 +-
 drivers/rtc/rtc-twl.c                              |    9 +-
 drivers/rtc/rtc-x1205.c                            |    4 +-
 drivers/s390/block/dasd.c                          |   42 +-
 drivers/s390/block/dasd_eckd.c                     |    3 +-
 drivers/s390/char/sclp_cmd.c                       |   48 +-
 drivers/s390/cio/blacklist.c                       |   12 +-
 drivers/s390/kvm/virtio_ccw.c                      |   10 +-
 drivers/sbus/char/bbc_envctrl.c                    |    3 +-
 drivers/sbus/char/envctrl.c                        |    7 +-
 drivers/scsi/NCR5380.c                             |   10 +-
 drivers/scsi/aacraid/aachba.c                      |  410 +-
 drivers/scsi/aacraid/aacraid.h                     |  106 +-
 drivers/scsi/aacraid/commctrl.c                    |   10 +-
 drivers/scsi/aacraid/comminit.c                    |  106 +-
 drivers/scsi/aacraid/commsup.c                     |   96 +-
 drivers/scsi/aacraid/dpcsup.c                      |   13 +-
 drivers/scsi/aacraid/linit.c                       |   61 +-
 drivers/scsi/aacraid/rx.c                          |   14 +-
 drivers/scsi/aacraid/src.c                         |  438 +-
 drivers/scsi/aha1542.c                             | 1687 ++----
 drivers/scsi/aha1542.h                             |  136 +-
 drivers/scsi/aic7xxx/aic79xx_core.c                |    3 +-
 drivers/scsi/aic7xxx/aic79xx_osm.c                 |    3 +-
 drivers/scsi/aic7xxx/aic7xxx_core.c                |   10 +-
 drivers/scsi/aic7xxx/aic7xxx_osm.c                 |    3 +-
 drivers/scsi/am53c974.c                            |    6 +-
 drivers/scsi/atari_NCR5380.c                       |    2 +-
 drivers/scsi/atari_scsi.c                          |    1 -
 drivers/scsi/bfa/bfad.c                            |   22 +-
 drivers/scsi/g_NCR5380.c                           |    8 +-
 drivers/scsi/hpsa.c                                |    6 +-
 drivers/scsi/ipr.c                                 |  319 +-
 drivers/scsi/ipr.h                                 |   15 +-
 drivers/scsi/lpfc/lpfc.h                           |    5 +-
 drivers/scsi/lpfc/lpfc_attr.c                      |   25 +-
 drivers/scsi/lpfc/lpfc_bsg.c                       |    4 +-
 drivers/scsi/lpfc/lpfc_bsg.h                       |    3 +-
 drivers/scsi/lpfc/lpfc_crtn.h                      |    4 +-
 drivers/scsi/lpfc/lpfc_ct.c                        |  738 ++-
 drivers/scsi/lpfc/lpfc_debugfs.c                   |    2 +-
 drivers/scsi/lpfc/lpfc_els.c                       |   19 +-
 drivers/scsi/lpfc/lpfc_hbadisc.c                   |   74 +-
 drivers/scsi/lpfc/lpfc_hw.h                        |  208 +-
 drivers/scsi/lpfc/lpfc_hw4.h                       |    8 +-
 drivers/scsi/lpfc/lpfc_init.c                      |  264 +-
 drivers/scsi/lpfc/lpfc_mbox.c                      |    2 +-
 drivers/scsi/lpfc/lpfc_nportdisc.c                 |   29 +-
 drivers/scsi/lpfc/lpfc_scsi.c                      |   83 +-
 drivers/scsi/lpfc/lpfc_scsi.h                      |    2 +-
 drivers/scsi/lpfc/lpfc_sli.c                       |   72 +-
 drivers/scsi/lpfc/lpfc_sli.h                       |    3 +-
 drivers/scsi/lpfc/lpfc_sli4.h                      |    4 +-
 drivers/scsi/lpfc/lpfc_version.h                   |    6 +-
 drivers/scsi/mac53c94.c                            |   10 +-
 drivers/scsi/mac_scsi.c                            |    1 -
 drivers/scsi/megaraid/megaraid_sas_fusion.c        |    9 +-
 drivers/scsi/mesh.c                                |   14 +-
 drivers/scsi/mvsas/mv_sas.c                        |    5 +-
 drivers/scsi/qla2xxx/Kconfig                       |    3 +
 drivers/scsi/qla2xxx/qla_dbg.c                     |    6 +-
 drivers/scsi/qla2xxx/qla_def.h                     |   16 +-
 drivers/scsi/qla2xxx/qla_init.c                    |   75 +-
 drivers/scsi/qla2xxx/qla_isr.c                     |   17 +-
 drivers/scsi/qla2xxx/qla_mbx.c                     |   31 +-
 drivers/scsi/qla2xxx/qla_mid.c                     |   22 +-
 drivers/scsi/qla2xxx/qla_os.c                      |    3 +
 drivers/scsi/qla2xxx/qla_sup.c                     |   11 +-
 drivers/scsi/qla2xxx/qla_target.c                  |    2 +-
 drivers/scsi/qla2xxx/qla_tmpl.c                    |   15 +-
 drivers/scsi/qla2xxx/qla_version.h                 |    2 +-
 drivers/scsi/qla2xxx/tcm_qla2xxx.c                 |  174 +-
 drivers/scsi/qla2xxx/tcm_qla2xxx.h                 |    1 +
 drivers/scsi/scsi.c                                |   20 +-
 drivers/scsi/scsi_scan.c                           |    7 +-
 drivers/scsi/scsi_transport_fc.c                   |    1 +
 drivers/scsi/sd.c                                  |   64 +-
 drivers/scsi/sd_dif.c                              |    2 +-
 drivers/scsi/storvsc_drv.c                         |  232 +-
 drivers/scsi/sun3_scsi.c                           |    1 -
 drivers/scsi/ufs/ufs-qcom.c                        |   36 +-
 drivers/scsi/ufs/ufs-qcom.h                        |   26 +
 drivers/scsi/ufs/ufshcd.c                          |   35 +
 drivers/scsi/ufs/ufshcd.h                          |    9 +
 drivers/scsi/xen-scsifront.c                       |  219 +-
 drivers/soc/Kconfig                                |    1 +
 drivers/soc/Makefile                               |    1 +
 drivers/soc/mediatek/Kconfig                       |   11 +
 drivers/soc/mediatek/Makefile                      |    1 +
 drivers/soc/mediatek/mtk-pmic-wrap.c               |  975 ++++
 drivers/soc/qcom/Kconfig                           |    1 +
 drivers/soc/qcom/qcom_gsbi.c                       |  152 +
 drivers/spi/spi-rspi.c                             |    1 -
 drivers/spi/spi-sh-msiof.c                         |    1 -
 drivers/spmi/Kconfig                               |    1 -
 drivers/spmi/spmi-pmic-arb.c                       |  319 +-
 drivers/spmi/spmi.c                                |    9 +-
 drivers/ssb/Kconfig                                |    1 +
 drivers/ssb/driver_chipcommon_pmu.c                |    2 +-
 drivers/ssb/driver_mipscore.c                      |    2 +-
 drivers/staging/android/ashmem.c                   |    2 +-
 drivers/staging/android/ion/ion.c                  |    9 +-
 drivers/staging/comedi/drivers/serial2002.c        |   18 +-
 drivers/staging/lustre/lustre/Kconfig              |    1 +
 drivers/staging/lustre/lustre/llite/dcache.c       |   14 +-
 drivers/staging/lustre/lustre/llite/file.c         |   22 +-
 .../staging/lustre/lustre/llite/llite_internal.h   |    4 +-
 drivers/staging/lustre/lustre/llite/llite_lib.c    |    6 +-
 drivers/staging/lustre/lustre/llite/llite_nfs.c    |    6 +-
 drivers/staging/lustre/lustre/llite/namei.c        |   20 +-
 drivers/staging/lustre/lustre/llite/rw26.c         |   22 +-
 drivers/staging/lustre/lustre/llite/statahead.c    |   28 +-
 drivers/staging/lustre/lustre/llite/symlink.c      |    2 +-
 drivers/staging/lustre/lustre/llite/xattr.c        |    8 +-
 drivers/staging/media/bcm2048/radio-bcm2048.c      |   39 +-
 drivers/staging/media/davinci_vpfe/dm365_ipipe.c   |   51 +-
 drivers/staging/media/davinci_vpfe/dm365_ipipeif.c |   49 +-
 drivers/staging/media/davinci_vpfe/dm365_isif.c    |   83 +-
 drivers/staging/media/davinci_vpfe/dm365_resizer.c |   59 +-
 drivers/staging/media/dt3155v4l/dt3155v4l.c        |   37 +-
 drivers/staging/media/dt3155v4l/dt3155v4l.h        |    4 +-
 drivers/staging/media/mn88472/mn88472.c            |   93 +-
 drivers/staging/media/mn88472/mn88472_priv.h       |    2 +
 drivers/staging/media/mn88473/mn88473.c            |  133 +-
 drivers/staging/media/mn88473/mn88473_priv.h       |    1 +
 drivers/staging/media/omap4iss/iss_csi2.c          |   42 +-
 drivers/staging/media/omap4iss/iss_ipipe.c         |   48 +-
 drivers/staging/media/omap4iss/iss_ipipeif.c       |   58 +-
 drivers/staging/media/omap4iss/iss_resizer.c       |   52 +-
 drivers/staging/media/omap4iss/iss_video.c         |    8 +-
 drivers/staging/octeon/ethernet-tx.c               |    5 +-
 drivers/staging/octeon/ethernet.c                  |   10 +
 drivers/target/Kconfig                             |    5 +-
 drivers/target/Makefile                            |    2 +-
 drivers/target/iscsi/Makefile                      |    1 -
 drivers/target/iscsi/iscsi_target.c                |  131 +-
 drivers/target/iscsi/iscsi_target.h                |    2 +-
 drivers/target/iscsi/iscsi_target_configfs.c       |  208 +-
 drivers/target/iscsi/iscsi_target_configfs.h       |    7 -
 drivers/target/iscsi/iscsi_target_erl0.c           |   14 +-
 drivers/target/iscsi/iscsi_target_login.c          |   60 +-
 drivers/target/iscsi/iscsi_target_tpg.c            |   25 +-
 drivers/target/iscsi/iscsi_target_tpg.h            |    1 +
 drivers/target/iscsi/iscsi_target_tq.c             |  495 --
 drivers/target/iscsi/iscsi_target_tq.h             |   84 -
 drivers/target/iscsi/iscsi_target_util.c           |    1 -
 drivers/target/loopback/tcm_loop.c                 |  242 +-
 drivers/target/loopback/tcm_loop.h                 |    1 +
 drivers/target/sbp/sbp_target.c                    |   68 +-
 drivers/target/target_core_configfs.c              |  192 +-
 drivers/target/target_core_fabric_configfs.c       |   38 +-
 drivers/target/target_core_file.c                  |  261 +-
 drivers/target/target_core_iblock.c                |    4 +-
 drivers/target/target_core_internal.h              |    6 +
 drivers/target/target_core_pr.c                    |   48 +-
 drivers/target/target_core_rd.c                    |  137 +-
 drivers/target/target_core_sbc.c                   |  109 +-
 drivers/target/target_core_spc.c                   |   16 +-
 drivers/target/target_core_tmr.c                   |    4 +-
 drivers/target/target_core_tpg.c                   |    2 +-
 drivers/target/target_core_transport.c             |  162 +-
 drivers/target/target_core_user.c                  |   52 +-
 drivers/target/target_core_xcopy.c                 |   46 +-
 drivers/target/tcm_fc/tcm_fc.h                     |    1 -
 drivers/target/tcm_fc/tfc_conf.c                   |   89 +-
 drivers/tty/Kconfig                                |   47 +
 drivers/tty/Makefile                               |    1 +
 drivers/tty/hvc/hvc_opal.c                         |    2 +-
 drivers/tty/mips_ejtag_fdc.c                       | 1303 +++++
 drivers/tty/n_gsm.c                                |   12 +-
 drivers/tty/serial/8250/8250.h                     |   23 +-
 drivers/tty/serial/8250/8250_core.c                |  513 +-
 drivers/tty/serial/8250/8250_dw.c                  |   58 +-
 drivers/tty/serial/8250/8250_early.c               |   74 +-
 drivers/tty/serial/8250/8250_em.c                  |    1 -
 drivers/tty/serial/8250/8250_hp300.c               |    1 -
 drivers/tty/serial/8250/8250_omap.c                |    1 -
 drivers/tty/serial/8250/8250_pci.c                 |  414 +-
 drivers/tty/serial/8250/Kconfig                    |    1 +
 drivers/tty/serial/Kconfig                         |   32 +-
 drivers/tty/serial/Makefile                        |    2 -
 drivers/tty/serial/amba-pl011.c                    |  234 +-
 drivers/tty/serial/apbuart.c                       |    2 +-
 drivers/tty/serial/ar933x_uart.c                   |    2 +-
 drivers/tty/serial/atmel_serial.c                  |   29 +-
 drivers/tty/serial/bcm63xx_uart.c                  |    4 +-
 drivers/tty/serial/bfin_uart.c                     |    2 +
 drivers/tty/serial/clps711x.c                      |    2 +
 drivers/tty/serial/cpm_uart/Makefile               |    2 +-
 drivers/tty/serial/cpm_uart/cpm_uart.h             |    2 +-
 drivers/tty/serial/cpm_uart/cpm_uart_core.c        |    2 +-
 drivers/tty/serial/earlycon.c                      |  140 +-
 drivers/tty/serial/fsl_lpuart.c                    |    2 +-
 drivers/tty/serial/imx.c                           |  317 +-
 drivers/tty/serial/jsm/jsm_cls.c                   |    2 +-
 drivers/tty/serial/jsm/jsm_neo.c                   |    6 +-
 drivers/tty/serial/max3100.c                       |    2 +-
 drivers/tty/serial/mfd.c                           | 1505 ------
 drivers/tty/serial/mpc52xx_uart.c                  |    2 +-
 drivers/tty/serial/msm_serial.h                    |    9 -
 drivers/tty/serial/msm_serial_hs.c                 | 1874 -------
 drivers/tty/serial/mxs-auart.c                     |   18 +-
 drivers/tty/serial/of_serial.c                     |    8 +-
 drivers/tty/serial/omap-serial.c                   |   10 +-
 drivers/tty/serial/pmac_zilog.c                    |    2 +-
 drivers/tty/serial/pxa.c                           |    2 +-
 drivers/tty/serial/sc16is7xx.c                     |   46 +-
 drivers/tty/serial/serial-tegra.c                  |    2 +-
 drivers/tty/serial/serial_core.c                   |   52 +-
 drivers/tty/serial/serial_mctrl_gpio.c             |   50 +-
 drivers/tty/serial/sh-sci.c                        |   88 +-
 drivers/tty/serial/sirfsoc_uart.c                  |    2 +-
 drivers/tty/serial/sprd_serial.c                   |    6 +-
 drivers/tty/serial/st-asc.c                        |    2 +-
 drivers/tty/serial/uartlite.c                      |    2 +-
 drivers/tty/serial/ucc_uart.c                      |    2 +-
 drivers/tty/serial/xilinx_uartps.c                 |  242 +-
 drivers/tty/tty_io.c                               |   24 +-
 drivers/tty/vt/vt.c                                |   74 +-
 drivers/tty/vt/vt_ioctl.c                          |    2 +-
 drivers/uio/uio.c                                  |   12 +-
 drivers/usb/gadget/function/f_fs.c                 |    2 -
 drivers/usb/gadget/function/f_uvc.c                |   40 +-
 drivers/usb/gadget/function/uvc.h                  |    3 +-
 drivers/usb/gadget/function/uvc_queue.c            |   79 +-
 drivers/usb/gadget/function/uvc_queue.h            |    4 +-
 drivers/usb/gadget/function/uvc_v4l2.c             |    8 +-
 drivers/usb/gadget/function/uvc_video.c            |    3 +-
 drivers/usb/gadget/legacy/inode.c                  |    4 +-
 drivers/usb/gadget/legacy/tcm_usb_gadget.c         |   57 +-
 drivers/vhost/scsi.c                               |  126 +-
 drivers/video/fbdev/Kconfig                        |    4 +-
 drivers/video/fbdev/aty/aty128fb.c                 |    4 +-
 drivers/video/fbdev/aty/radeon_base.c              |   24 +-
 drivers/video/fbdev/aty/radeon_monitor.c           |   20 +-
 drivers/video/fbdev/aty/radeon_pm.c                |   16 +-
 drivers/video/fbdev/aty/radeonfb.h                 |    4 +-
 drivers/video/fbdev/controlfb.c                    |    2 +-
 drivers/video/fbdev/core/fbmon.c                   |    4 -
 drivers/video/fbdev/hyperv_fb.c                    |    6 +-
 drivers/video/fbdev/imsttfb.c                      |    6 +-
 drivers/video/fbdev/imxfb.c                        |    2 +-
 drivers/video/fbdev/nvidia/Makefile                |    3 +-
 drivers/video/fbdev/nvidia/nv_of.c                 |    3 -
 drivers/video/fbdev/nvidia/nv_proto.h              |    8 -
 drivers/video/fbdev/nvidia/nvidia.c                |    4 -
 .../video/fbdev/omap2/displays-new/connector-dvi.c |    2 +-
 .../fbdev/omap2/displays-new/encoder-tfp410.c      |   11 +
 .../omap2/displays-new/panel-lgphilips-lb035q02.c  |    2 +-
 .../omap2/displays-new/panel-sharp-ls037v7dw01.c   |    2 +-
 .../omap2/displays-new/panel-sony-acx565akm.c      |    2 +-
 .../omap2/displays-new/panel-tpo-td028ttec1.c      |    2 +-
 .../omap2/displays-new/panel-tpo-td043mtea1.c      |    2 +-
 drivers/video/fbdev/omap2/dss/core.c               |    4 +
 drivers/video/fbdev/omap2/dss/dispc.c              |  147 +-
 drivers/video/fbdev/omap2/dss/display.c            |    2 +-
 drivers/video/fbdev/omap2/dss/dsi.c                |    2 +-
 drivers/video/fbdev/omap2/dss/dss.c                |    3 +
 drivers/video/fbdev/omap2/dss/dss_features.c       |    2 +-
 drivers/video/fbdev/omap2/dss/hdmi5_core.c         |    2 +-
 drivers/video/fbdev/omap2/dss/omapdss-boot-init.c  |    7 +-
 drivers/video/fbdev/omap2/dss/rfbi.c               |    2 +-
 drivers/video/fbdev/omap2/omapfb/omapfb-main.c     |    4 +-
 drivers/video/fbdev/platinumfb.c                   |    2 +-
 drivers/video/fbdev/pm3fb.c                        |    6 +-
 drivers/video/fbdev/pxafb.c                        |    6 +-
 drivers/video/fbdev/riva/fbdev.c                   |   17 +-
 drivers/video/fbdev/sh_mobile_lcdcfb.c             |   15 +-
 drivers/video/fbdev/sm501fb.c                      |    2 +-
 drivers/video/fbdev/via/via_clock.c                |    2 +-
 drivers/virtio/Kconfig                             |   10 +
 drivers/virtio/Makefile                            |    1 +
 drivers/virtio/virtio.c                            |    6 -
 drivers/virtio/virtio_balloon.c                    |   21 +-
 drivers/virtio/virtio_input.c                      |  384 ++
 drivers/virtio/virtio_mmio.c                       |    8 -
 drivers/virtio/virtio_pci_modern.c                 |  123 +-
 drivers/w1/masters/mxc_w1.c                        |    2 +-
 drivers/w1/masters/omap_hdq.c                      |    2 +-
 drivers/w1/masters/w1-gpio.c                       |    2 +-
 drivers/watchdog/Kconfig                           |    4 +-
 drivers/watchdog/at91rm9200_wdt.c                  |   61 +-
 drivers/watchdog/bcm_kona_wdt.c                    |   27 +-
 drivers/watchdog/octeon-wdt-main.c                 |  201 +-
 drivers/watchdog/pnx4008_wdt.c                     |    2 +-
 drivers/watchdog/qcom-wdt.c                        |   21 +-
 drivers/watchdog/stmp3xxx_rtc_wdt.c                |    4 +-
 drivers/xen/Kconfig                                |   10 +
 drivers/xen/Makefile                               |    3 +-
 drivers/xen/mcelog.c                               |   25 +-
 drivers/xen/pci.c                                  |   15 +-
 drivers/xen/pcpu.c                                 |   44 +-
 drivers/xen/privcmd.c                              |  117 +-
 drivers/xen/xen-balloon.c                          |   45 +-
 drivers/xen/xen-pciback/conf_space_header.c        |   15 +-
 drivers/xen/xen-pciback/pci_stub.c                 |    4 +-
 drivers/xen/xen-pciback/xenbus.c                   |    2 +-
 drivers/xen/xen-scsiback.c                         |  164 +-
 drivers/xen/xenbus/xenbus_client.c                 |  387 +-
 drivers/xen/xlate_mmu.c                            |  143 +
 firmware/ihex2fw.c                                 |    1 +
 fs/9p/acl.c                                        |    4 +-
 fs/9p/v9fs.h                                       |    1 -
 fs/9p/v9fs_vfs.h                                   |    4 -
 fs/9p/vfs_addr.c                                   |   85 +-
 fs/9p/vfs_dentry.c                                 |    4 +-
 fs/9p/vfs_dir.c                                    |   17 +-
 fs/9p/vfs_file.c                                   |  326 +-
 fs/9p/vfs_inode.c                                  |   34 +-
 fs/9p/vfs_inode_dotl.c                             |   16 +-
 fs/9p/vfs_super.c                                  |    8 +-
 fs/9p/xattr.c                                      |   80 +-
 fs/Kconfig                                         |    2 +-
 fs/adfs/dir_fplus.c                                |    1 +
 fs/adfs/file.c                                     |    2 -
 fs/adfs/inode.c                                    |    2 +-
 fs/adfs/super.c                                    |   20 +-
 fs/affs/affs.h                                     |   28 +-
 fs/affs/amigaffs.c                                 |   10 +-
 fs/affs/file.c                                     |   13 +-
 fs/affs/inode.c                                    |   34 +-
 fs/affs/namei.c                                    |   16 +-
 fs/affs/super.c                                    |   43 +-
 fs/afs/dir.c                                       |   42 +-
 fs/afs/file.c                                      |    2 -
 fs/afs/inode.c                                     |    4 +-
 fs/afs/mntpt.c                                     |    8 +-
 fs/afs/super.c                                     |    2 +-
 fs/aio.c                                           |   70 +-
 fs/autofs4/autofs_i.h                              |    6 +-
 fs/autofs4/expire.c                                |    2 +-
 fs/autofs4/inode.c                                 |    6 +-
 fs/autofs4/root.c                                  |   18 +-
 fs/autofs4/symlink.c                               |    2 +-
 fs/autofs4/waitq.c                                 |    6 +-
 fs/befs/befs.h                                     |   22 +-
 fs/befs/datastream.c                               |    4 +-
 fs/befs/io.c                                       |    2 +-
 fs/befs/linuxvfs.c                                 |   16 +-
 fs/befs/super.c                                    |    4 +-
 fs/bfs/dir.c                                       |   12 +-
 fs/bfs/file.c                                      |    2 -
 fs/binfmt_misc.c                                   |   46 +-
 fs/block_dev.c                                     |   26 +-
 fs/btrfs/async-thread.c                            |    4 +-
 fs/btrfs/async-thread.h                            |    2 +-
 fs/btrfs/backref.c                                 |    4 +-
 fs/btrfs/btrfs_inode.h                             |   14 +-
 fs/btrfs/check-integrity.c                         |    9 +-
 fs/btrfs/compression.c                             |    4 +-
 fs/btrfs/compression.h                             |    4 +-
 fs/btrfs/ctree.c                                   |   62 +-
 fs/btrfs/ctree.h                                   |   46 +-
 fs/btrfs/delayed-inode.c                           |    9 +-
 fs/btrfs/delayed-ref.c                             |   22 +-
 fs/btrfs/delayed-ref.h                             |   10 +
 fs/btrfs/dev-replace.c                             |    6 +-
 fs/btrfs/disk-io.c                                 |  570 +-
 fs/btrfs/disk-io.h                                 |    4 +-
 fs/btrfs/export.c                                  |    6 +-
 fs/btrfs/extent-tree.c                             |  476 +-
 fs/btrfs/extent_io.c                               |    5 +-
 fs/btrfs/extent_io.h                               |    2 +-
 fs/btrfs/file-item.c                               |    6 +-
 fs/btrfs/file.c                                    |   95 +-
 fs/btrfs/free-space-cache.c                        |  331 +-
 fs/btrfs/free-space-cache.h                        |    9 +-
 fs/btrfs/inode-map.c                               |    2 +-
 fs/btrfs/inode.c                                   |  204 +-
 fs/btrfs/ioctl.c                                   |   55 +-
 fs/btrfs/lzo.c                                     |    2 +-
 fs/btrfs/math.h                                    |    6 +-
 fs/btrfs/props.c                                   |    2 +
 fs/btrfs/qgroup.c                                  |  348 +-
 fs/btrfs/qgroup.h                                  |    3 +-
 fs/btrfs/raid56.c                                  |   16 +-
 fs/btrfs/relocation.c                              |   11 +-
 fs/btrfs/scrub.c                                   |   25 +-
 fs/btrfs/send.c                                    |   83 +-
 fs/btrfs/super.c                                   |   31 +-
 fs/btrfs/sysfs.c                                   |    2 +-
 fs/btrfs/sysfs.h                                   |   22 +-
 fs/btrfs/tests/qgroup-tests.c                      |    4 +-
 fs/btrfs/transaction.c                             |   54 +-
 fs/btrfs/transaction.h                             |   12 +
 fs/btrfs/tree-log.c                                |  396 +-
 fs/btrfs/tree-log.h                                |    2 +
 fs/btrfs/volumes.c                                 |  140 +-
 fs/btrfs/volumes.h                                 |    3 +-
 fs/btrfs/xattr.c                                   |   69 +-
 fs/btrfs/zlib.c                                    |    2 +-
 fs/cachefiles/bind.c                               |   10 +-
 fs/cachefiles/interface.c                          |    6 +-
 fs/cachefiles/namei.c                              |  122 +-
 fs/cachefiles/rdwr.c                               |   14 +-
 fs/cachefiles/security.c                           |    6 +-
 fs/cachefiles/xattr.c                              |   22 +-
 fs/ceph/addr.c                                     |   41 +-
 fs/ceph/caps.c                                     |   53 +-
 fs/ceph/debugfs.c                                  |    2 +-
 fs/ceph/dir.c                                      |  108 +-
 fs/ceph/export.c                                   |   28 +-
 fs/ceph/file.c                                     |   28 +-
 fs/ceph/inode.c                                    |   52 +-
 fs/ceph/mds_client.c                               |   85 +-
 fs/ceph/strings.c                                  |    1 +
 fs/ceph/super.c                                    |   60 +-
 fs/ceph/super.h                                    |    4 +-
 fs/ceph/xattr.c                                    |   39 +-
 fs/cifs/cifs_dfs_ref.c                             |    2 +-
 fs/cifs/cifsfs.c                                   |   14 +-
 fs/cifs/cifssmb.c                                  |    4 +-
 fs/cifs/dir.c                                      |    8 +-
 fs/cifs/file.c                                     |  141 +-
 fs/cifs/inode.c                                    |   32 +-
 fs/cifs/link.c                                     |   12 +-
 fs/cifs/misc.c                                     |    2 +-
 fs/cifs/readdir.c                                  |    4 +-
 fs/cifs/smb1ops.c                                  |    2 +-
 fs/cifs/smb2file.c                                 |    4 +-
 fs/cifs/smb2misc.c                                 |    4 +-
 fs/cifs/smb2ops.c                                  |   10 +-
 fs/cifs/xattr.c                                    |   22 +-
 fs/coda/cache.c                                    |    4 +-
 fs/coda/dir.c                                      |   22 +-
 fs/coda/file.c                                     |   38 +-
 fs/coda/inode.c                                    |    6 +-
 fs/coda/pioctl.c                                   |    2 +-
 fs/coda/upcall.c                                   |    4 +-
 fs/configfs/dir.c                                  |   70 +-
 fs/configfs/file.c                                 |    4 +-
 fs/configfs/inode.c                                |   16 +-
 fs/coredump.c                                      |    2 +-
 fs/dax.c                                           |   48 +-
 fs/dcache.c                                        |   47 +-
 fs/debugfs/file.c                                  |    2 +-
 fs/debugfs/inode.c                                 |   58 +-
 fs/devpts/inode.c                                  |   16 +-
 fs/direct-io.c                                     |   46 +-
 fs/ecryptfs/crypto.c                               |    4 +-
 fs/ecryptfs/dentry.c                               |    6 +-
 fs/ecryptfs/file.c                                 |    4 +-
 fs/ecryptfs/inode.c                                |  164 +-
 fs/ecryptfs/kthread.c                              |    2 +-
 fs/ecryptfs/main.c                                 |    6 +-
 fs/ecryptfs/mmap.c                                 |    2 +-
 fs/efivarfs/inode.c                                |    4 +-
 fs/efivarfs/super.c                                |    2 +-
 fs/efs/namei.c                                     |    4 +-
 fs/exec.c                                          |   88 +-
 fs/exofs/dir.c                                     |    4 +-
 fs/exofs/file.c                                    |    2 -
 fs/exofs/inode.c                                   |    6 +-
 fs/exofs/namei.c                                   |   10 +-
 fs/exofs/super.c                                   |    2 +-
 fs/exofs/symlink.c                                 |    2 +-
 fs/ext2/dir.c                                      |    2 +-
 fs/ext2/ext2.h                                     |    1 -
 fs/ext2/file.c                                     |   21 +-
 fs/ext2/ialloc.c                                   |    2 +-
 fs/ext2/inode.c                                    |   18 +-
 fs/ext2/namei.c                                    |   24 +-
 fs/ext2/symlink.c                                  |    2 +-
 fs/ext2/xattr.c                                    |    4 +-
 fs/ext2/xattr_security.c                           |    4 +-
 fs/ext2/xattr_trusted.c                            |    4 +-
 fs/ext2/xattr_user.c                               |    4 +-
 fs/ext3/file.c                                     |    2 -
 fs/ext3/ialloc.c                                   |    2 +-
 fs/ext3/inode.c                                    |   16 +-
 fs/ext3/namei.c                                    |   34 +-
 fs/ext3/super.c                                    |    8 +-
 fs/ext3/symlink.c                                  |    2 +-
 fs/ext3/xattr.c                                    |   13 +-
 fs/ext3/xattr_security.c                           |    4 +-
 fs/ext3/xattr_trusted.c                            |    4 +-
 fs/ext3/xattr_user.c                               |    4 +-
 fs/ext4/Kconfig                                    |   17 +
 fs/ext4/Makefile                                   |    4 +-
 fs/ext4/acl.c                                      |    5 -
 fs/ext4/balloc.c                                   |    3 -
 fs/ext4/bitmap.c                                   |    1 -
 fs/ext4/block_validity.c                           |    1 -
 fs/ext4/crypto.c                                   |  558 ++
 fs/ext4/crypto_fname.c                             |  709 +++
 fs/ext4/crypto_key.c                               |  165 +
 fs/ext4/crypto_policy.c                            |  194 +
 fs/ext4/dir.c                                      |   81 +-
 fs/ext4/ext4.h                                     |  174 +-
 fs/ext4/ext4_crypto.h                              |  147 +
 fs/ext4/extents.c                                  |   81 +-
 fs/ext4/extents_status.c                           |    2 -
 fs/ext4/file.c                                     |   75 +-
 fs/ext4/fsync.c                                    |    3 +-
 fs/ext4/hash.c                                     |    1 -
 fs/ext4/ialloc.c                                   |   30 +-
 fs/ext4/indirect.c                                 |   31 +-
 fs/ext4/inline.c                                   |   20 +-
 fs/ext4/inode.c                                    |  171 +-
 fs/ext4/ioctl.c                                    |   86 +-
 fs/ext4/migrate.c                                  |    2 +-
 fs/ext4/namei.c                                    |  681 ++-
 fs/ext4/page-io.c                                  |   47 +-
 fs/ext4/readpage.c                                 |  328 ++
 fs/ext4/super.c                                    |   64 +-
 fs/ext4/symlink.c                                  |   99 +-
 fs/ext4/xattr.c                                    |   14 +-
 fs/ext4/xattr.h                                    |    3 +
 fs/ext4/xattr_security.c                           |    4 +-
 fs/ext4/xattr_trusted.c                            |    4 +-
 fs/ext4/xattr_user.c                               |    4 +-
 fs/f2fs/Kconfig                                    |    2 +-
 fs/f2fs/acl.c                                      |   14 +-
 fs/f2fs/checkpoint.c                               |   38 +-
 fs/f2fs/data.c                                     |  764 ++-
 fs/f2fs/debug.c                                    |   22 +-
 fs/f2fs/dir.c                                      |   93 +-
 fs/f2fs/f2fs.h                                     |  176 +-
 fs/f2fs/file.c                                     |   70 +-
 fs/f2fs/gc.c                                       |    6 +-
 fs/f2fs/inline.c                                   |   69 +-
 fs/f2fs/inode.c                                    |   25 +-
 fs/f2fs/namei.c                                    |   99 +-
 fs/f2fs/node.c                                     |   18 +-
 fs/f2fs/node.h                                     |    1 +
 fs/f2fs/recovery.c                                 |   76 +-
 fs/f2fs/segment.c                                  |   17 +-
 fs/f2fs/segment.h                                  |    3 +-
 fs/f2fs/super.c                                    |   40 +-
 fs/f2fs/xattr.c                                    |   14 +-
 fs/fat/cache.c                                     |    2 -
 fs/fat/dir.c                                       |    4 -
 fs/fat/fat.h                                       |    5 +-
 fs/fat/fatent.c                                    |    3 -
 fs/fat/file.c                                      |   10 +-
 fs/fat/inode.c                                     |   22 +-
 fs/fat/misc.c                                      |    4 -
 fs/fat/namei_msdos.c                               |   10 +-
 fs/fat/namei_vfat.c                                |   16 +-
 fs/fat/nfs.c                                       |    4 +-
 fs/file.c                                          |    3 +-
 fs/file_table.c                                    |    4 +-
 fs/freevxfs/vxfs_immed.c                           |    2 +-
 fs/fs_pin.c                                        |    4 +-
 fs/fuse/control.c                                  |    6 +-
 fs/fuse/cuse.c                                     |   25 +-
 fs/fuse/dev.c                                      |   63 +-
 fs/fuse/dir.c                                      |   60 +-
 fs/fuse/file.c                                     |   96 +-
 fs/fuse/inode.c                                    |    4 +-
 fs/gfs2/aops.c                                     |   16 +-
 fs/gfs2/dentry.c                                   |   12 +-
 fs/gfs2/export.c                                   |    8 +-
 fs/gfs2/file.c                                     |    6 +-
 fs/gfs2/inode.c                                    |   34 +-
 fs/gfs2/ops_fstype.c                               |    8 +-
 fs/gfs2/quota.c                                    |   28 +-
 fs/gfs2/super.c                                    |    2 +-
 fs/gfs2/xattr.c                                    |    6 +-
 fs/hfs/attr.c                                      |    6 +-
 fs/hfs/dir.c                                       |   12 +-
 fs/hfs/inode.c                                     |   12 +-
 fs/hfs/sysdep.c                                    |    2 +-
 fs/hfsplus/bfind.c                                 |    4 +-
 fs/hfsplus/catalog.c                               |    3 +-
 fs/hfsplus/dir.c                                   |   16 +-
 fs/hfsplus/inode.c                                 |   19 +-
 fs/hfsplus/ioctl.c                                 |   14 +-
 fs/hfsplus/xattr.c                                 |   90 +-
 fs/hfsplus/xattr.h                                 |   22 +-
 fs/hfsplus/xattr_security.c                        |   38 +-
 fs/hfsplus/xattr_trusted.c                         |   37 +-
 fs/hfsplus/xattr_user.c                            |   35 +-
 fs/hostfs/hostfs.h                                 |    6 +-
 fs/hostfs/hostfs_kern.c                            |  116 +-
 fs/hostfs/hostfs_user.c                            |   29 +-
 fs/hpfs/file.c                                     |    2 -
 fs/hpfs/inode.c                                    |    2 +-
 fs/hpfs/namei.c                                    |    8 +-
 fs/hppfs/hppfs.c                                   |   20 +-
 fs/hugetlbfs/inode.c                               |  185 +-
 fs/inode.c                                         |   20 +-
 fs/isofs/export.c                                  |    2 +-
 fs/jffs2/dir.c                                     |   40 +-
 fs/jffs2/file.c                                    |    2 -
 fs/jffs2/fs.c                                      |    2 +-
 fs/jffs2/security.c                                |    4 +-
 fs/jffs2/super.c                                   |    4 +-
 fs/jffs2/symlink.c                                 |    2 +-
 fs/jffs2/xattr.c                                   |    3 +-
 fs/jffs2/xattr_trusted.c                           |    4 +-
 fs/jffs2/xattr_user.c                              |    4 +-
 fs/jfs/file.c                                      |    4 +-
 fs/jfs/inode.c                                     |    8 +-
 fs/jfs/jfs_metapage.c                              |   31 +-
 fs/jfs/jfs_metapage.h                              |    1 -
 fs/jfs/namei.c                                     |   18 +-
 fs/jfs/symlink.c                                   |    2 +-
 fs/jfs/xattr.c                                     |   12 +-
 fs/kernfs/dir.c                                    |    2 +-
 fs/kernfs/inode.c                                  |    8 +-
 fs/libfs.c                                         |   26 +-
 fs/lockd/svcsubs.c                                 |    2 +-
 fs/locks.c                                         |   94 +-
 fs/logfs/dir.c                                     |   14 +-
 fs/logfs/file.c                                    |    4 +-
 fs/minix/dir.c                                     |    4 +-
 fs/minix/file.c                                    |    4 +-
 fs/minix/inode.c                                   |    4 +-
 fs/minix/namei.c                                   |   10 +-
 fs/namei.c                                         |   14 +-
 fs/namespace.c                                     |  142 +-
 fs/ncpfs/dir.c                                     |   48 +-
 fs/ncpfs/file.c                                    |   88 +-
 fs/ncpfs/inode.c                                   |    6 +-
 fs/ncpfs/ioctl.c                                   |    8 +-
 fs/ncpfs/ncplib_kernel.c                           |    8 +-
 fs/ncpfs/ncplib_kernel.h                           |    2 +-
 fs/ncpfs/symlink.c                                 |    2 +-
 fs/nfs/Kconfig                                     |    2 +-
 fs/nfs/Makefile                                    |    2 +-
 fs/nfs/blocklayout/blocklayout.c                   |    1 +
 fs/nfs/blocklayout/dev.c                           |    2 +-
 fs/nfs/callback.c                                  |    6 +-
 fs/nfs/client.c                                    |    1 -
 fs/nfs/delegation.c                                |    4 +-
 fs/nfs/dir.c                                       |   63 +-
 fs/nfs/direct.c                                    |   89 +-
 fs/nfs/file.c                                      |   20 +-
 fs/nfs/filelayout/filelayout.c                     |   10 +-
 fs/nfs/filelayout/filelayoutdev.c                  |    2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c             |   12 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c          |    2 +-
 fs/nfs/getroot.c                                   |    4 +-
 fs/nfs/inode.c                                     |   54 +-
 fs/nfs/namespace.c                                 |   10 +-
 fs/nfs/nfs3acl.c                                   |    2 +-
 fs/nfs/nfs3proc.c                                  |   12 +-
 fs/nfs/nfs42proc.c                                 |   31 +-
 fs/nfs/nfs42xdr.c                                  |   20 +-
 fs/nfs/nfs4client.c                                |    4 +-
 fs/nfs/nfs4file.c                                  |   26 +-
 fs/nfs/{idmap.c =3D> nfs4idmap.c}                    |    2 +-
 include/linux/nfs_idmap.h =3D> fs/nfs/nfs4idmap.h    |   13 +-
 fs/nfs/nfs4namespace.c                             |    4 +-
 fs/nfs/nfs4proc.c                                  |   83 +-
 fs/nfs/nfs4state.c                                 |    6 +-
 fs/nfs/nfs4super.c                                 |    7 +-
 fs/nfs/nfs4sysctl.c                                |    2 +-
 fs/nfs/nfs4trace.h                                 |    4 +-
 fs/nfs/nfs4xdr.c                                   |   22 +-
 fs/nfs/nfstrace.c                                  |    3 +
 fs/nfs/objlayout/objio_osd.c                       |    4 +-
 fs/nfs/pagelist.c                                  |    2 +-
 fs/nfs/pnfs.c                                      |   68 +-
 fs/nfs/pnfs.h                                      |   28 +-
 fs/nfs/pnfs_dev.c                                  |   21 +-
 fs/nfs/pnfs_nfs.c                                  |   12 +-
 fs/nfs/proc.c                                      |    4 +-
 fs/nfs/read.c                                      |   10 +-
 fs/nfs/super.c                                     |   10 +-
 fs/nfs/symlink.c                                   |    2 +-
 fs/nfs/unlink.c                                    |   20 +-
 fs/nfs/write.c                                     |   23 +-
 fs/nfsd/Kconfig                                    |    3 +-
 fs/nfsd/export.c                                   |    8 +-
 fs/nfsd/nfs2acl.c                                  |    8 +-
 fs/nfsd/nfs3acl.c                                  |    8 +-
 fs/nfsd/nfs3proc.c                                 |    6 +-
 fs/nfsd/nfs3xdr.c                                  |   16 +-
 fs/nfsd/nfs4acl.c                                  |   54 +-
 fs/nfsd/nfs4proc.c                                 |   24 +-
 fs/nfsd/nfs4recover.c                              |   22 +-
 fs/nfsd/nfs4state.c                                |   27 +-
 fs/nfsd/nfs4xdr.c                                  |   26 +-
 fs/nfsd/nfsctl.c                                   |   16 +-
 fs/nfsd/nfsd.h                                     |    2 +-
 fs/nfsd/nfsfh.c                                    |   20 +-
 fs/nfsd/nfsfh.h                                    |    6 +-
 fs/nfsd/nfsproc.c                                  |    4 +-
 fs/nfsd/nfsxdr.c                                   |    2 +-
 fs/nfsd/vfs.c                                      |   62 +-
 fs/nfsd/xdr4.h                                     |    5 +-
 fs/nilfs2/alloc.c                                  |    5 +-
 fs/nilfs2/bmap.c                                   |   48 +-
 fs/nilfs2/bmap.h                                   |   13 +-
 fs/nilfs2/btree.c                                  |   63 +
 fs/nilfs2/cpfile.c                                 |   58 +-
 fs/nilfs2/dir.c                                    |    2 +-
 fs/nilfs2/direct.c                                 |   17 +
 fs/nilfs2/file.c                                   |    2 -
 fs/nilfs2/inode.c                                  |   37 +-
 fs/nilfs2/mdt.c                                    |   54 +
 fs/nilfs2/mdt.h                                    |   10 +-
 fs/nilfs2/namei.c                                  |   18 +-
 fs/nilfs2/page.c                                   |   24 +-
 fs/nilfs2/segment.c                                |   17 +-
 fs/nilfs2/super.c                                  |    8 +-
 fs/nsfs.c                                          |    4 +-
 fs/ntfs/file.c                                     |   82 +-
 fs/ntfs/inode.c                                    |    2 +-
 fs/ntfs/namei.c                                    |    4 +-
 fs/ocfs2/aops.c                                    |   22 +-
 fs/ocfs2/cluster/heartbeat.c                       |   42 +-
 fs/ocfs2/dcache.c                                  |   14 +-
 fs/ocfs2/dir.h                                     |    2 +-
 fs/ocfs2/dlmfs/dlmfs.c                             |    4 +-
 fs/ocfs2/dlmglue.c                                 |    2 +-
 fs/ocfs2/export.c                                  |    2 +-
 fs/ocfs2/file.c                                    |  136 +-
 fs/ocfs2/inode.c                                   |    2 +-
 fs/ocfs2/namei.c                                   |   14 +-
 fs/ocfs2/refcounttree.c                            |   10 +-
 fs/ocfs2/super.c                                   |    9 +-
 fs/ocfs2/xattr.c                                   |   22 +-
 fs/omfs/dir.c                                      |   10 +-
 fs/omfs/file.c                                     |    4 +-
 fs/open.c                                          |   12 +-
 fs/pipe.c                                          |    4 +-
 fs/pnode.c                                         |   60 +-
 fs/pnode.h                                         |    7 +-
 fs/posix_acl.c                                     |    8 +-
 fs/proc/array.c                                    |   26 +-
 fs/proc/base.c                                     |  114 +-
 fs/proc/fd.c                                       |   33 +-
 fs/proc/generic.c                                  |    4 +-
 fs/proc/inode.c                                    |    2 +-
 fs/proc/namespaces.c                               |    4 +-
 fs/proc/proc_net.c                                 |    2 +-
 fs/proc/proc_sysctl.c                              |   12 +-
 fs/proc/root.c                                     |    2 +-
 fs/proc/self.c                                     |    2 +-
 fs/proc/thread_self.c                              |    2 +-
 fs/pstore/inode.c                                  |   13 +-
 fs/qnx6/inode.c                                    |    2 +-
 fs/quota/dquot.c                                   |  161 +-
 fs/quota/quota.c                                   |  217 +-
 fs/quota/quota_tree.c                              |    7 +
 fs/quota/quota_v2.c                                |   12 +-
 fs/quota/quotaio_v2.h                              |    6 +-
 fs/ramfs/file-mmu.c                                |    2 -
 fs/ramfs/file-nommu.c                              |    4 +-
 fs/read_write.c                                    |  112 +-
 fs/reiserfs/dir.c                                  |    4 +-
 fs/reiserfs/file.c                                 |    2 -
 fs/reiserfs/inode.c                                |   10 +-
 fs/reiserfs/namei.c                                |   12 +-
 fs/reiserfs/reiserfs.h                             |    1 -
 fs/reiserfs/super.c                                |    6 +-
 fs/reiserfs/xattr.c                                |  126 +-
 fs/reiserfs/xattr.h                                |    2 +-
 fs/reiserfs/xattr_security.c                       |   10 +-
 fs/reiserfs/xattr_trusted.c                        |   10 +-
 fs/reiserfs/xattr_user.c                           |    4 +-
 fs/romfs/mmap-nommu.c                              |    1 -
 fs/splice.c                                        |    3 +
 fs/squashfs/export.c                               |    2 +-
 fs/squashfs/xattr.c                                |    8 +-
 fs/stat.c                                          |    4 +-
 fs/sysv/dir.c                                      |    4 +-
 fs/sysv/file.c                                     |    4 +-
 fs/sysv/itree.c                                    |    2 +-
 fs/sysv/namei.c                                    |   10 +-
 fs/sysv/symlink.c                                  |    2 +-
 fs/ubifs/budget.c                                  |    2 +-
 fs/ubifs/commit.c                                  |   12 +-
 fs/ubifs/compress.c                                |   22 +-
 fs/ubifs/debug.c                                   |  186 +-
 fs/ubifs/dir.c                                     |   37 +-
 fs/ubifs/file.c                                    |   23 +-
 fs/ubifs/io.c                                      |   40 +-
 fs/ubifs/ioctl.c                                   |    2 +-
 fs/ubifs/journal.c                                 |   21 +-
 fs/ubifs/log.c                                     |    4 +-
 fs/ubifs/lprops.c                                  |   62 +-
 fs/ubifs/lpt.c                                     |   59 +-
 fs/ubifs/lpt_commit.c                              |   34 +-
 fs/ubifs/master.c                                  |    6 +-
 fs/ubifs/orphan.c                                  |   26 +-
 fs/ubifs/recovery.c                                |   44 +-
 fs/ubifs/replay.c                                  |   34 +-
 fs/ubifs/sb.c                                      |   30 +-
 fs/ubifs/scan.c                                    |   24 +-
 fs/ubifs/super.c                                   |  107 +-
 fs/ubifs/tnc.c                                     |   20 +-
 fs/ubifs/tnc_commit.c                              |   12 +-
 fs/ubifs/tnc_misc.c                                |   24 +-
 fs/ubifs/ubifs.h                                   |   40 +-
 fs/ubifs/xattr.c                                   |   28 +-
 fs/udf/balloc.c                                    |   20 +-
 fs/udf/dir.c                                       |    1 -
 fs/udf/directory.c                                 |    1 -
 fs/udf/file.c                                      |   30 +-
 fs/udf/inode.c                                     |   10 +-
 fs/udf/misc.c                                      |    1 -
 fs/udf/namei.c                                     |   26 +-
 fs/udf/partition.c                                 |    1 -
 fs/udf/super.c                                     |    1 -
 fs/udf/symlink.c                                   |    1 -
 fs/udf/truncate.c                                  |    1 -
 fs/ufs/dir.c                                       |    2 +-
 fs/ufs/file.c                                      |    2 -
 fs/ufs/namei.c                                     |   10 +-
 fs/ufs/super.c                                     |    4 +-
 fs/ufs/symlink.c                                   |    2 +-
 fs/ufs/truncate.c                                  |    2 +-
 fs/xfs/libxfs/xfs_alloc.c                          |  104 +-
 fs/xfs/libxfs/xfs_attr_leaf.c                      |  150 +-
 fs/xfs/libxfs/xfs_attr_leaf.h                      |    6 +-
 fs/xfs/libxfs/xfs_bmap.c                           |  554 +-
 fs/xfs/libxfs/xfs_bmap.h                           |   13 +-
 fs/xfs/libxfs/xfs_btree.c                          |   24 +-
 fs/xfs/libxfs/xfs_da_btree.c                       |    8 +-
 fs/xfs/libxfs/xfs_da_format.h                      |   14 +-
 fs/xfs/libxfs/xfs_dir2_data.c                      |   39 +-
 fs/xfs/libxfs/xfs_format.h                         |   62 -
 fs/xfs/libxfs/xfs_ialloc.c                         |   48 +-
 fs/xfs/libxfs/xfs_sb.c                             |   20 +-
 fs/xfs/xfs_aops.c                                  |  282 +-
 fs/xfs/xfs_attr_inactive.c                         |    3 +-
 fs/xfs/xfs_attr_list.c                             |    9 +-
 fs/xfs/xfs_bmap_util.c                             |  164 +-
 fs/xfs/xfs_bmap_util.h                             |    2 +
 fs/xfs/xfs_buf_item.c                              |    4 +-
 fs/xfs/xfs_discard.c                               |    2 +-
 fs/xfs/xfs_error.c                                 |    2 +-
 fs/xfs/xfs_error.h                                 |    8 +-
 fs/xfs/xfs_export.c                                |    2 +-
 fs/xfs/xfs_file.c                                  |  202 +-
 fs/xfs/xfs_filestream.c                            |    4 +-
 fs/xfs/xfs_fsops.c                                 |   20 +-
 fs/xfs/xfs_icache.c                                |    4 +-
 fs/xfs/xfs_inode.c                                 |  558 +-
 fs/xfs/xfs_inode.h                                 |   49 +-
 fs/xfs/xfs_ioctl.c                                 |   25 +-
 fs/xfs/xfs_ioctl32.c                               |   12 +-
 fs/xfs/xfs_iomap.c                                 |    3 +-
 fs/xfs/xfs_iops.c                                  |  109 +-
 fs/xfs/xfs_iops.h                                  |    2 -
 fs/xfs/xfs_itable.c                                |    2 +-
 fs/xfs/xfs_linux.h                                 |    9 -
 fs/xfs/xfs_log_recover.c                           |    4 +-
 fs/xfs/xfs_mount.c                                 |  918 +---
 fs/xfs/xfs_mount.h                                 |   95 +-
 fs/xfs/xfs_mru_cache.c                             |    2 +-
 fs/xfs/xfs_pnfs.c                                  |    7 +-
 fs/xfs/xfs_pnfs.h                                  |    5 +-
 fs/xfs/xfs_qm.c                                    |   13 +-
 fs/xfs/xfs_qm.h                                    |    4 -
 fs/xfs/xfs_qm_syscalls.c                           |  176 -
 fs/xfs/xfs_quotaops.c                              |  117 +-
 fs/xfs/xfs_super.c                                 |  134 +-
 fs/xfs/xfs_super.h                                 |    2 +
 fs/xfs/xfs_symlink.c                               |   58 +-
 fs/xfs/xfs_trace.h                                 |   29 +-
 fs/xfs/xfs_trans.c                                 |  234 +-
 fs/xfs/xfs_xattr.c                                 |    6 +-
 include/acpi/acpi_io.h                             |    4 +
 include/acpi/acpixf.h                              |   14 +-
 include/acpi/actbl2.h                              |   70 +-
 include/acpi/actypes.h                             |   50 +-
 include/acpi/platform/acenv.h                      |    1 +
 include/acpi/processor.h                           |    6 +-
 include/asm-generic/dma-mapping-common.h           |    5 +
 include/asm-generic/gpio.h                         |   48 -
 include/asm-generic/seccomp.h                      |    2 +
 include/asm-generic/vmlinux.lds.h                  |    9 +
 include/crypto/algapi.h                            |    2 +-
 include/crypto/rng.h                               |    3 +-
 include/crypto/sha.h                               |   15 +-
 include/crypto/sha1_base.h                         |  106 +
 include/crypto/sha256_base.h                       |  128 +
 include/crypto/sha512_base.h                       |  131 +
 include/drm/bridge/dw_hdmi.h                       |    5 +-
 include/drm/drmP.h                                 |   20 +-
 include/drm/drm_atomic.h                           |   24 +
 include/drm/drm_atomic_helper.h                    |   20 +-
 include/drm/drm_crtc.h                             |   21 +-
 include/drm/drm_crtc_helper.h                      |    9 +-
 include/drm/drm_dp_helper.h                        |  176 +-
 include/drm/drm_dp_mst_helper.h                    |    2 +
 include/drm/drm_edid.h                             |    2 +
 include/drm/drm_fb_helper.h                        |   19 +
 include/drm/drm_gem.h                              |   14 +-
 include/drm/drm_modes.h                            |    2 +-
 include/drm/drm_panel.h                            |    5 +
 include/drm/drm_plane_helper.h                     |   12 +-
 include/drm/i915_pciids.h                          |   77 +-
 include/dt-bindings/clock/exynos3250.h             |   61 +
 include/dt-bindings/clock/exynos5433.h             | 1403 +++++
 include/dt-bindings/clock/imx6qdl-clock.h          |    5 +-
 include/dt-bindings/clock/pistachio-clk.h          |  183 +
 include/dt-bindings/clock/qcom,gcc-ipq806x.h       |    1 +
 include/dt-bindings/clock/qcom,gcc-msm8916.h       |  156 +
 include/dt-bindings/clock/r8a73a4-clock.h          |   62 +
 include/dt-bindings/clock/r8a7778-clock.h          |   71 +
 include/dt-bindings/clock/r8a7790-clock.h          |    3 +
 include/dt-bindings/clock/r8a7791-clock.h          |    3 +
 include/dt-bindings/clock/sh73a0-clock.h           |    3 +
 include/dt-bindings/clock/tegra124-car-common.h    |    2 +-
 include/dt-bindings/dma/jz4780-dma.h               |   49 +
 include/dt-bindings/leds/common.h                  |   21 +
 include/dt-bindings/media/omap3-isp.h              |   22 +
 include/dt-bindings/media/xilinx-vip.h             |   39 +
 include/dt-bindings/reset/qcom,gcc-msm8916.h       |  108 +
 include/linux/a.out.h                              |   67 -
 include/linux/acpi.h                               |    8 +-
 include/linux/acpi_irq.h                           |   10 +
 include/linux/arm-cci.h                            |    9 +-
 include/linux/async_tx.h                           |    3 +
 .../mach-bcm47xx =3D> include/linux}/bcm47xx_nvram.h |   19 +-
 include/linux/bitmap.h                             |   16 +-
 include/linux/bitops.h                             |    4 +-
 include/linux/blk-mq.h                             |    9 +-
 include/linux/capability.h                         |   29 +
 include/linux/ceph/ceph_features.h                 |   16 +-
 include/linux/ceph/ceph_fs.h                       |    1 +
 include/linux/ceph/debugfs.h                       |    8 +-
 include/linux/ceph/libceph.h                       |    2 +
 include/linux/ceph/osdmap.h                        |    5 +-
 include/linux/clk-provider.h                       |    2 +-
 include/linux/clk/at91_pmc.h                       |    4 +-
 include/linux/clk/shmobile.h                       |    1 +
 include/linux/clk/ti.h                             |    6 +-
 include/linux/clocksource.h                        |    6 +
 include/linux/compaction.h                         |    1 +
 include/linux/console.h                            |    3 +-
 include/linux/cpumask.h                            |  176 +-
 include/linux/cred.h                               |   23 +-
 include/linux/crush/crush.h                        |   12 +-
 include/linux/crypto.h                             |    6 +
 include/linux/dcache.h                             |   59 +-
 include/linux/device-mapper.h                      |    5 -
 include/linux/dma-buf.h                            |   34 +-
 include/linux/dma-mapping.h                        |    4 +
 include/linux/dma/hsu.h                            |   48 +
 include/linux/{amba =3D> dma}/xilinx_dma.h           |    0
 include/linux/dmaengine.h                          |   36 -
 include/linux/f2fs_fs.h                            |    3 +-
 include/linux/falloc.h                             |    6 +
 include/linux/fixp-arith.h                         |  145 +-
 include/linux/fs.h                                 |   93 +-
 include/linux/fs_pin.h                             |    2 +
 include/linux/gpio/consumer.h                      |   77 +
 include/linux/gpio/driver.h                        |   48 +
 include/linux/host1x.h                             |    1 +
 include/linux/hsi/hsi.h                            |    6 +-
 include/linux/hugetlb.h                            |   20 +-
 include/linux/hw_random.h                          |    4 +
 include/linux/hyperv.h                             |   37 +-
 include/linux/intel-iommu.h                        |   18 +-
 include/linux/io.h                                 |    2 +
 include/linux/iommu-common.h                       |   51 +
 include/linux/iommu.h                              |   33 +-
 include/linux/ioport.h                             |    8 -
 include/linux/irqchip/arm-gic-acpi.h               |   31 +
 include/linux/irqchip/mips-gic.h                   |    7 +
 include/linux/jz4780-nemc.h                        |   43 +
 include/linux/kasan.h                              |    2 +
 include/linux/kconfig.h                            |   24 +-
 include/linux/kernel.h                             |   12 +
 include/linux/ksm.h                                |   17 -
 include/linux/led-class-flash.h                    |   19 +-
 include/linux/leds.h                               |    5 +-
 include/linux/lguest.h                             |    4 +-
 include/linux/mempool.h                            |    3 +-
 include/linux/mfd/arizona/core.h                   |    2 +-
 include/linux/mfd/cros_ec.h                        |   23 +-
 include/linux/mfd/samsung/rtc.h                    |    2 +
 include/linux/mfd/syscon/atmel-st.h                |   49 +
 include/linux/mfd/syscon/imx6q-iomuxc-gpr.h        |    1 +
 include/linux/mfd/tmio.h                           |    2 +
 include/linux/miscdevice.h                         |    2 +
 include/linux/mlx4/device.h                        |    4 +
 include/linux/mm.h                                 |   98 +-
 include/linux/mm_types.h                           |    2 +-
 include/linux/mmc/card.h                           |   14 +-
 include/linux/mmc/sh_mobile_sdhi.h                 |   10 -
 include/linux/mmzone.h                             |    8 +-
 include/linux/mod_devicetable.h                    |    8 +
 include/linux/mount.h                              |    3 +-
 include/linux/mtd/map.h                            |   54 +-
 include/linux/mtd/spi-nor.h                        |    5 +
 include/linux/nbd.h                                |   46 -
 include/linux/netdevice.h                          |   12 +-
 include/linux/nfs4.h                               |    7 +
 include/linux/nfs_fs.h                             |    6 +-
 include/linux/nfs_xdr.h                            |    6 +
 include/linux/nvme.h                               |    5 +-
 include/linux/of.h                                 |   38 +
 include/linux/of_fdt.h                             |    2 +
 include/linux/of_graph.h                           |   20 +
 include/linux/of_irq.h                             |    9 +-
 include/linux/omap-gpmc.h                          |    3 +-
 include/linux/page-flags.h                         |  103 +
 include/linux/pci.h                                |   15 +
 include/linux/personality.h                        |   40 +-
 include/linux/platform_data/dma-hsu.h              |   25 +
 include/linux/platform_data/dma-imx-sdma.h         |    3 +
 include/linux/platform_data/mmc-msm_sdcc.h         |   27 -
 include/linux/platform_data/msm_serial_hs.h        |   49 -
 include/linux/platform_data/serial-imx.h           |    5 -
 .../platform_data/{tpm_stm_st33.h =3D> st33zp24.h}   |   21 +-
 include/linux/printk.h                             |    5 +
 include/linux/pstore.h                             |    1 +
 include/linux/qcom_scm.h                           |   28 +
 include/linux/quota.h                              |   90 +-
 include/linux/quotaops.h                           |   14 +-
 include/linux/raid/pq.h                            |    1 +
 include/linux/reboot.h                             |    3 +-
 include/linux/remoteproc.h                         |    2 +
 include/linux/rhashtable.h                         |    3 +-
 include/linux/rmap.h                               |    8 -
 include/linux/sched.h                              |    6 -
 include/linux/serial_8250.h                        |   20 +-
 include/linux/serial_core.h                        |   23 +-
 include/linux/serial_mfd.h                         |   47 -
 include/linux/shdma-base.h                         |    1 +
 include/linux/skbuff.h                             |   13 +
 include/linux/smp.h                                |    2 +-
 include/linux/stmmac.h                             |    2 +
 include/linux/string_helpers.h                     |   10 +-
 include/linux/sunrpc/msg_prot.h                    |    8 +-
 include/linux/sunrpc/xprtrdma.h                    |    5 -
 include/linux/swap.h                               |    2 +-
 include/linux/sysctl.h                             |    3 +
 include/linux/types.h                              |    6 -
 include/linux/uidgid.h                             |   12 +
 include/linux/uio.h                                |    8 +
 include/linux/util_macros.h                        |   40 +
 include/linux/virtio.h                             |    2 -
 include/linux/virtio_config.h                      |   16 +-
 include/linux/virtio_ring.h                        |   23 +-
 include/linux/wl12xx.h                             |   49 -
 include/linux/zsmalloc.h                           |    1 +
 include/media/adv7604.h                            |   83 +-
 include/media/davinci/vpfe_capture.h               |    2 +-
 include/media/media-entity.h                       |   21 +-
 include/media/mt9p031.h                            |    2 -
 include/media/omap3isp.h                           |   38 +-
 include/media/ov2659.h                             |   34 +
 include/media/saa7146_vv.h                         |    4 +-
 include/media/v4l2-clk.h                           |   10 +-
 include/media/v4l2-dev.h                           |    1 -
 include/media/v4l2-device.h                        |    2 -
 include/media/v4l2-ioctl.h                         |    6 -
 include/media/v4l2-of.h                            |   30 +
 include/media/v4l2-subdev.h                        |   55 +-
 include/media/videobuf2-core.h                     |   20 +-
 include/net/9p/client.h                            |    8 +-
 include/net/9p/transport.h                         |    2 +-
 include/net/bonding.h                              |    7 -
 include/net/inet_connection_sock.h                 |   20 +-
 include/net/netns/generic.h                        |    2 -
 include/net/request_sock.h                         |   18 -
 include/net/tcp.h                                  |    2 +-
 include/scsi/scsi_transport_fc.h                   |    1 +
 include/sound/ac97_codec.h                         |    4 +-
 include/sound/compress_driver.h                    |    4 +-
 include/sound/control.h                            |    2 +-
 include/sound/core.h                               |    3 +-
 include/sound/hda_regmap.h                         |  217 +
 include/sound/hdaudio.h                            |  247 +
 include/sound/pcm.h                                |   66 +-
 include/sound/pcm_params.h                         |    7 +
 include/sound/rt5670.h                             |    1 +
 include/sound/seq_device.h                         |   46 +-
 include/sound/seq_kernel.h                         |    6 +-
 include/sound/simple_card.h                        |    1 -
 include/sound/soc-dapm.h                           |    6 +-
 include/sound/soc-dpcm.h                           |    2 +-
 include/sound/soc.h                                |   32 +-
 include/target/iscsi/iscsi_target_core.h           |   15 +-
 include/target/target_core_base.h                  |   10 +-
 include/target/target_core_configfs.h              |    6 -
 include/target/target_core_fabric.h                |   33 +-
 include/target/target_core_fabric_configfs.h       |    5 +
 include/trace/events/btrfs.h                       |    4 +-
 include/trace/events/clk.h                         |  198 +
 include/trace/events/cma.h                         |   66 +
 include/trace/events/ext3.h                        |   16 +-
 include/trace/events/ext4.h                        |   16 +-
 include/trace/events/f2fs.h                        |  162 +-
 include/trace/events/filemap.h                     |    8 +-
 include/trace/events/kmem.h                        |   42 +-
 include/trace/events/vmscan.h                      |    8 +-
 include/uapi/asm-generic/errno.h                   |   11 +-
 include/uapi/drm/drm.h                             |    1 +
 include/uapi/drm/drm_fourcc.h                      |   78 +
 include/uapi/drm/drm_mode.h                        |    9 +
 include/uapi/drm/i915_drm.h                        |    5 +-
 include/uapi/drm/nouveau_drm.h                     |    1 +
 include/uapi/drm/radeon_drm.h                      |    4 +
 include/uapi/drm/tegra_drm.h                       |    3 +-
 include/uapi/linux/Kbuild                          |    2 +
 include/uapi/linux/am437x-vpfe.h                   |    2 +
 include/uapi/linux/bpf.h                           |    2 +-
 include/uapi/linux/dm-ioctl.h                      |    4 +-
 include/uapi/linux/falloc.h                        |   17 +
 include/uapi/linux/filter.h                        |    7 +-
 include/uapi/linux/kvm.h                           |    1 +
 include/uapi/linux/media-bus-format.h              |   28 +-
 include/uapi/linux/media.h                         |   52 +-
 include/uapi/linux/nfs4.h                          |    7 -
 include/uapi/linux/nfs_idmap.h                     |    2 +-
 include/uapi/linux/nfsd/debug.h                    |    8 -
 include/uapi/linux/nfsd/export.h                   |    3 +
 include/uapi/linux/quota.h                         |    6 +-
 include/uapi/linux/raid/md_p.h                     |    7 +
 include/uapi/linux/raid/md_u.h                     |    1 +
 include/uapi/linux/serial_reg.h                    |   19 -
 include/uapi/linux/target_core_user.h              |   44 +-
 include/uapi/linux/v4l2-dv-timings.h               |   64 +-
 include/uapi/linux/v4l2-subdev.h                   |   12 +-
 include/uapi/linux/videodev2.h                     |   18 +-
 include/uapi/linux/virtio_balloon.h                |   32 +-
 include/uapi/linux/virtio_ids.h                    |    1 +
 include/uapi/linux/virtio_input.h                  |   76 +
 include/uapi/linux/xilinx-v4l2-controls.h          |   73 +
 include/uapi/sound/asequencer.h                    |    1 +
 include/uapi/sound/asound.h                        |   41 +-
 include/uapi/sound/compress_offload.h              |    2 +-
 include/uapi/sound/emu10k1.h                       |    3 +-
 include/uapi/sound/hdspm.h                         |    6 +
 include/video/imx-ipu-v3.h                         |    2 +-
 include/video/omapdss.h                            |    7 +-
 include/video/samsung_fimd.h                       |   11 +
 include/xen/interface/xen.h                        |    6 +-
 include/xen/xen-ops.h                              |   47 +-
 include/xen/xenbus.h                               |   20 +-
 init/Kconfig                                       |   25 +-
 init/do_mounts.c                                   |    6 +-
 init/main.c                                        |    4 +-
 ipc/mqueue.c                                       |   22 +-
 ipc/msg.c                                          |   34 +-
 ipc/sem.c                                          |   26 +-
 ipc/shm.c                                          |   44 +-
 ipc/util.c                                         |    6 +-
 kernel/Makefile                                    |    4 +-
 kernel/acct.c                                      |    2 +-
 kernel/audit.c                                     |   49 +-
 kernel/audit.h                                     |    3 +
 kernel/audit_tree.c                                |   92 +-
 kernel/audit_watch.c                               |   14 +-
 kernel/auditsc.c                                   |   15 +-
 kernel/bpf/verifier.c                              |   12 +-
 kernel/capability.c                                |   35 +-
 kernel/cgroup.c                                    |    6 +-
 kernel/cred.c                                      |    3 +
 kernel/exec_domain.c                               |  137 +-
 kernel/exit.c                                      |    2 -
 kernel/fork.c                                      |  145 +-
 kernel/gcov/base.c                                 |    5 +-
 kernel/groups.c                                    |    3 -
 kernel/hung_task.c                                 |    4 +-
 kernel/locking/lockdep.c                           |   16 +-
 kernel/module.c                                    |    9 +-
 kernel/params.c                                    |    4 +-
 kernel/pid.c                                       |   15 +-
 kernel/printk/printk.c                             |   53 +-
 kernel/ptrace.c                                    |   39 +-
 kernel/reboot.c                                    |   53 +-
 kernel/relay.c                                     |    4 +-
 kernel/resource.c                                  |   32 -
 kernel/signal.c                                    |   14 +-
 kernel/smp.c                                       |   80 +-
 kernel/sys.c                                       |   49 +-
 kernel/sys_ni.c                                    |   14 +
 kernel/sysctl.c                                    |   25 +-
 kernel/time/clockevents.c                          |    2 +-
 kernel/trace/trace.c                               |    2 +-
 kernel/trace/trace_events.c                        |   19 +-
 kernel/trace/trace_functions_graph.c               |    8 +-
 kernel/trace/trace_stack.c                         |    4 +-
 kernel/trace/trace_uprobe.c                        |    2 +-
 lib/Kconfig                                        |    9 +-
 lib/Makefile                                       |    4 +-
 lib/bitmap.c                                       |   30 -
 lib/cpumask.c                                      |   37 +-
 lib/devres.c                                       |   28 +
 lib/dma-debug.c                                    |    2 +-
 lib/find_bit.c                                     |  193 +
 lib/find_last_bit.c                                |   36 +-
 lib/find_next_bit.c                                |  285 -
 lib/iommu-common.c                                 |  270 +
 lib/lru_cache.c                                    |    9 +-
 lib/raid6/algos.c                                  |   41 +-
 lib/raid6/altivec.uc                               |    1 +
 lib/raid6/avx2.c                                   |    3 +
 lib/raid6/int.uc                                   |   41 +-
 lib/raid6/mmx.c                                    |    2 +
 lib/raid6/neon.c                                   |    1 +
 lib/raid6/sse1.c                                   |    2 +
 lib/raid6/sse2.c                                   |  227 +
 lib/raid6/test/test.c                              |   51 +-
 lib/raid6/tilegx.uc                                |    1 +
 lib/rhashtable.c                                   |   11 +-
 lib/string.c                                       |    2 +-
 lib/string_helpers.c                               |  261 +-
 lib/test-hexdump.c                                 |   10 +-
 lib/test-string_helpers.c                          |   40 +-
 lib/vsprintf.c                                     |  352 +-
 mm/cma.c                                           |    5 +
 mm/cma_debug.c                                     |   41 +-
 mm/compaction.c                                    |   60 +-
 mm/filemap.c                                       |  114 +-
 mm/gup.c                                           |    4 +-
 mm/huge_memory.c                                   |   86 +-
 mm/hugetlb.c                                       |  234 +-
 mm/internal.h                                      |    4 +-
 mm/kasan/kasan.c                                   |   13 +
 mm/ksm.c                                           |   10 +-
 mm/memblock.c                                      |   18 +-
 mm/memcontrol.c                                    |   47 +-
 mm/memory-failure.c                                |  122 +-
 mm/memory.c                                        |   56 +-
 mm/memory_hotplug.c                                |    2 +-
 mm/mempool.c                                       |  117 +-
 mm/migrate.c                                       |    3 +-
 mm/mmap.c                                          |   21 +-
 mm/mremap.c                                        |   25 +-
 mm/nommu.c                                         |    4 +-
 mm/oom_kill.c                                      |    2 +-
 mm/page-writeback.c                                |    3 +-
 mm/page_alloc.c                                    |    6 +-
 mm/page_io.c                                       |    4 +-
 mm/rmap.c                                          |    6 +-
 mm/shmem.c                                         |   32 +-
 mm/slub.c                                          |    4 +-
 mm/swap.c                                          |   34 +-
 mm/swap_state.c                                    |    2 +-
 mm/swapfile.c                                      |    2 +-
 mm/truncate.c                                      |    2 +-
 mm/util.c                                          |   41 +-
 mm/vmalloc.c                                       |   95 +-
 mm/zsmalloc.c                                      | 1011 +++-
 net/9p/client.c                                    |  262 +-
 net/9p/protocol.c                                  |   28 +-
 net/9p/trans_common.c                              |   42 +-
 net/9p/trans_common.h                              |    2 -
 net/9p/trans_fd.c                                  |    3 +-
 net/9p/trans_rdma.c                                |   52 +-
 net/9p/trans_virtio.c                              |  142 +-
 net/bluetooth/hidp/core.c                          |    3 +-
 net/ceph/ceph_common.c                             |   37 +
 net/ceph/crush/crush.c                             |   14 +
 net/ceph/crush/crush_ln_table.h                    |  166 +
 net/ceph/crush/mapper.c                            |  118 +-
 net/ceph/debugfs.c                                 |   24 +
 net/ceph/messenger.c                               |   25 +-
 net/ceph/osdmap.c                                  |   25 +
 net/core/dev.c                                     |   14 +-
 net/core/filter.c                                  |   41 +-
 net/core/net_namespace.c                           |    1 -
 net/core/skbuff.c                                  |   40 +-
 net/dccp/ipv4.c                                    |    3 +-
 net/dccp/ipv6.c                                    |    3 +-
 net/dccp/minisocks.c                               |    3 +-
 net/dsa/dsa.c                                      |    6 +-
 net/ipv4/fou.c                                     |    3 +-
 net/ipv4/inet_connection_sock.c                    |   34 +
 net/ipv4/inet_diag.c                               |   28 +-
 net/ipv4/ip_forward.c                              |    3 +
 net/ipv4/tcp.c                                     |   14 +-
 net/ipv4/tcp_dctcp.c                               |    5 +-
 net/ipv4/tcp_illinois.c                            |    6 +-
 net/ipv4/tcp_input.c                               |    2 +
 net/ipv4/tcp_ipv4.c                                |    3 +-
 net/ipv4/tcp_minisocks.c                           |    7 +-
 net/ipv4/tcp_output.c                              |   64 +-
 net/ipv4/tcp_vegas.c                               |    5 +-
 net/ipv4/tcp_vegas.h                               |    2 +-
 net/ipv4/tcp_westwood.c                            |    6 +-
 net/ipv6/ip6_gre.c                                 |    9 +-
 net/ipv6/tcp_ipv6.c                                |    3 +-
 net/mpls/af_mpls.c                                 |  125 +-
 net/mpls/internal.h                                |    6 +
 net/netfilter/nft_reject.c                         |    2 +
 net/netfilter/nft_reject_inet.c                    |    2 +
 net/netlink/af_netlink.c                           |    6 +-
 net/sched/act_bpf.c                                |    3 +
 net/sched/act_mirred.c                             |    2 +-
 net/sched/cls_bpf.c                                |    3 +
 net/socket.c                                       |    8 +-
 net/sunrpc/Kconfig                                 |    2 +
 net/sunrpc/cache.c                                 |    8 +-
 net/sunrpc/rpc_pipe.c                              |   32 +-
 net/sunrpc/sched.c                                 |    4 +-
 net/sunrpc/xprt.c                                  |   22 +-
 net/sunrpc/xprtrdma/Makefile                       |    3 +-
 net/sunrpc/xprtrdma/fmr_ops.c                      |  208 +
 net/sunrpc/xprtrdma/frwr_ops.c                     |  353 ++
 net/sunrpc/xprtrdma/physical_ops.c                 |   94 +
 net/sunrpc/xprtrdma/rpc_rdma.c                     |   87 +-
 net/sunrpc/xprtrdma/transport.c                    |   61 +-
 net/sunrpc/xprtrdma/verbs.c                        |  699 +--
 net/sunrpc/xprtrdma/xprt_rdma.h                    |   90 +-
 net/tipc/link.c                                    |    1 -
 net/tipc/server.c                                  |    9 +-
 net/tipc/socket.c                                  |    3 +-
 net/unix/af_unix.c                                 |    8 +-
 net/unix/diag.c                                    |    2 +-
 net/unix/garbage.c                                 |   70 +-
 samples/bpf/tcbpf1_kern.c                          |   16 +-
 samples/bpf/test_verifier.c                        |   22 +
 scripts/Makefile.dtbinst                           |    2 +-
 scripts/Makefile.fwinst                            |    2 +-
 scripts/Makefile.kasan                             |    8 +-
 scripts/Makefile.lib                               |    3 +-
 scripts/check_extable.sh                           |  146 +
 scripts/checkkconfigsymbols.py                     |  147 +-
 scripts/checkpatch.pl                              |  164 +-
 scripts/coccinelle/misc/irqf_oneshot.cocci         |   24 +
 scripts/extract-ikconfig                           |    1 +
 scripts/kallsyms.c                                 |   29 +-
 scripts/kconfig/Makefile                           |   80 +-
 scripts/kconfig/conf.c                             |    8 +-
 scripts/kconfig/confdata.c                         |    5 +
 scripts/kconfig/expr.c                             |   22 +-
 scripts/kconfig/expr.h                             |    5 -
 scripts/kconfig/gconf.c                            |   29 +-
 scripts/kconfig/lkc.h                              |   14 -
 scripts/kconfig/lkc_proto.h                        |   85 +-
 scripts/kconfig/mconf.c                            |   31 +-
 scripts/kconfig/menu.c                             |    4 +-
 scripts/kconfig/merge_config.sh                    |   27 +-
 scripts/kconfig/nconf.c                            |    5 +
 scripts/kconfig/qconf.cc                           |    5 +-
 scripts/kconfig/symbol.c                           |   42 +-
 scripts/kconfig/util.c                             |   10 -
 scripts/mod/devicetable-offsets.c                  |    3 +
 scripts/mod/file2alias.c                           |   16 +
 scripts/mod/modpost.c                              |  341 +-
 scripts/spelling.txt                               |    1 +
 scripts/xen-hypercalls.sh                          |   12 +
 security/Kconfig                                   |    1 +
 security/apparmor/apparmorfs.c                     |    2 +-
 security/apparmor/file.c                           |    6 +-
 security/apparmor/lsm.c                            |   18 +-
 security/commoncap.c                               |    6 +-
 security/inode.c                                   |   18 +-
 security/integrity/evm/evm_crypto.c                |    4 +-
 security/integrity/evm/evm_main.c                  |   18 +-
 security/integrity/ima/ima_appraise.c              |   10 +-
 security/lsm_audit.c                               |   19 +-
 security/security.c                                |   50 +-
 security/selinux/avc.c                             |    6 +-
 security/selinux/hooks.c                           |   36 +-
 security/selinux/selinuxfs.c                       |    2 +-
 security/selinux/ss/avtab.c                        |   72 +-
 security/selinux/ss/avtab.h                        |    8 +-
 security/selinux/ss/mls.c                          |   10 +-
 security/selinux/ss/services.c                     |    6 +-
 security/smack/smack.h                             |    8 +
 security/smack/smack_access.c                      |   43 +-
 security/smack/smack_lsm.c                         |  145 +-
 security/smack/smackfs.c                           |   99 +-
 security/tomoyo/.gitignore                         |    2 +-
 security/tomoyo/Kconfig                            |    1 +
 security/tomoyo/Makefile                           |   55 +-
 security/tomoyo/condition.c                        |    2 +-
 .../tomoyo/policy/exception_policy.conf.default    |    2 +
 security/tomoyo/realpath.c                         |   10 +-
 security/tomoyo/util.c                             |   13 +-
 security/yama/Kconfig                              |    2 -
 security/yama/yama_lsm.c                           |   13 +-
 sound/Kconfig                                      |    2 +
 sound/Makefile                                     |    2 +-
 sound/aoa/soundbus/i2sbus/core.c                   |    2 +-
 sound/core/control.c                               |  329 +-
 sound/core/device.c                                |   47 +-
 sound/core/hwdep.c                                 |    4 +-
 sound/core/init.c                                  |    5 +-
 sound/core/oss/mixer_oss.c                         |    4 +-
 sound/core/oss/pcm_oss.c                           |    1 -
 sound/core/pcm.c                                   |  105 +-
 sound/core/pcm_compat.c                            |   28 +-
 sound/core/pcm_dmaengine.c                         |    4 +-
 sound/core/pcm_lib.c                               |   88 +-
 sound/core/pcm_native.c                            |   80 +-
 sound/core/rawmidi.c                               |    8 +-
 sound/core/seq/oss/seq_oss.c                       |   22 +-
 sound/core/seq/oss/seq_oss_init.c                  |    4 +-
 sound/core/seq/oss/seq_oss_midi.c                  |    5 +-
 sound/core/seq/oss/seq_oss_readq.c                 |    9 +-
 sound/core/seq/oss/seq_oss_synth.c                 |   12 +-
 sound/core/seq/oss/seq_oss_synth.h                 |    4 +-
 sound/core/seq/seq_clientmgr.c                     |    1 +
 sound/core/seq/seq_device.c                        |  571 +--
 sound/core/seq/seq_dummy.c                         |    6 +-
 sound/core/seq/seq_fifo.c                          |    4 +-
 sound/core/seq/seq_memory.c                        |    8 +-
 sound/core/seq/seq_midi.c                          |   36 +-
 sound/core/seq/seq_ports.c                         |    4 +-
 sound/core/seq/seq_prioq.c                         |    4 +-
 sound/core/seq/seq_queue.c                         |    4 +-
 sound/core/seq/seq_timer.c                         |    4 +-
 sound/core/sound.c                                 |   14 +-
 sound/core/timer.c                                 |    4 +-
 sound/drivers/opl3/opl3_seq.c                      |   34 +-
 sound/drivers/opl4/opl4_seq.c                      |   33 +-
 sound/firewire/amdtp.c                             |    8 +-
 sound/firewire/fireworks/fireworks_transaction.c   |    2 +-
 sound/hda/Kconfig                                  |    3 +
 sound/hda/Makefile                                 |    7 +
 sound/hda/array.c                                  |   49 +
 sound/hda/hda_bus_type.c                           |   42 +
 sound/hda/hdac_bus.c                               |  186 +
 sound/hda/hdac_device.c                            |  599 +++
 sound/hda/hdac_regmap.c                            |  472 ++
 sound/hda/hdac_sysfs.c                             |  406 ++
 sound/hda/local.h                                  |   23 +
 sound/hda/trace.c                                  |    6 +
 sound/hda/trace.h                                  |   62 +
 sound/i2c/other/ak4113.c                           |    4 +-
 sound/isa/sb/emu8000_synth.c                       |   35 +-
 sound/isa/wavefront/wavefront_fx.c                 |    6 +-
 sound/isa/wavefront/wavefront_synth.c              |   26 +-
 sound/mips/au1x00.c                                |   12 +-
 sound/oss/dev_table.c                              |    6 +-
 sound/oss/opl3.c                                   |    4 +-
 sound/oss/sb_ess.c                                 |   19 +-
 sound/oss/sb_midi.c                                |    6 +-
 sound/oss/sequencer.c                              |   12 +-
 sound/oss/sys_timer.c                              |   35 +-
 sound/oss/v_midi.c                                 |    4 +-
 sound/pci/ac97/ac97_codec.c                        |    4 +-
 sound/pci/ac97/ac97_patch.c                        |   27 +
 sound/pci/ad1889.c                                 |    2 +-
 sound/pci/asihpi/asihpi.c                          |    2 +-
 sound/pci/atiixp.c                                 |    2 +-
 sound/pci/azt3328.c                                |    7 +-
 sound/pci/cmipci.c                                 |    2 +-
 sound/pci/cs5535audio/cs5535audio.c                |    2 +-
 sound/pci/echoaudio/echoaudio.c                    |   16 +-
 sound/pci/emu10k1/emu10k1_main.c                   |   25 +
 sound/pci/emu10k1/emu10k1_synth.c                  |   35 +-
 sound/pci/emu10k1/emumixer.c                       |  118 +
 sound/pci/emu10k1/emuproc.c                        |   12 -
 sound/pci/hda/Kconfig                              |    1 +
 sound/pci/hda/Makefile                             |    3 +-
 sound/pci/hda/hda_auto_parser.c                    |   33 +-
 sound/pci/hda/hda_beep.c                           |   37 +-
 sound/pci/hda/hda_beep.h                           |    1 +
 sound/pci/hda/hda_bind.c                           |  273 +
 sound/pci/hda/hda_codec.c                          | 2327 ++-------
 sound/pci/hda/hda_codec.h                          |  288 +-
 sound/pci/hda/hda_controller.c                     |  269 +-
 sound/pci/hda/hda_controller.h                     |  397 +-
 sound/pci/hda/hda_generic.c                        |  599 ++-
 sound/pci/hda/hda_generic.h                        |    9 +-
 sound/pci/hda/hda_hwdep.c                          |    5 +-
 sound/pci/hda/hda_i915.c                           |    8 +-
 sound/pci/hda/hda_intel.c                          |  104 +-
 sound/pci/hda/hda_intel.h                          |    2 +-
 sound/pci/hda/hda_jack.c                           |    8 +-
 sound/pci/hda/hda_local.h                          |  123 +-
 sound/pci/hda/hda_priv.h                           |  406 --
 sound/pci/hda/hda_proc.c                           |   80 +-
 sound/pci/hda/hda_sysfs.c                          |   62 +-
 sound/pci/hda/hda_tegra.c                          |   50 +-
 sound/pci/hda/hda_trace.h                          |  143 -
 sound/pci/hda/local.h                              |   39 +
 sound/pci/hda/patch_analog.c                       |   34 +-
 sound/pci/hda/patch_ca0110.c                       |   16 +-
 sound/pci/hda/patch_ca0132.c                       |   68 +-
 sound/pci/hda/patch_cirrus.c                       |   16 +-
 sound/pci/hda/patch_cmedia.c                       |   16 +-
 sound/pci/hda/patch_conexant.c                     |   41 +-
 sound/pci/hda/patch_hdmi.c                         |   99 +-
 sound/pci/hda/patch_realtek.c                      |  338 +-
 sound/pci/hda/patch_si3054.c                       |   37 +-
 sound/pci/hda/patch_sigmatel.c                     |  138 +-
 sound/pci/hda/patch_via.c                          |  778 +--
 sound/pci/hda/thinkpad_helper.c                    |    2 +-
 sound/pci/ice1712/wtm.c                            |  172 +-
 sound/pci/intel8x0.c                               |    6 +-
 sound/pci/rme9652/hdspm.c                          |  141 +-
 sound/pci/via82xx.c                                |    2 +-
 sound/ppc/pmac.c                                   |   58 +-
 sound/soc/Kconfig                                  |    1 +
 sound/soc/Makefile                                 |    1 +
 sound/soc/atmel/Kconfig                            |    9 +-
 sound/soc/atmel/Makefile                           |    2 -
 sound/soc/atmel/atmel-pcm-dma.c                    |    4 +-
 sound/soc/atmel/atmel-pcm-pdc.c                    |   79 +
 sound/soc/atmel/atmel-pcm.c                        |  121 -
 sound/soc/atmel/atmel-pcm.h                        |    5 -
 sound/soc/atmel/atmel_ssc_dai.c                    |  111 +-
 sound/soc/atmel/atmel_ssc_dai.h                    |    1 +
 sound/soc/codecs/Kconfig                           |   22 +-
 sound/soc/codecs/Makefile                          |    6 +
 sound/soc/codecs/ab8500-codec.c                    |    2 -
 sound/soc/codecs/adau1977.c                        |   17 +-
 sound/soc/codecs/ak4554.c                          |    2 +-
 sound/soc/codecs/ak4642.c                          |   41 +-
 sound/soc/codecs/arizona.c                         |   10 +-
 sound/soc/codecs/cs35l32.c                         |   19 +-
 sound/soc/codecs/cs4265.c                          |   19 +-
 sound/soc/codecs/cs4271.c                          |    4 +-
 sound/soc/codecs/cx20442.c                         |    4 +-
 sound/soc/codecs/max98090.c                        |   17 +
 sound/soc/codecs/max98357a.c                       |   11 +-
 sound/soc/codecs/max98925.c                        |  655 +++
 sound/soc/codecs/max98925.h                        |  832 +++
 sound/soc/codecs/pcm512x.c                         |  189 +-
 sound/soc/codecs/rt286.c                           |   40 +-
 sound/soc/codecs/rt5631.c                          |    2 +-
 sound/soc/codecs/rt5645.c                          |   90 +-
 sound/soc/codecs/rt5645.h                          |    2 -
 sound/soc/codecs/rt5670.c                          |  213 +-
 sound/soc/codecs/rt5670.h                          |   10 +
 sound/soc/codecs/rt5677.c                          |  207 +-
 sound/soc/codecs/rt5677.h                          |   85 +
 sound/soc/codecs/sn95031.c                         |   14 +-
 sound/soc/codecs/sn95031.h                         |    3 +-
 sound/soc/codecs/sta350.c                          |   30 +-
 sound/soc/codecs/tas2552.c                         |   13 +-
 sound/soc/codecs/tlv320aic23-i2c.c                 |    4 +-
 sound/soc/codecs/wm2200.c                          |    9 +-
 sound/soc/codecs/wm5100.c                          |    7 +-
 sound/soc/codecs/wm5102.c                          |    1 -
 sound/soc/codecs/wm8350.c                          |   25 +-
 sound/soc/codecs/wm8731.c                          |   34 +
 sound/soc/codecs/wm8741.c                          |    8 +-
 sound/soc/codecs/wm8753.c                          |   73 +-
 sound/soc/codecs/wm8804-i2c.c                      |   65 +
 sound/soc/codecs/wm8804-spi.c                      |   57 +
 sound/soc/codecs/wm8804.c                          |  534 +-
 sound/soc/codecs/wm8804.h                          |    8 +
 sound/soc/codecs/wm8971.c                          |   99 +-
 sound/soc/codecs/wm8996.c                          |   12 +-
 sound/soc/codecs/wm_adsp.c                         |   13 +-
 sound/soc/davinci/Kconfig                          |   18 +-
 sound/soc/davinci/Makefile                         |    2 -
 sound/soc/davinci/davinci-evm.c                    |   17 +-
 sound/soc/davinci/davinci-i2s.c                    |   67 +-
 sound/soc/davinci/davinci-mcasp.c                  |  335 +-
 sound/soc/davinci/davinci-pcm.c                    |  861 ----
 sound/soc/davinci/davinci-pcm.h                    |   41 -
 sound/soc/davinci/davinci-vcif.c                   |   55 +-
 sound/soc/fsl/Kconfig                              |    4 +-
 sound/soc/fsl/fsl-asoc-card.c                      |    6 +
 sound/soc/fsl/fsl_ssi.c                            |   32 +-
 sound/soc/fsl/imx-es8328.c                         |    6 +-
 sound/soc/fsl/mpc5200_psc_ac97.c                   |    2 +-
 sound/soc/fsl/mpc5200_psc_i2s.c                    |    2 +-
 sound/soc/fsl/pcm030-audio-fabric.c                |    2 +-
 sound/soc/fsl/wm1133-ev1.c                         |   15 +-
 sound/soc/generic/simple-card.c                    |   50 +-
 sound/soc/intel/Makefile                           |   42 +-
 sound/soc/intel/atom/Makefile                      |    7 +
 sound/soc/intel/{ =3D> atom}/sst-atom-controls.c     |    0
 sound/soc/intel/{ =3D> atom}/sst-atom-controls.h     |    0
 sound/soc/intel/{ =3D> atom}/sst-mfld-dsp.h          |    0
 .../intel/{ =3D> atom}/sst-mfld-platform-compress.c  |    0
 sound/soc/intel/{ =3D> atom}/sst-mfld-platform-pcm.c |   60 +
 sound/soc/intel/{ =3D> atom}/sst-mfld-platform.h     |    1 +
 sound/soc/intel/{ =3D> atom}/sst/Makefile            |    0
 sound/soc/intel/{ =3D> atom}/sst/sst.c               |  130 +-
 sound/soc/intel/{ =3D> atom}/sst/sst.h               |   12 +
 sound/soc/intel/{ =3D> atom}/sst/sst_acpi.c          |    4 +-
 sound/soc/intel/{ =3D> atom}/sst/sst_drv_interface.c |   69 +-
 sound/soc/intel/{ =3D> atom}/sst/sst_ipc.c           |    2 +-
 sound/soc/intel/{ =3D> atom}/sst/sst_loader.c        |   12 +-
 sound/soc/intel/{ =3D> atom}/sst/sst_pci.c           |    0
 sound/soc/intel/{ =3D> atom}/sst/sst_pvt.c           |   26 +-
 sound/soc/intel/{ =3D> atom}/sst/sst_stream.c        |    2 +-
 sound/soc/intel/baytrail/Makefile                  |    4 +
 sound/soc/intel/{ =3D> baytrail}/sst-baytrail-dsp.c  |    4 +-
 sound/soc/intel/{ =3D> baytrail}/sst-baytrail-ipc.c  |  364 +-
 sound/soc/intel/{ =3D> baytrail}/sst-baytrail-ipc.h  |    0
 sound/soc/intel/{ =3D> baytrail}/sst-baytrail-pcm.c  |    4 +-
 sound/soc/intel/boards/Makefile                    |   15 +
 sound/soc/intel/{ =3D> boards}/broadwell.c           |   50 +-
 sound/soc/intel/{ =3D> boards}/byt-max98090.c        |   13 +-
 sound/soc/intel/{ =3D> boards}/byt-rt5640.c          |    4 +-
 .../{bytcr_dpcm_rt5640.c =3D> boards/bytcr_rt5640.c} |    8 +-
 sound/soc/intel/{ =3D> boards}/cht_bsw_rt5645.c      |   20 +-
 sound/soc/intel/{ =3D> boards}/cht_bsw_rt5672.c      |  108 +-
 sound/soc/intel/{ =3D> boards}/haswell.c             |   10 +-
 sound/soc/intel/{ =3D> boards}/mfld_machine.c        |   24 +-
 sound/soc/intel/common/Makefile                    |    7 +
 sound/soc/intel/{ =3D> common}/sst-acpi.c            |    1 +
 sound/soc/intel/{ =3D> common}/sst-dsp-priv.h        |   13 +
 sound/soc/intel/{ =3D> common}/sst-dsp.c             |    0
 sound/soc/intel/{ =3D> common}/sst-dsp.h             |    2 +-
 sound/soc/intel/{ =3D> common}/sst-firmware.c        |   10 +-
 sound/soc/intel/common/sst-ipc.c                   |  294 ++
 sound/soc/intel/common/sst-ipc.h                   |   91 +
 sound/soc/intel/haswell/Makefile                   |    4 +
 sound/soc/intel/{ =3D> haswell}/sst-haswell-dsp.c    |    9 +-
 sound/soc/intel/{ =3D> haswell}/sst-haswell-ipc.c    |  794 +--
 sound/soc/intel/{ =3D> haswell}/sst-haswell-ipc.h    |   53 +
 sound/soc/intel/{ =3D> haswell}/sst-haswell-pcm.c    |  140 +-
 sound/soc/jz4740/jz4740-i2s.c                      |   84 +-
 sound/soc/kirkwood/kirkwood-i2s.c                  |    2 +-
 sound/soc/nuc900/nuc900-audio.h                    |    3 -
 sound/soc/nuc900/nuc900-pcm.c                      |   31 +-
 sound/soc/omap/Kconfig                             |    4 +-
 sound/soc/omap/ams-delta.c                         |    4 +-
 sound/soc/omap/n810.c                              |   23 +-
 sound/soc/omap/omap-abe-twl6040.c                  |   10 +-
 sound/soc/omap/omap-hdmi-audio.c                   |    2 -
 sound/soc/omap/omap-pcm.c                          |   21 +-
 sound/soc/omap/omap-twl4030.c                      |   12 +-
 sound/soc/omap/rx51.c                              |    6 +-
 sound/soc/pxa/hx4700.c                             |   11 +-
 sound/soc/pxa/palm27x.c                            |   11 +-
 sound/soc/pxa/ttc-dkb.c                            |   15 +-
 sound/soc/pxa/z2.c                                 |   10 +-
 sound/soc/qcom/Kconfig                             |   25 +
 sound/soc/qcom/Makefile                            |   11 +
 sound/soc/qcom/lpass-cpu.c                         |  491 ++
 sound/soc/qcom/lpass-lpaif-ipq806x.h               |  172 +
 sound/soc/qcom/lpass-platform.c                    |  526 ++
 sound/soc/qcom/lpass.h                             |   51 +
 sound/soc/qcom/storm.c                             |  162 +
 sound/soc/samsung/h1940_uda1380.c                  |    9 +-
 sound/soc/samsung/littlemill.c                     |   12 +-
 sound/soc/samsung/lowland.c                        |   14 +-
 sound/soc/samsung/rx1950_uda1380.c                 |    9 +-
 sound/soc/samsung/smartq_wm8987.c                  |   11 +-
 sound/soc/samsung/speyside.c                       |   14 +-
 sound/soc/samsung/tobermory.c                      |   13 +-
 sound/soc/sh/Kconfig                               |    6 +
 sound/soc/sh/fsi.c                                 |   89 +-
 sound/soc/sh/rcar/Makefile                         |    7 +-
 sound/soc/sh/rcar/adg.c                            |    4 +-
 sound/soc/sh/rcar/core.c                           |  278 +-
 sound/soc/sh/rcar/dma.c                            |  616 +++
 sound/soc/sh/rcar/dvc.c                            |   45 +-
 sound/soc/sh/rcar/gen.c                            |  152 +-
 sound/soc/sh/rcar/rsnd.h                           |   92 +-
 sound/soc/sh/rcar/rsrc-card.c                      |  512 ++
 sound/soc/sh/rcar/src.c                            |  250 +-
 sound/soc/sh/rcar/ssi.c                            |   73 +-
 sound/soc/soc-core.c                               |  124 +-
 sound/soc/soc-dapm.c                               |  182 +-
 sound/soc/soc-jack.c                               |   42 +-
 sound/soc/soc-pcm.c                                |   17 +-
 sound/soc/tegra/tegra_alc5632.c                    |   14 +-
 sound/soc/tegra/tegra_max98090.c                   |   26 +-
 sound/soc/tegra/tegra_rt5640.c                     |   10 +-
 sound/soc/tegra/tegra_rt5677.c                     |   20 +-
 sound/soc/tegra/tegra_wm8903.c                     |   21 +-
 sound/soc/tegra/tegra_wm9712.c                     |    6 +-
 sound/soc/ux500/mop500_ab8500.c                    |   36 +-
 sound/usb/format.c                                 |    5 +-
 sound/usb/quirks-table.h                           |   30 +-
 sound/usb/quirks.c                                 |   41 +-
 tools/hv/Makefile                                  |    2 +-
 tools/hv/hv_vss_daemon.c                           |   10 +-
 tools/perf/Documentation/perf-kmem.txt             |    8 +-
 tools/perf/builtin-kmem.c                          |  500 +-
 tools/perf/util/probe-event.c                      |   60 +-
 tools/perf/util/probe-finder.c                     |   73 +-
 tools/perf/util/probe-finder.h                     |    4 +
 .../acpi/os_specific/service_layers/oslinuxtbl.c   |    2 +-
 .../acpi/os_specific/service_layers/osunixmap.c    |    2 +-
 tools/power/cpupower/utils/helpers/pci.c           |   11 +-
 tools/power/x86/turbostat/Makefile                 |    6 +-
 tools/power/x86/turbostat/turbostat.8              |  138 +-
 tools/power/x86/turbostat/turbostat.c              |  436 +-
 tools/testing/selftests/powerpc/Makefile           |   16 +-
 tools/testing/selftests/powerpc/copyloops/Makefile |    1 +
 .../selftests/powerpc/copyloops/asm/ppc_asm.h      |   33 -
 tools/testing/selftests/powerpc/harness.c          |   47 +
 .../selftests/powerpc/mm/hugetlb_vs_thp_test.c     |    8 +-
 tools/testing/selftests/powerpc/pmu/lib.c          |   47 -
 tools/testing/selftests/powerpc/pmu/lib.h          |    1 -
 .../selftests/powerpc/switch_endian/.gitignore     |    2 +
 .../selftests/powerpc/switch_endian/Makefile       |   24 +
 .../selftests/powerpc/switch_endian/check.S        |  100 +
 .../selftests/powerpc/switch_endian/common.h       |    6 +
 .../powerpc/switch_endian/switch_endian_test.S     |   81 +
 tools/testing/selftests/powerpc/tm/.gitignore      |    1 +
 tools/testing/selftests/powerpc/tm/Makefile        |    5 +-
 .../testing/selftests/powerpc/tm/tm-syscall-asm.S  |   27 +
 tools/testing/selftests/powerpc/tm/tm-syscall.c    |  121 +
 tools/testing/selftests/powerpc/utils.h            |    3 +-
 tools/testing/selftests/powerpc/vphn/.gitignore    |    1 +
 tools/testing/selftests/powerpc/vphn/Makefile      |   15 +
 tools/testing/selftests/powerpc/vphn/test-vphn.c   |  410 ++
 tools/testing/selftests/powerpc/vphn/vphn.c        |    1 +
 tools/testing/selftests/powerpc/vphn/vphn.h        |    1 +
 tools/testing/selftests/vm/hugetlbfstest.c         |    4 +-
 tools/testing/selftests/vm/map_hugetlb.c           |    6 +-
 tools/testing/selftests/x86/Makefile               |    2 +-
 tools/testing/selftests/x86/run_x86_tests.sh       |    2 +
 tools/testing/selftests/x86/single_step_syscall.c  |  181 +
 virt/kvm/arm/vgic.c                                |    5 +-
 virt/kvm/kvm_main.c                                |    1 +
 5332 files changed, 222035 insertions(+), 118488 deletions(-)
 create mode 100644 Documentation/ABI/obsolete/sysfs-block-zram
 create mode 100644 Documentation/ABI/testing/sysfs-class-led-flash
 create mode 100644 Documentation/ABI/testing/sysfs-platform-dell-lapto=
p
 delete mode 100644 Documentation/arm/Makefile
 delete mode 100644 Documentation/arm/SH-Mobile/Makefile
 delete mode 100644 Documentation/arm/SH-Mobile/vrl4.c
 delete mode 100644 Documentation/arm/SH-Mobile/zboot-rom-mmcif.txt
 delete mode 100644 Documentation/arm/SH-Mobile/zboot-rom-sdhi.txt
 delete mode 100644 Documentation/arm/msm/gpiomux.txt
 create mode 100644 Documentation/arm64/acpi_object_usage.txt
 create mode 100644 Documentation/arm64/arm-acpi.txt
 delete mode 100644 Documentation/crypto/crypto-API-userspace.txt
 create mode 100644 Documentation/device-mapper/log-writes.txt
 create mode 100644 Documentation/devicetree/bindings/arc/pct.txt
 delete mode 100644 Documentation/devicetree/bindings/arc/pmu.txt
 create mode 100644 Documentation/devicetree/bindings/arm/al,alpine.txt
 create mode 100644 Documentation/devicetree/bindings/arm/altera.txt
 create mode 100644 Documentation/devicetree/bindings/arm/armada-39x.tx=
t
 rename Documentation/devicetree/bindings/arm/bcm/{brcm,bcm11351-cpu-me=
thod =3D> brcm,bcm11351-cpu-method.txt} (100%)
 rename Documentation/devicetree/bindings/arm/bcm/{bcm11351.txt =3D> br=
cm,bcm11351.txt} (100%)
 rename Documentation/devicetree/bindings/arm/bcm/{bcm21664.txt =3D> br=
cm,bcm21664.txt} (100%)
 rename Documentation/devicetree/bindings/arm/{bcm2835.txt =3D> bcm/brc=
m,bcm2835.txt} (100%)
 rename Documentation/devicetree/bindings/arm/{bcm4708.txt =3D> bcm/brc=
m,bcm4708.txt} (100%)
 rename Documentation/devicetree/bindings/arm/bcm/{bcm63138.txt =3D> br=
cm,bcm63138.txt} (100%)
 rename Documentation/devicetree/bindings/arm/{brcm-brcmstb.txt =3D> bc=
m/brcm,brcmstb.txt} (100%)
 rename Documentation/devicetree/bindings/arm/bcm/{cygnus.txt =3D> brcm=
,cygnus.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/arm/cpu-enable-me=
thod/al,alpine-smp
 delete mode 100644 Documentation/devicetree/bindings/arm/geniatech.txt
 create mode 100644 Documentation/devicetree/bindings/arm/msm/qcom,idle=
-state.txt
 create mode 100644 Documentation/devicetree/bindings/arm/omap/ctrl.txt
 create mode 100644 Documentation/devicetree/bindings/arm/omap/l4.txt
 create mode 100644 Documentation/devicetree/bindings/arm/tegra/nvidia,=
tegra30-actmon.txt
 rename Documentation/devicetree/bindings/bus/{bcma.txt =3D> brcm,bus-a=
xi.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/bus/renesas,bsc.t=
xt
 create mode 100644 Documentation/devicetree/bindings/bus/simple-pm-bus=
=2Etxt
 rename Documentation/devicetree/bindings/clock/{bcm-kona-clock.txt =3D=
> brcm,kona-ccu.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/clock/exynos5433-=
clock.txt
 create mode 100644 Documentation/devicetree/bindings/clock/fujitsu,mb8=
6s70-crg11.txt
 create mode 100644 Documentation/devicetree/bindings/clock/pistachio-c=
lock.txt
 create mode 100644 Documentation/devicetree/bindings/clock/pwm-clock.t=
xt
 create mode 100644 Documentation/devicetree/bindings/clock/renesas,r8a=
7778-cpg-clocks.txt
 create mode 100644 Documentation/devicetree/bindings/common-properties=
=2Etxt
 create mode 100644 Documentation/devicetree/bindings/cris/axis.txt
 create mode 100644 Documentation/devicetree/bindings/cris/boards.txt
 create mode 100644 Documentation/devicetree/bindings/cris/interrupts.t=
xt
 create mode 100644 Documentation/devicetree/bindings/crypto/img-hash.t=
xt
 create mode 100644 Documentation/devicetree/bindings/dma/apm-xgene-dma=
=2Etxt
 rename Documentation/devicetree/bindings/dma/{bcm2835-dma.txt =3D> brc=
m,bcm2835-dma.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/dma/jz4780-dma.tx=
t
 delete mode 100644 Documentation/devicetree/bindings/dma/rcar-audmapp.=
txt
 create mode 100644 Documentation/devicetree/bindings/dma/renesas,usb-d=
mac.txt
 create mode 100644 Documentation/devicetree/bindings/extcon/extcon-usb=
-gpio.txt
 rename Documentation/devicetree/bindings/gpio/{gpio-bcm-kona.txt =3D> =
brcm,kona-gpio.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/gpio/gpio-altera.=
txt
 create mode 100644 Documentation/devicetree/bindings/hwrng/brcm,iproc-=
rng200.txt
 rename Documentation/devicetree/bindings/i2c/{i2c-bcm-kona.txt =3D> br=
cm,kona-i2c.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/interrupt-control=
ler/brcm,bcm3380-l2-intc.txt
 create mode 100644 Documentation/devicetree/bindings/interrupt-control=
ler/brcm,bcm7038-l1-intc.txt
 create mode 100644 Documentation/devicetree/bindings/interrupt-control=
ler/cdns,xtensa-mx.txt
 create mode 100644 Documentation/devicetree/bindings/interrupt-control=
ler/cdns,xtensa-pic.txt
 create mode 100644 Documentation/devicetree/bindings/leds/leds-pm8941-=
wled.txt
 create mode 100644 Documentation/devicetree/bindings/mailbox/arm-mhu.t=
xt
 create mode 100644 Documentation/devicetree/bindings/media/i2c/mt9v032=
=2Etxt
 create mode 100644 Documentation/devicetree/bindings/media/i2c/ov2640.=
txt
 create mode 100644 Documentation/devicetree/bindings/media/i2c/ov2659.=
txt
 create mode 100644 Documentation/devicetree/bindings/media/ti,omap3isp=
=2Etxt
 create mode 100644 Documentation/devicetree/bindings/media/xilinx/vide=
o.txt
 create mode 100644 Documentation/devicetree/bindings/media/xilinx/xlnx=
,v-tc.txt
 create mode 100644 Documentation/devicetree/bindings/media/xilinx/xlnx=
,v-tpg.txt
 create mode 100644 Documentation/devicetree/bindings/media/xilinx/xlnx=
,video.txt
 create mode 100644 Documentation/devicetree/bindings/memory-controller=
s/ingenic,jz4780-nemc.txt
 rename Documentation/devicetree/bindings/mfd/{bcm590xx.txt =3D> brcm,b=
cm59056.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/mfd/qcom,tcsr.txt
 delete mode 100644 Documentation/devicetree/bindings/mips/brcm/bcm3384=
-intc.txt
 rename Documentation/devicetree/bindings/mips/brcm/{bmips.txt =3D> brc=
m,bmips.txt} (100%)
 delete mode 100644 Documentation/devicetree/bindings/mips/brcm/cm-dsl.=
txt
 create mode 100644 Documentation/devicetree/bindings/mips/brcm/soc.txt
 create mode 100644 Documentation/devicetree/bindings/mips/img/pistachi=
o.txt
 rename Documentation/devicetree/bindings/misc/{smc.txt =3D> brcm,kona-=
smc.txt} (100%)
 rename Documentation/devicetree/bindings/mmc/{kona-sdhci.txt =3D> brcm=
,kona-sdhci.txt} (100%)
 rename Documentation/devicetree/bindings/net/{broadcom-sf2.txt =3D> br=
cm,bcm7445-switch-v4.0.txt} (100%)
 rename Documentation/devicetree/bindings/net/{broadcom-bcmgenet.txt =3D=
> brcm,bcmgenet.txt} (100%)
 rename Documentation/devicetree/bindings/net/{broadcom-systemport.txt =
=3D> brcm,systemport.txt} (100%)
 rename Documentation/devicetree/bindings/net/{broadcom-mdio-unimac.txt=
 =3D> brcm,unimac-mdio.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/ti,w=
lcore.txt
 create mode 100644 Documentation/devicetree/bindings/panel/ampire,am80=
0480r3tmqwa1h.txt
 create mode 100644 Documentation/devicetree/bindings/panel/auo,b101ean=
01.txt
 create mode 100644 Documentation/devicetree/bindings/panel/innolux,at0=
43tn24.txt
 create mode 100644 Documentation/devicetree/bindings/panel/innolux,zj0=
70na-01p.txt
 create mode 100644 Documentation/devicetree/bindings/panel/ortustech,c=
om43h4m85ulc.txt
 create mode 100644 Documentation/devicetree/bindings/panel/samsung,ltn=
140at29-301.txt
 create mode 100644 Documentation/devicetree/bindings/panel/shelly,sca0=
7010-bfn-lnn.txt
 rename Documentation/devicetree/bindings/phy/{bcm-phy.txt =3D> brcm,ko=
na-usb2-phy.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/power/fsl,imx-gpc=
=2Etxt
 rename Documentation/devicetree/bindings/pwm/{bcm-kona-pwm.txt =3D> br=
cm,kona-pwm.txt} (100%)
 rename Documentation/devicetree/bindings/{arm/bcm/kona-resetmgr.txt =3D=
> reset/brcm,bcm21664-resetmgr.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/rtc/digicolor-rtc=
=2Etxt
 create mode 100644 Documentation/devicetree/bindings/security/tpm/st33=
zp24-spi.txt
 rename Documentation/devicetree/bindings/serial/{bcm63xx-uart.txt =3D>=
 brcm,bcm6345-uart.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/soc/mediatek/pwra=
p.txt
 rename Documentation/devicetree/bindings/sound/{bcm2835-i2s.txt =3D> b=
rcm,bcm2835-i2s.txt} (100%)
 create mode 100644 Documentation/devicetree/bindings/sound/max98925.tx=
t
 create mode 100644 Documentation/devicetree/bindings/sound/qcom,lpass-=
cpu.txt
 create mode 100644 Documentation/devicetree/bindings/sound/renesas,rsr=
c-card.txt
 create mode 100644 Documentation/devicetree/bindings/sound/storm.txt
 rename Documentation/devicetree/bindings/{arm/bcm/kona-timer.txt =3D> =
timer/brcm,kona-timer.txt} (100%)
 rename Documentation/devicetree/bindings/{mips/brcm/usb.txt =3D> usb/b=
rcm,bcm3384-usb.txt} (100%)
 rename Documentation/devicetree/bindings/{arm/bcm/kona-wdt.txt =3D> wa=
tchdog/brcm,kona-wdt.txt} (100%)
 rename Documentation/devicetree/{of_selftest.txt =3D> of_unittest.txt}=
 (90%)
 delete mode 100644 Documentation/i2o/README
 delete mode 100644 Documentation/i2o/ioctl
 create mode 100644 Documentation/leds/leds-class-flash.txt
 create mode 100644 Documentation/md-cluster.txt
 create mode 100644 Documentation/powerpc/pci_iov_resource_on_powernv.t=
xt
 create mode 100644 Documentation/sound/alsa/timestamping.txt
 create mode 100644 Documentation/vm/zsmalloc.txt
 create mode 100644 Documentation/zh_CN/arm64/legacy_instructions.txt
 delete mode 100644 arch/arm/boot/compressed/mmcif-sh7372.c
 delete mode 100644 arch/arm/boot/compressed/sdhi-sh7372.c
 delete mode 100644 arch/arm/boot/compressed/sdhi-shmobile.c
 delete mode 100644 arch/arm/boot/compressed/sdhi-shmobile.h
 create mode 100644 arch/arm/boot/dts/alpine-db.dts
 create mode 100644 arch/arm/boot/dts/alpine.dtsi
 create mode 100644 arch/arm/boot/dts/am335x-chiliboard.dts
 create mode 100644 arch/arm/boot/dts/am335x-chilisom.dtsi
 create mode 100644 arch/arm/boot/dts/armada-390.dtsi
 create mode 100644 arch/arm/boot/dts/armada-398-db.dts
 create mode 100644 arch/arm/boot/dts/armada-398.dtsi
 create mode 100644 arch/arm/boot/dts/armada-39x.dtsi
 create mode 100644 arch/arm/boot/dts/armada-xp-linksys-mamba.dts
 create mode 100644 arch/arm/boot/dts/at91-sama5d4_xplained.dts
 create mode 100644 arch/arm/boot/dts/bcm4709-netgear-r8000.dts
 create mode 100644 arch/arm/boot/dts/bcm958305k.dts
 create mode 100644 arch/arm/boot/dts/imx6sl-warp.dts
 create mode 100644 arch/arm/boot/dts/imx6sx-sdb-reva.dts
 create mode 100644 arch/arm/boot/dts/imx6sx-sdb.dtsi
 create mode 100644 arch/arm/boot/dts/kirkwood-nas2big.dts
 create mode 100644 arch/arm/boot/dts/meson8-minix-neo-x8.dts
 create mode 100644 arch/arm/boot/dts/omap3-pandora-1ghz.dts
 create mode 100644 arch/arm/boot/dts/omap3-pandora-600mhz.dts
 create mode 100644 arch/arm/boot/dts/omap3-pandora-common.dtsi
 delete mode 100644 arch/arm/boot/dts/omap34xx-hs.dtsi
 delete mode 100644 arch/arm/boot/dts/omap36xx-hs.dtsi
 create mode 100644 arch/arm/boot/dts/qcom-pm8841.dtsi
 create mode 100644 arch/arm/boot/dts/qcom-pm8941.dtsi
 create mode 100644 arch/arm/boot/dts/qcom-pma8084.dtsi
 delete mode 100644 arch/arm/boot/dts/r8a73a4-ape6evm-reference.dts
 create mode 100644 arch/arm/boot/dts/rk3288-popmetal.dts
 delete mode 100644 arch/arm/boot/dts/sh7372-mackerel.dts
 delete mode 100644 arch/arm/boot/dts/sh7372.dtsi
 delete mode 100644 arch/arm/boot/dts/sh73a0-kzm9g-reference.dts
 create mode 100644 arch/arm/boot/dts/tegra124-jetson-tk1-emc.dtsi
 create mode 100644 arch/arm/boot/dts/tegra124-nyan-big-emc.dtsi
 create mode 100644 arch/arm/boot/dts/tegra124-nyan-blaze-emc.dtsi
 create mode 100644 arch/arm/boot/dts/tegra124-nyan-blaze.dts
 create mode 100644 arch/arm/boot/dts/tegra124-nyan.dtsi
 delete mode 100644 arch/arm/configs/ape6evm_defconfig
 delete mode 100644 arch/arm/configs/mackerel_defconfig
 delete mode 100644 arch/arm/configs/msm_defconfig
 create mode 100644 arch/arm/crypto/Kconfig
 create mode 100644 arch/arm/crypto/aes-ce-core.S
 create mode 100644 arch/arm/crypto/aes-ce-glue.c
 create mode 100644 arch/arm/crypto/ghash-ce-core.S
 create mode 100644 arch/arm/crypto/ghash-ce-glue.c
 create mode 100644 arch/arm/crypto/sha1-ce-core.S
 create mode 100644 arch/arm/crypto/sha1-ce-glue.c
 rename arch/arm/{include/asm =3D> }/crypto/sha1.h (67%)
 create mode 100644 arch/arm/crypto/sha2-ce-core.S
 create mode 100644 arch/arm/crypto/sha2-ce-glue.c
 create mode 100644 arch/arm/crypto/sha256-armv4.pl
 create mode 100644 arch/arm/crypto/sha256-core.S_shipped
 create mode 100644 arch/arm/crypto/sha256_glue.c
 create mode 100644 arch/arm/crypto/sha256_glue.h
 create mode 100644 arch/arm/crypto/sha256_neon_glue.c
 create mode 100644 arch/arm/include/asm/arm-cci.h
 delete mode 100644 arch/arm/include/asm/seccomp.h
 delete mode 100644 arch/arm/kernel/arthur.c
 create mode 100644 arch/arm/mach-alpine/Kconfig
 create mode 100644 arch/arm/mach-alpine/Makefile
 create mode 100644 arch/arm/mach-alpine/alpine_cpu_pm.c
 rename arch/arm/{mach-at91/include/mach/io.h =3D> mach-alpine/alpine_c=
pu_pm.h} (55%)
 create mode 100644 arch/arm/mach-alpine/alpine_cpu_resume.h
 rename arch/{powerpc/platforms/cell/beat_interrupt.h =3D> arm/mach-alp=
ine/alpine_machine.c} (50%)
 create mode 100644 arch/arm/mach-alpine/platsmp.c
 delete mode 100644 arch/arm/mach-at91/include/mach/at91_dbgu.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91_matrix.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91_st.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91rm9200.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9260.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9260_matrix.=
h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9261.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9261_matrix.=
h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9263.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9263_matrix.=
h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9g45.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9g45_matrix.=
h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9n12.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9n12_matrix.=
h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9rl.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9rl_matrix.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9x5.h
 delete mode 100644 arch/arm/mach-at91/include/mach/at91sam9x5_matrix.h
 delete mode 100644 arch/arm/mach-at91/include/mach/cpu.h
 delete mode 100644 arch/arm/mach-at91/include/mach/hardware.h
 delete mode 100644 arch/arm/mach-at91/include/mach/sama5d3.h
 delete mode 100644 arch/arm/mach-at91/include/mach/sama5d4.h
 delete mode 100644 arch/arm/mach-at91/include/mach/uncompress.h
 delete mode 100644 arch/arm/mach-at91/pm_slowclock.S
 create mode 100644 arch/arm/mach-at91/pm_suspend.S
 delete mode 100644 arch/arm/mach-at91/setup.c
 create mode 100644 arch/arm/mach-at91/soc.c
 create mode 100644 arch/arm/mach-at91/soc.h
 delete mode 100644 arch/arm/mach-imx/devices-imx25.h
 delete mode 100644 arch/arm/mach-imx/devices/platform-imxdi_rtc.c
 delete mode 100644 arch/arm/mach-imx/ehci-imx25.c
 delete mode 100644 arch/arm/mach-imx/eukrea_mbimxsd25-baseboard.c
 delete mode 100644 arch/arm/mach-imx/iomux-mx25.h
 delete mode 100644 arch/arm/mach-imx/mach-eukrea_cpuimx25.c
 rename arch/arm/mach-imx/{imx25-dt.c =3D> mach-imx25.c} (68%)
 delete mode 100644 arch/arm/mach-imx/mach-mx25_3ds.c
 delete mode 100644 arch/arm/mach-imx/mm-imx25.c
 delete mode 100644 arch/arm/mach-imx/mx25.h
 delete mode 100644 arch/arm/mach-msm/Kconfig
 delete mode 100644 arch/arm/mach-msm/Makefile
 delete mode 100644 arch/arm/mach-msm/Makefile.boot
 delete mode 100644 arch/arm/mach-msm/board-halibut.c
 delete mode 100644 arch/arm/mach-msm/board-msm7x30.c
 delete mode 100644 arch/arm/mach-msm/board-qsd8x50.c
 delete mode 100644 arch/arm/mach-msm/board-sapphire.c
 delete mode 100644 arch/arm/mach-msm/board-trout-gpio.c
 delete mode 100644 arch/arm/mach-msm/board-trout-mmc.c
 delete mode 100644 arch/arm/mach-msm/board-trout-panel.c
 delete mode 100644 arch/arm/mach-msm/board-trout.c
 delete mode 100644 arch/arm/mach-msm/board-trout.h
 delete mode 100644 arch/arm/mach-msm/clock-pcom.c
 delete mode 100644 arch/arm/mach-msm/clock-pcom.h
 delete mode 100644 arch/arm/mach-msm/clock.c
 delete mode 100644 arch/arm/mach-msm/clock.h
 delete mode 100644 arch/arm/mach-msm/common.h
 delete mode 100644 arch/arm/mach-msm/devices-msm7x00.c
 delete mode 100644 arch/arm/mach-msm/devices-msm7x30.c
 delete mode 100644 arch/arm/mach-msm/devices-qsd8x50.c
 delete mode 100644 arch/arm/mach-msm/devices.h
 delete mode 100644 arch/arm/mach-msm/dma.c
 delete mode 100644 arch/arm/mach-msm/gpiomux-8x50.c
 delete mode 100644 arch/arm/mach-msm/gpiomux-v1.h
 delete mode 100644 arch/arm/mach-msm/gpiomux.c
 delete mode 100644 arch/arm/mach-msm/gpiomux.h
 delete mode 100644 arch/arm/mach-msm/include/mach/clk.h
 delete mode 100644 arch/arm/mach-msm/include/mach/dma.h
 delete mode 100644 arch/arm/mach-msm/include/mach/entry-macro.S
 delete mode 100644 arch/arm/mach-msm/include/mach/hardware.h
 delete mode 100644 arch/arm/mach-msm/include/mach/irqs-7x00.h
 delete mode 100644 arch/arm/mach-msm/include/mach/irqs-7x30.h
 delete mode 100644 arch/arm/mach-msm/include/mach/irqs-8x50.h
 delete mode 100644 arch/arm/mach-msm/include/mach/irqs.h
 delete mode 100644 arch/arm/mach-msm/include/mach/msm_gpiomux.h
 delete mode 100644 arch/arm/mach-msm/include/mach/msm_iomap-7x00.h
 delete mode 100644 arch/arm/mach-msm/include/mach/msm_iomap-7x30.h
 delete mode 100644 arch/arm/mach-msm/include/mach/msm_iomap-8x50.h
 delete mode 100644 arch/arm/mach-msm/include/mach/msm_iomap.h
 delete mode 100644 arch/arm/mach-msm/include/mach/msm_smd.h
 delete mode 100644 arch/arm/mach-msm/include/mach/sirc.h
 delete mode 100644 arch/arm/mach-msm/include/mach/vreg.h
 delete mode 100644 arch/arm/mach-msm/io.c
 delete mode 100644 arch/arm/mach-msm/irq-vic.c
 delete mode 100644 arch/arm/mach-msm/irq.c
 delete mode 100644 arch/arm/mach-msm/last_radio_log.c
 delete mode 100644 arch/arm/mach-msm/proc_comm.c
 delete mode 100644 arch/arm/mach-msm/proc_comm.h
 delete mode 100644 arch/arm/mach-msm/sirc.c
 delete mode 100644 arch/arm/mach-msm/smd.c
 delete mode 100644 arch/arm/mach-msm/smd_debug.c
 delete mode 100644 arch/arm/mach-msm/smd_private.h
 delete mode 100644 arch/arm/mach-msm/vreg.c
 delete mode 100644 arch/arm/mach-omap2/board-devkit8000.c
 delete mode 100644 arch/arm/mach-omap2/board-omap3stalker.c
 delete mode 100644 arch/arm/mach-omap2/board-omap3touchbook.c
 delete mode 100644 arch/arm/mach-qcom/scm-boot.c
 delete mode 100644 arch/arm/mach-qcom/scm.c
 delete mode 100644 arch/arm/mach-shmobile/board-ape6evm-reference.c
 delete mode 100644 arch/arm/mach-shmobile/board-ape6evm.c
 delete mode 100644 arch/arm/mach-shmobile/board-kzm9g-reference.c
 delete mode 100644 arch/arm/mach-shmobile/board-mackerel.c
 delete mode 100644 arch/arm/mach-shmobile/clock-r8a73a4.c
 delete mode 100644 arch/arm/mach-shmobile/clock-sh7372.c
 delete mode 100644 arch/arm/mach-shmobile/cpuidle.c
 delete mode 100644 arch/arm/mach-shmobile/entry-intc.S
 delete mode 100644 arch/arm/mach-shmobile/include/mach/clkdev.h
 delete mode 100644 arch/arm/mach-shmobile/include/mach/head-mackerel.t=
xt
 delete mode 100644 arch/arm/mach-shmobile/include/mach/mmc-mackerel.h
 delete mode 100644 arch/arm/mach-shmobile/include/mach/mmc.h
 delete mode 100644 arch/arm/mach-shmobile/include/mach/sdhi-sh7372.h
 delete mode 100644 arch/arm/mach-shmobile/include/mach/sdhi.h
 delete mode 100644 arch/arm/mach-shmobile/include/mach/system.h
 delete mode 100644 arch/arm/mach-shmobile/include/mach/uncompress.h
 delete mode 100644 arch/arm/mach-shmobile/intc-sh7372.c
 delete mode 100644 arch/arm/mach-shmobile/pm-r8a7790.c
 delete mode 100644 arch/arm/mach-shmobile/pm-r8a7791.c
 create mode 100644 arch/arm/mach-shmobile/pm-rcar-gen2.c
 delete mode 100644 arch/arm/mach-shmobile/pm-sh7372.c
 delete mode 100644 arch/arm/mach-shmobile/r8a73a4.h
 create mode 100644 arch/arm/mach-shmobile/regulator-quirk-rcar-gen2.c
 delete mode 100644 arch/arm/mach-shmobile/setup-sh7372.c
 delete mode 100644 arch/arm/mach-shmobile/sh7372.h
 delete mode 100644 arch/arm/mach-shmobile/sleep-sh7372.S
 create mode 100644 arch/arm64/boot/dts/mediatek/mt8173-pinfunc.h
 create mode 100644 arch/arm64/boot/dts/qcom/Makefile
 rename arch/{arm/mach-qcom/scm-boot.h =3D> arm64/boot/dts/qcom/apq8016=
-sbc.dts} (50%)
 rename arch/{arm/mach-qcom/scm.h =3D> arm64/boot/dts/qcom/apq8016-sbc.=
dtsi} (54%)
 create mode 100644 arch/arm64/boot/dts/qcom/msm8916-mtp.dts
 create mode 100644 arch/arm64/boot/dts/qcom/msm8916-mtp.dtsi
 create mode 100644 arch/arm64/boot/dts/qcom/msm8916.dtsi
 create mode 100644 arch/arm64/boot/dts/sprd/Makefile
 create mode 100644 arch/arm64/boot/dts/sprd/sc9836-openphone.dts
 create mode 100644 arch/arm64/boot/dts/sprd/sc9836.dtsi
 create mode 100644 arch/arm64/boot/dts/sprd/sharkl64.dtsi
 create mode 100644 arch/arm64/boot/dts/xilinx/Makefile
 create mode 100644 arch/arm64/boot/dts/xilinx/zynqmp-ep108.dts
 create mode 100644 arch/arm64/boot/dts/xilinx/zynqmp.dtsi
 create mode 100644 arch/arm64/include/asm/acenv.h
 create mode 100644 arch/arm64/include/asm/acpi.h
 rename arch/arm64/include/asm/{cputable.h =3D> arm-cci.h} (59%)
 create mode 100644 arch/arm64/kernel/acpi.c
 create mode 100644 arch/arm64/kernel/cpufeature.c
 delete mode 100644 arch/arm64/kernel/cputable.c
 create mode 100644 arch/c6x/include/asm/flat.h
 delete mode 100644 arch/cris/arch-v32/kernel/smp.c
 delete mode 100644 arch/cris/arch-v32/lib/spinlock.S
 create mode 100644 arch/cris/boot/dts/Makefile
 create mode 100644 arch/cris/boot/dts/dev88.dts
 create mode 100644 arch/cris/boot/dts/etraxfs.dtsi
 delete mode 100644 arch/cris/include/arch-v10/arch/atomic.h
 delete mode 100644 arch/cris/include/arch-v32/arch/atomic.h
 delete mode 100644 arch/cris/include/arch-v32/arch/spinlock.h
 delete mode 100644 arch/cris/include/asm/atomic.h
 delete mode 100644 arch/cris/include/asm/cmpxchg.h
 delete mode 100644 arch/cris/include/asm/device.h
 delete mode 100644 arch/cris/include/asm/div64.h
 delete mode 100644 arch/cris/include/asm/emergency-restart.h
 delete mode 100644 arch/cris/include/asm/futex.h
 delete mode 100644 arch/cris/include/asm/hardirq.h
 delete mode 100644 arch/cris/include/asm/irq_regs.h
 delete mode 100644 arch/cris/include/asm/kdebug.h
 delete mode 100644 arch/cris/include/asm/kmap_types.h
 delete mode 100644 arch/cris/include/asm/local.h
 delete mode 100644 arch/cris/include/asm/local64.h
 delete mode 100644 arch/cris/include/asm/percpu.h
 delete mode 100644 arch/cris/include/asm/smp.h
 delete mode 100644 arch/cris/include/asm/spinlock.h
 delete mode 100644 arch/cris/include/asm/topology.h
 create mode 100644 arch/cris/kernel/devicetree.c
 create mode 100644 arch/m32r/include/asm/asm-offsets.h
 delete mode 100644 arch/mips/bcm3384/Platform
 delete mode 100644 arch/mips/bcm3384/dma.c
 delete mode 100644 arch/mips/bcm3384/irq.c
 delete mode 100644 arch/mips/bcm3384/setup.c
 create mode 100644 arch/mips/bmips/Kconfig
 rename arch/mips/{bcm3384 =3D> bmips}/Makefile (100%)
 create mode 100644 arch/mips/bmips/Platform
 create mode 100644 arch/mips/bmips/dma.c
 create mode 100644 arch/mips/bmips/irq.c
 create mode 100644 arch/mips/bmips/setup.c
 delete mode 100644 arch/mips/boot/dts/bcm3384.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/Makefile
 create mode 100644 arch/mips/boot/dts/brcm/bcm3384_viper.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm3384_zephyr.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm6328.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm6368.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7125.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7346.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7358.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7360.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7362.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7420.dtsi
 create mode 100644 arch/mips/boot/dts/brcm/bcm7425.dtsi
 rename arch/mips/boot/dts/{ =3D> brcm}/bcm93384wvg.dts (63%)
 create mode 100644 arch/mips/boot/dts/brcm/bcm93384wvg_viper.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm96368mvwg.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97125cbmb.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97346dbsmb.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97358svmb.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97360svmb.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97362svmb.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97420c.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm97425svmb.dts
 create mode 100644 arch/mips/boot/dts/brcm/bcm9ejtagprb.dts
 create mode 100644 arch/mips/boot/dts/cavium-octeon/Makefile
 rename arch/mips/boot/dts/{ =3D> cavium-octeon}/octeon_3xxx.dts (98%)
 rename arch/mips/boot/dts/{ =3D> cavium-octeon}/octeon_68xx.dts (100%)
 create mode 100644 arch/mips/boot/dts/lantiq/Makefile
 rename arch/mips/boot/dts/{ =3D> lantiq}/danube.dtsi (100%)
 rename arch/mips/boot/dts/{ =3D> lantiq}/easy50712.dts (100%)
 create mode 100644 arch/mips/boot/dts/mti/Makefile
 rename arch/mips/boot/dts/{ =3D> mti}/sead3.dts (100%)
 create mode 100644 arch/mips/boot/dts/netlogic/Makefile
 rename arch/mips/boot/dts/{ =3D> netlogic}/xlp_evp.dts (100%)
 rename arch/mips/boot/dts/{ =3D> netlogic}/xlp_fvp.dts (100%)
 rename arch/mips/boot/dts/{ =3D> netlogic}/xlp_gvp.dts (100%)
 create mode 100644 arch/mips/boot/dts/netlogic/xlp_rvp.dts
 rename arch/mips/boot/dts/{ =3D> netlogic}/xlp_svp.dts (100%)
 create mode 100644 arch/mips/boot/dts/ralink/Makefile
 rename arch/mips/boot/dts/{ =3D> ralink}/mt7620a.dtsi (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/mt7620a_eval.dts (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/rt2880.dtsi (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/rt2880_eval.dts (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/rt3050.dtsi (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/rt3052_eval.dts (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/rt3883.dtsi (100%)
 rename arch/mips/boot/dts/{ =3D> ralink}/rt3883_eval.dts (100%)
 create mode 100644 arch/mips/cavium-octeon/crypto/octeon-sha1.c
 create mode 100644 arch/mips/cavium-octeon/crypto/octeon-sha256.c
 create mode 100644 arch/mips/cavium-octeon/crypto/octeon-sha512.c
 rename arch/mips/configs/{bcm3384_defconfig =3D> bmips_be_defconfig} (=
89%)
 create mode 100644 arch/mips/configs/bmips_stb_defconfig
 create mode 100644 arch/mips/configs/maltaup_xpa_defconfig
 create mode 100644 arch/mips/configs/pistachio_defconfig
 create mode 100644 arch/mips/include/asm/cdmm.h
 delete mode 100644 arch/mips/include/asm/mach-ar7/war.h
 delete mode 100644 arch/mips/include/asm/mach-ath25/war.h
 delete mode 100644 arch/mips/include/asm/mach-ath79/war.h
 delete mode 100644 arch/mips/include/asm/mach-au1x00/war.h
 delete mode 100644 arch/mips/include/asm/mach-bcm3384/war.h
 delete mode 100644 arch/mips/include/asm/mach-bcm47xx/war.h
 create mode 100644 arch/mips/include/asm/mach-bcm63xx/dma-coherence.h
 delete mode 100644 arch/mips/include/asm/mach-bcm63xx/war.h
 rename arch/mips/include/asm/{mach-bcm3384 =3D> mach-bmips}/dma-cohere=
nce.h (83%)
 create mode 100644 arch/mips/include/asm/mach-bmips/spaces.h
 create mode 100644 arch/mips/include/asm/mach-cavium-octeon/mangle-por=
t.h
 delete mode 100644 arch/mips/include/asm/mach-cobalt/war.h
 delete mode 100644 arch/mips/include/asm/mach-dec/war.h
 delete mode 100644 arch/mips/include/asm/mach-emma2rh/war.h
 rename arch/mips/include/asm/{mach-ralink =3D> mach-generic}/war.h (86=
%)
 delete mode 100644 arch/mips/include/asm/mach-ip32/mc146818rtc.h
 delete mode 100644 arch/mips/include/asm/mach-jazz/war.h
 delete mode 100644 arch/mips/include/asm/mach-jz4740/war.h
 delete mode 100644 arch/mips/include/asm/mach-lantiq/war.h
 delete mode 100644 arch/mips/include/asm/mach-lasat/war.h
 delete mode 100644 arch/mips/include/asm/mach-loongson/war.h
 delete mode 100644 arch/mips/include/asm/mach-loongson1/war.h
 delete mode 100644 arch/mips/include/asm/mach-netlogic/topology.h
 delete mode 100644 arch/mips/include/asm/mach-netlogic/war.h
 delete mode 100644 arch/mips/include/asm/mach-paravirt/war.h
 create mode 100644 arch/mips/include/asm/mach-pistachio/gpio.h
 create mode 100644 arch/mips/include/asm/mach-pistachio/irq.h
 delete mode 100644 arch/mips/include/asm/mach-pnx833x/war.h
 delete mode 100644 arch/mips/include/asm/mach-tx39xx/war.h
 delete mode 100644 arch/mips/include/asm/mach-vr41xx/war.h
 create mode 100644 arch/mips/include/asm/mips-boards/sead3-addr.h
 delete mode 100644 arch/mips/mti-sead3/sead3-ehci.c
 delete mode 100644 arch/mips/mti-sead3/sead3-i2c-dev.c
 delete mode 100644 arch/mips/mti-sead3/sead3-i2c-drv.c
 delete mode 100644 arch/mips/mti-sead3/sead3-i2c.c
 delete mode 100644 arch/mips/mti-sead3/sead3-leds.c
 delete mode 100644 arch/mips/mti-sead3/sead3-mtd.c
 delete mode 100644 arch/mips/mti-sead3/sead3-net.c
 create mode 100644 arch/mips/pistachio/Makefile
 create mode 100644 arch/mips/pistachio/Platform
 create mode 100644 arch/mips/pistachio/init.c
 create mode 100644 arch/mips/pistachio/irq.c
 create mode 100644 arch/mips/pistachio/time.c
 create mode 100644 arch/mips/power/hibernate.c
 rename arch/mips/power/{hibernate.S =3D> hibernate_asm.S} (91%)
 create mode 100644 arch/nios2/include/asm/shmparam.h
 delete mode 100644 arch/parisc/include/asm/scatterlist.h
 delete mode 100644 arch/parisc/include/asm/seccomp.h
 delete mode 100644 arch/powerpc/boot/dts/b4860emu.dts
 delete mode 100644 arch/powerpc/configs/celleb_defconfig
 create mode 100644 arch/powerpc/crypto/aes-spe-core.S
 create mode 100644 arch/powerpc/crypto/aes-spe-glue.c
 create mode 100644 arch/powerpc/crypto/aes-spe-keys.S
 create mode 100644 arch/powerpc/crypto/aes-spe-modes.S
 create mode 100644 arch/powerpc/crypto/aes-spe-regs.h
 create mode 100644 arch/powerpc/crypto/aes-tab-4k.S
 create mode 100644 arch/powerpc/crypto/md5-asm.S
 create mode 100644 arch/powerpc/crypto/md5-glue.c
 create mode 100644 arch/powerpc/crypto/sha1-spe-asm.S
 create mode 100644 arch/powerpc/crypto/sha1-spe-glue.c
 create mode 100644 arch/powerpc/crypto/sha256-spe-asm.S
 create mode 100644 arch/powerpc/crypto/sha256-spe-glue.c
 delete mode 100644 arch/powerpc/include/asm/div64.h
 delete mode 100644 arch/powerpc/include/asm/irq_regs.h
 delete mode 100644 arch/powerpc/include/asm/local64.h
 create mode 100644 arch/powerpc/include/asm/nmi.h
 create mode 100644 arch/powerpc/include/asm/opal-api.h
 create mode 100644 arch/powerpc/include/asm/seccomp.h
 delete mode 100644 arch/powerpc/include/uapi/asm/seccomp.h
 create mode 100644 arch/powerpc/mm/vphn.c
 create mode 100644 arch/powerpc/mm/vphn.h
 delete mode 100644 arch/powerpc/platforms/cell/beat.c
 delete mode 100644 arch/powerpc/platforms/cell/beat.h
 delete mode 100644 arch/powerpc/platforms/cell/beat_htab.c
 delete mode 100644 arch/powerpc/platforms/cell/beat_hvCall.S
 delete mode 100644 arch/powerpc/platforms/cell/beat_interrupt.c
 delete mode 100644 arch/powerpc/platforms/cell/beat_iommu.c
 delete mode 100644 arch/powerpc/platforms/cell/beat_spu_priv1.c
 delete mode 100644 arch/powerpc/platforms/cell/beat_syscall.h
 delete mode 100644 arch/powerpc/platforms/cell/beat_udbg.c
 delete mode 100644 arch/powerpc/platforms/cell/beat_wrapper.h
 create mode 100644 arch/powerpc/platforms/cell/cell.h
 delete mode 100644 arch/powerpc/platforms/cell/celleb_pci.c
 delete mode 100644 arch/powerpc/platforms/cell/celleb_pci.h
 delete mode 100644 arch/powerpc/platforms/cell/celleb_scc.h
 delete mode 100644 arch/powerpc/platforms/cell/celleb_scc_epci.c
 delete mode 100644 arch/powerpc/platforms/cell/celleb_scc_pciex.c
 delete mode 100644 arch/powerpc/platforms/cell/celleb_scc_sio.c
 delete mode 100644 arch/powerpc/platforms/cell/celleb_scc_uhc.c
 delete mode 100644 arch/powerpc/platforms/cell/celleb_setup.c
 delete mode 100644 arch/powerpc/platforms/powernv/eeh-ioda.c
 delete mode 100755 arch/powerpc/relocs_check.pl
 create mode 100755 arch/powerpc/relocs_check.sh
 create mode 100644 arch/s390/net/bpf_jit.h
 create mode 100644 arch/tile/include/asm/irq_work.h
 delete mode 100644 arch/um/Makefile-ia64
 delete mode 100644 arch/um/Makefile-ppc
 delete mode 100644 arch/um/include/shared/skas/proc_mm.h
 delete mode 100644 arch/um/include/shared/skas_ptrace.h
 create mode 100644 arch/um/kernel/kmsg_dump.c
 delete mode 100644 arch/um/kernel/smp.c
 delete mode 100644 arch/um/sys-ia64/Makefile
 delete mode 100644 arch/um/sys-ia64/sysdep/ptrace.h
 delete mode 100644 arch/um/sys-ia64/sysdep/sigcontext.h
 delete mode 100644 arch/um/sys-ia64/sysdep/skas_ptrace.h
 delete mode 100644 arch/um/sys-ia64/sysdep/syscalls.h
 delete mode 100644 arch/um/sys-ppc/Makefile
 delete mode 100644 arch/um/sys-ppc/asm/archparam.h
 delete mode 100644 arch/um/sys-ppc/asm/elf.h
 delete mode 100644 arch/um/sys-ppc/asm/processor.h
 delete mode 100644 arch/um/sys-ppc/misc.S
 delete mode 100644 arch/um/sys-ppc/miscthings.c
 delete mode 100644 arch/um/sys-ppc/ptrace.c
 delete mode 100644 arch/um/sys-ppc/ptrace_user.c
 delete mode 100644 arch/um/sys-ppc/shared/sysdep/ptrace.h
 delete mode 100644 arch/um/sys-ppc/shared/sysdep/sigcontext.h
 delete mode 100644 arch/um/sys-ppc/shared/sysdep/skas_ptrace.h
 delete mode 100644 arch/um/sys-ppc/shared/sysdep/syscalls.h
 delete mode 100644 arch/um/sys-ppc/sigcontext.c
 delete mode 100644 arch/um/sys-ppc/sysrq.c
 delete mode 100644 arch/x86/include/asm/seccomp_32.h
 delete mode 100644 arch/x86/include/asm/seccomp_64.h
 create mode 100644 arch/x86/kernel/pmem.c
 delete mode 100644 arch/x86/platform/intel-mid/early_printk_intel_mid.=
c
 delete mode 100644 arch/x86/um/shared/sysdep/skas_ptrace.h
 create mode 100644 arch/xtensa/configs/audio_kc705_defconfig
 create mode 100644 crypto/algif_aead.c
 create mode 100644 drivers/acpi/gsi.c
 create mode 100644 drivers/block/pmem.c
 create mode 100644 drivers/bus/mips_cdmm.c
 create mode 100644 drivers/bus/simple-pm-bus.c
 create mode 100644 drivers/char/hw_random/iproc-rng200.c
 create mode 100644 drivers/char/tpm/st33zp24/Kconfig
 create mode 100644 drivers/char/tpm/st33zp24/Makefile
 create mode 100644 drivers/char/tpm/st33zp24/i2c.c
 create mode 100644 drivers/char/tpm/st33zp24/spi.c
 create mode 100644 drivers/char/tpm/st33zp24/st33zp24.c
 create mode 100644 drivers/char/tpm/st33zp24/st33zp24.h
 delete mode 100644 drivers/char/tpm/tpm_i2c_stm_st33.c
 create mode 100644 drivers/clk/clk-mb86s7x.c
 create mode 100644 drivers/clk/clk-pwm.c
 create mode 100644 drivers/clk/mvebu/armada-39x.c
 create mode 100644 drivers/clk/pistachio/Makefile
 create mode 100644 drivers/clk/pistachio/clk-pistachio.c
 create mode 100644 drivers/clk/pistachio/clk-pll.c
 create mode 100644 drivers/clk/pistachio/clk.c
 create mode 100644 drivers/clk/pistachio/clk.h
 create mode 100644 drivers/clk/qcom/gcc-msm8916.c
 create mode 100644 drivers/clk/samsung/clk-exynos5433.c
 create mode 100644 drivers/clk/shmobile/clk-r8a7778.c
 create mode 100644 drivers/clk/sunxi/clk-usb.c
 rename arch/arm/mach-at91/at91rm9200_time.c =3D> drivers/clocksource/t=
imer-atmel-st.c (73%)
 create mode 100644 drivers/crypto/img-hash.c
 create mode 100644 drivers/crypto/vmx/Kconfig
 create mode 100644 drivers/crypto/vmx/Makefile
 create mode 100644 drivers/crypto/vmx/aes.c
 create mode 100644 drivers/crypto/vmx/aes_cbc.c
 create mode 100644 drivers/crypto/vmx/aes_ctr.c
 create mode 100644 drivers/crypto/vmx/aesp8-ppc.h
 create mode 100644 drivers/crypto/vmx/aesp8-ppc.pl
 create mode 100644 drivers/crypto/vmx/ghash.c
 create mode 100644 drivers/crypto/vmx/ghashp8-ppc.pl
 create mode 100644 drivers/crypto/vmx/ppc-xlate.pl
 create mode 100644 drivers/crypto/vmx/vmx.c
 create mode 100644 drivers/dma/dma-jz4780.c
 create mode 100644 drivers/dma/fsl_raid.c
 create mode 100644 drivers/dma/fsl_raid.h
 create mode 100644 drivers/dma/hsu/Kconfig
 create mode 100644 drivers/dma/hsu/Makefile
 create mode 100644 drivers/dma/hsu/hsu.c
 create mode 100644 drivers/dma/hsu/hsu.h
 create mode 100644 drivers/dma/hsu/pci.c
 delete mode 100644 drivers/dma/sh/rcar-audmapp.c
 create mode 100644 drivers/dma/sh/usb-dmac.c
 create mode 100755 drivers/dma/xgene-dma.c
 create mode 100644 drivers/extcon/extcon-max77843.c
 create mode 100644 drivers/extcon/extcon-usb-gpio.c
 rename drivers/extcon/{extcon-class.c =3D> extcon.c} (97%)
 create mode 100644 drivers/firmware/qcom_scm.c
 create mode 100644 drivers/gpio/gpio-altera.c
 rename arch/mips/loongson/common/gpio.c =3D> drivers/gpio/gpio-loongso=
n.c (52%)
 delete mode 100644 drivers/gpio/gpio-msm-v1.c
 create mode 100644 drivers/gpu/drm/bridge/ps8622.c
 create mode 100644 drivers/gpu/drm/exynos/exynos_drm_fimd.h
 create mode 100644 drivers/gpu/drm/i915/i915_gem_shrinker.c
 delete mode 100644 drivers/gpu/drm/i915/i915_ums.c
 create mode 100644 drivers/gpu/drm/i915/i915_vgpu.c
 create mode 100644 drivers/gpu/drm/i915/i915_vgpu.h
 create mode 100644 drivers/gpu/drm/msm/dsi/dsi.c
 create mode 100644 drivers/gpu/drm/msm/dsi/dsi.h
 create mode 100644 drivers/gpu/drm/msm/dsi/dsi_host.c
 create mode 100644 drivers/gpu/drm/msm/dsi/dsi_manager.c
 create mode 100644 drivers/gpu/drm/msm/dsi/dsi_phy.c
 create mode 100644 drivers/gpu/drm/msm/mdp/mdp5/mdp5_cmd_encoder.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/ce/gm204.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/fifo/gm204.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgm204.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/gr/ctxgm206.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/gr/gm204.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/engine/gr/gm206.c
 delete mode 100644 drivers/gpu/drm/nouveau/nvkm/subdev/fb/ramgk20a.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/subdev/instmem/gk20a.c
 create mode 100644 drivers/gpu/drm/nouveau/nvkm/subdev/pmu/gk110.c
 create mode 100644 drivers/gpu/drm/radeon/radeon_dp_auxch.c
 create mode 100644 drivers/gpu/drm/radeon/radeon_dp_mst.c
 create mode 100644 drivers/gpu/drm/vgem/Makefile
 create mode 100644 drivers/gpu/drm/vgem/vgem_dma_buf.c
 create mode 100644 drivers/gpu/drm/vgem/vgem_drv.c
 rename drivers/gpu/drm/{i915/intel_dsi_cmd.h =3D> vgem/vgem_drv.h} (51=
%)
 create mode 100644 drivers/hwtracing/coresight/Kconfig
 rename drivers/{ =3D> hwtracing}/coresight/Makefile (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-etb10.c (99%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-etm-cp14.c (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-etm.h (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-etm3x.c (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-funnel.c (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-priv.h (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-replicator.c (98%=
)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-tmc.c (91%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight-tpiu.c (100%)
 rename drivers/{ =3D> hwtracing}/coresight/coresight.c (99%)
 rename drivers/{ =3D> hwtracing}/coresight/of_coresight.c (88%)
 create mode 100644 drivers/input/mouse/vmmouse.c
 create mode 100644 drivers/input/mouse/vmmouse.h
 create mode 100644 drivers/irqchip/irq-bcm7038-l1.c
 create mode 100644 drivers/leds/leds-pm8941-wled.c
 create mode 100644 drivers/mailbox/arm_mhu.c
 create mode 100644 drivers/md/dm-log-writes.c
 create mode 100644 drivers/md/md-cluster.c
 create mode 100644 drivers/md/md-cluster.h
 create mode 100644 drivers/media/dvb-frontends/lgdt3306a.c
 create mode 100644 drivers/media/dvb-frontends/lgdt3306a.h
 create mode 100644 drivers/media/i2c/ov2659.c
 create mode 100644 drivers/media/platform/coda/trace.h
 create mode 100644 drivers/media/platform/xilinx/Kconfig
 create mode 100644 drivers/media/platform/xilinx/Makefile
 create mode 100644 drivers/media/platform/xilinx/xilinx-dma.c
 create mode 100644 drivers/media/platform/xilinx/xilinx-dma.h
 create mode 100644 drivers/media/platform/xilinx/xilinx-tpg.c
 create mode 100644 drivers/media/platform/xilinx/xilinx-vip.c
 create mode 100644 drivers/media/platform/xilinx/xilinx-vip.h
 create mode 100644 drivers/media/platform/xilinx/xilinx-vipp.c
 create mode 100644 drivers/media/platform/xilinx/xilinx-vipp.h
 create mode 100644 drivers/media/platform/xilinx/xilinx-vtc.c
 create mode 100644 drivers/media/platform/xilinx/xilinx-vtc.h
 delete mode 100644 drivers/media/tuners/m88ts2022.c
 delete mode 100644 drivers/media/tuners/m88ts2022.h
 delete mode 100644 drivers/media/tuners/m88ts2022_priv.h
 create mode 100644 drivers/memory/jz4780-nemc.c
 create mode 100644 drivers/misc/mei/mei-trace.c
 create mode 100644 drivers/misc/mei/mei-trace.h
 delete mode 100644 drivers/mmc/host/msm_sdcc.c
 delete mode 100644 drivers/mmc/host/msm_sdcc.h
 create mode 100644 drivers/mtd/ubi/fastmap-wl.c
 create mode 100644 drivers/mtd/ubi/wl.h
 create mode 100644 drivers/net/bonding/bonding_priv.h
 create mode 100644 drivers/net/wireless/ath/ath10k/p2p.c
 create mode 100644 drivers/net/wireless/ath/ath10k/p2p.h
 create mode 100644 drivers/net/wireless/ath/ath10k/wow.c
 create mode 100644 drivers/net/wireless/ath/ath10k/wow.h
 create mode 100644 drivers/of/unittest-data/.gitignore
 create mode 100644 drivers/of/unittest-data/Makefile
 create mode 100644 drivers/platform/chrome/cros_ec_dev.c
 create mode 100644 drivers/platform/chrome/cros_ec_dev.h
 create mode 100644 drivers/platform/chrome/cros_ec_lightbar.c
 create mode 100644 drivers/platform/chrome/cros_ec_lpc.c
 create mode 100644 drivers/platform/chrome/cros_ec_sysfs.c
 create mode 100644 drivers/platform/mips/Kconfig
 create mode 100644 drivers/platform/mips/Makefile
 create mode 100644 drivers/platform/mips/acpi_init.c
 create mode 100644 drivers/platform/mips/cpu_hwmon.c
 create mode 100644 drivers/rtc/rtc-digicolor.c
 create mode 100644 drivers/soc/mediatek/Kconfig
 create mode 100644 drivers/soc/mediatek/Makefile
 create mode 100644 drivers/soc/mediatek/mtk-pmic-wrap.c
 delete mode 100644 drivers/target/iscsi/iscsi_target_configfs.h
 delete mode 100644 drivers/target/iscsi/iscsi_target_tq.c
 delete mode 100644 drivers/target/iscsi/iscsi_target_tq.h
 create mode 100644 drivers/tty/mips_ejtag_fdc.c
 delete mode 100644 drivers/tty/serial/mfd.c
 delete mode 100644 drivers/tty/serial/msm_serial_hs.c
 create mode 100644 drivers/virtio/virtio_input.c
 create mode 100644 drivers/xen/xlate_mmu.c
 create mode 100644 fs/ext4/crypto.c
 create mode 100644 fs/ext4/crypto_fname.c
 create mode 100644 fs/ext4/crypto_key.c
 create mode 100644 fs/ext4/crypto_policy.c
 create mode 100644 fs/ext4/ext4_crypto.h
 create mode 100644 fs/ext4/readpage.c
 rename fs/nfs/{idmap.c =3D> nfs4idmap.c} (99%)
 rename include/linux/nfs_idmap.h =3D> fs/nfs/nfs4idmap.h (94%)
 create mode 100644 include/crypto/sha1_base.h
 create mode 100644 include/crypto/sha256_base.h
 create mode 100644 include/crypto/sha512_base.h
 create mode 100644 include/dt-bindings/clock/exynos5433.h
 create mode 100644 include/dt-bindings/clock/pistachio-clk.h
 create mode 100644 include/dt-bindings/clock/qcom,gcc-msm8916.h
 create mode 100644 include/dt-bindings/clock/r8a73a4-clock.h
 create mode 100644 include/dt-bindings/clock/r8a7778-clock.h
 create mode 100644 include/dt-bindings/dma/jz4780-dma.h
 create mode 100644 include/dt-bindings/leds/common.h
 create mode 100644 include/dt-bindings/media/omap3-isp.h
 create mode 100644 include/dt-bindings/media/xilinx-vip.h
 create mode 100644 include/dt-bindings/reset/qcom,gcc-msm8916.h
 create mode 100644 include/linux/acpi_irq.h
 rename {arch/mips/include/asm/mach-bcm47xx =3D> include/linux}/bcm47xx=
_nvram.h (63%)
 create mode 100644 include/linux/dma/hsu.h
 rename include/linux/{amba =3D> dma}/xilinx_dma.h (100%)
 create mode 100644 include/linux/iommu-common.h
 create mode 100644 include/linux/irqchip/arm-gic-acpi.h
 create mode 100644 include/linux/jz4780-nemc.h
 create mode 100644 include/linux/mfd/syscon/atmel-st.h
 delete mode 100644 include/linux/nbd.h
 create mode 100644 include/linux/platform_data/dma-hsu.h
 delete mode 100644 include/linux/platform_data/mmc-msm_sdcc.h
 delete mode 100644 include/linux/platform_data/msm_serial_hs.h
 rename include/linux/platform_data/{tpm_stm_st33.h =3D> st33zp24.h} (6=
0%)
 create mode 100644 include/linux/qcom_scm.h
 delete mode 100644 include/linux/serial_mfd.h
 create mode 100644 include/linux/util_macros.h
 create mode 100644 include/media/ov2659.h
 create mode 100644 include/sound/hda_regmap.h
 create mode 100644 include/sound/hdaudio.h
 create mode 100644 include/trace/events/clk.h
 create mode 100644 include/trace/events/cma.h
 create mode 100644 include/uapi/linux/virtio_input.h
 create mode 100644 include/uapi/linux/xilinx-v4l2-controls.h
 create mode 100644 lib/find_bit.c
 delete mode 100644 lib/find_next_bit.c
 create mode 100644 lib/iommu-common.c
 create mode 100644 net/ceph/crush/crush_ln_table.h
 create mode 100644 net/sunrpc/xprtrdma/fmr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/frwr_ops.c
 create mode 100644 net/sunrpc/xprtrdma/physical_ops.c
 create mode 100755 scripts/check_extable.sh
 mode change 100644 =3D> 100755 scripts/checkkconfigsymbols.py
 create mode 100644 scripts/xen-hypercalls.sh
 create mode 100644 security/tomoyo/policy/exception_policy.conf.defaul=
t
 create mode 100644 sound/hda/Kconfig
 create mode 100644 sound/hda/Makefile
 create mode 100644 sound/hda/array.c
 create mode 100644 sound/hda/hda_bus_type.c
 create mode 100644 sound/hda/hdac_bus.c
 create mode 100644 sound/hda/hdac_device.c
 create mode 100644 sound/hda/hdac_regmap.c
 create mode 100644 sound/hda/hdac_sysfs.c
 create mode 100644 sound/hda/local.h
 create mode 100644 sound/hda/trace.c
 create mode 100644 sound/hda/trace.h
 create mode 100644 sound/pci/hda/hda_bind.c
 delete mode 100644 sound/pci/hda/hda_priv.h
 delete mode 100644 sound/pci/hda/hda_trace.h
 create mode 100644 sound/pci/hda/local.h
 delete mode 100644 sound/soc/atmel/atmel-pcm.c
 create mode 100644 sound/soc/codecs/max98925.c
 create mode 100644 sound/soc/codecs/max98925.h
 create mode 100644 sound/soc/codecs/wm8804-i2c.c
 create mode 100644 sound/soc/codecs/wm8804-spi.c
 delete mode 100644 sound/soc/davinci/davinci-pcm.c
 delete mode 100644 sound/soc/davinci/davinci-pcm.h
 create mode 100644 sound/soc/intel/atom/Makefile
 rename sound/soc/intel/{ =3D> atom}/sst-atom-controls.c (100%)
 rename sound/soc/intel/{ =3D> atom}/sst-atom-controls.h (100%)
 rename sound/soc/intel/{ =3D> atom}/sst-mfld-dsp.h (100%)
 rename sound/soc/intel/{ =3D> atom}/sst-mfld-platform-compress.c (100%=
)
 rename sound/soc/intel/{ =3D> atom}/sst-mfld-platform-pcm.c (94%)
 rename sound/soc/intel/{ =3D> atom}/sst-mfld-platform.h (99%)
 rename sound/soc/intel/{ =3D> atom}/sst/Makefile (100%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst.c (79%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst.h (98%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_acpi.c (99%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_drv_interface.c (92%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_ipc.c (99%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_loader.c (97%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_pci.c (100%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_pvt.c (95%)
 rename sound/soc/intel/{ =3D> atom}/sst/sst_stream.c (99%)
 create mode 100644 sound/soc/intel/baytrail/Makefile
 rename sound/soc/intel/{ =3D> baytrail}/sst-baytrail-dsp.c (99%)
 rename sound/soc/intel/{ =3D> baytrail}/sst-baytrail-ipc.c (71%)
 rename sound/soc/intel/{ =3D> baytrail}/sst-baytrail-ipc.h (100%)
 rename sound/soc/intel/{ =3D> baytrail}/sst-baytrail-pcm.c (99%)
 create mode 100644 sound/soc/intel/boards/Makefile
 rename sound/soc/intel/{ =3D> boards}/broadwell.c (86%)
 rename sound/soc/intel/{ =3D> boards}/byt-max98090.c (94%)
 rename sound/soc/intel/{ =3D> boards}/byt-rt5640.c (98%)
 rename sound/soc/intel/{bytcr_dpcm_rt5640.c =3D> boards/bytcr_rt5640.c=
} (97%)
 rename sound/soc/intel/{ =3D> boards}/cht_bsw_rt5645.c (95%)
 rename sound/soc/intel/{ =3D> boards}/cht_bsw_rt5672.c (75%)
 rename sound/soc/intel/{ =3D> boards}/haswell.c (96%)
 rename sound/soc/intel/{ =3D> boards}/mfld_machine.c (96%)
 create mode 100644 sound/soc/intel/common/Makefile
 rename sound/soc/intel/{ =3D> common}/sst-acpi.c (99%)
 rename sound/soc/intel/{ =3D> common}/sst-dsp-priv.h (97%)
 rename sound/soc/intel/{ =3D> common}/sst-dsp.c (100%)
 rename sound/soc/intel/{ =3D> common}/sst-dsp.h (99%)
 rename sound/soc/intel/{ =3D> common}/sst-firmware.c (99%)
 create mode 100644 sound/soc/intel/common/sst-ipc.c
 create mode 100644 sound/soc/intel/common/sst-ipc.h
 create mode 100644 sound/soc/intel/haswell/Makefile
 rename sound/soc/intel/{ =3D> haswell}/sst-haswell-dsp.c (98%)
 rename sound/soc/intel/{ =3D> haswell}/sst-haswell-ipc.c (77%)
 rename sound/soc/intel/{ =3D> haswell}/sst-haswell-ipc.h (87%)
 rename sound/soc/intel/{ =3D> haswell}/sst-haswell-pcm.c (88%)
 create mode 100644 sound/soc/qcom/Kconfig
 create mode 100644 sound/soc/qcom/Makefile
 create mode 100644 sound/soc/qcom/lpass-cpu.c
 create mode 100644 sound/soc/qcom/lpass-lpaif-ipq806x.h
 create mode 100644 sound/soc/qcom/lpass-platform.c
 create mode 100644 sound/soc/qcom/lpass.h
 create mode 100644 sound/soc/qcom/storm.c
 create mode 100644 sound/soc/sh/rcar/dma.c
 create mode 100644 sound/soc/sh/rcar/rsrc-card.c
 create mode 100644 tools/testing/selftests/powerpc/switch_endian/.giti=
gnore
 create mode 100644 tools/testing/selftests/powerpc/switch_endian/Makef=
ile
 create mode 100644 tools/testing/selftests/powerpc/switch_endian/check=
=2ES
 create mode 100644 tools/testing/selftests/powerpc/switch_endian/commo=
n.h
 create mode 100644 tools/testing/selftests/powerpc/switch_endian/switc=
h_endian_test.S
 create mode 100644 tools/testing/selftests/powerpc/tm/tm-syscall-asm.S
 create mode 100644 tools/testing/selftests/powerpc/tm/tm-syscall.c
 create mode 100644 tools/testing/selftests/powerpc/vphn/.gitignore
 create mode 100644 tools/testing/selftests/powerpc/vphn/Makefile
 create mode 100644 tools/testing/selftests/powerpc/vphn/test-vphn.c
 create mode 120000 tools/testing/selftests/powerpc/vphn/vphn.c
 create mode 120000 tools/testing/selftests/powerpc/vphn/vphn.h
 create mode 100644 tools/testing/selftests/x86/single_step_syscall.c


diff --cc drivers/net/wireless/ath/ath10k/mac.c
index fcd08b2f8d26,eaa0182e001d..000000000000
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@@ -766,9 -1031,68 +1031,48 @@@ static int ath10k_monitor_stop(struct =
a
  	return 0;
  }
 =20
 -static bool ath10k_mac_should_disable_promisc(struct ath10k *ar)
 -{
 -	struct ath10k_vif *arvif;
 -
 -	if (!(ar->filter_flags & FIF_PROMISC_IN_BSS))
 -		return true;
 -
 -	if (!ar->num_started_vdevs)
 -		return false;
 -
 -	list_for_each_entry(arvif, &ar->arvifs, list)
 -		if (arvif->vdev_type !=3D WMI_VDEV_TYPE_AP)
 -			return false;
 -
 -	ath10k_dbg(ar, ATH10K_DBG_MAC,
 -		   "mac disabling promiscuous mode because vdev is started\n");
 -	return true;
 -}
 -
+ static bool ath10k_mac_monitor_vdev_is_needed(struct ath10k *ar)
+ {
+ 	int num_ctx;
+=20
+ 	/* At least one chanctx is required to derive a channel to start
+ 	 * monitor vdev on.
+ 	 */
+ 	num_ctx =3D ath10k_mac_num_chanctxs(ar);
+ 	if (num_ctx =3D=3D 0)
+ 		return false;
+=20
+ 	/* If there's already an existing special monitor interface then don=
't
+ 	 * bother creating another monitor vdev.
+ 	 */
+ 	if (ar->monitor_arvif)
+ 		return false;
+=20
+ 	return ar->monitor ||
 -	       !ath10k_mac_should_disable_promisc(ar) ||
+ 	       test_bit(ATH10K_CAC_RUNNING, &ar->dev_flags);
+ }
+=20
+ static bool ath10k_mac_monitor_vdev_is_allowed(struct ath10k *ar)
+ {
+ 	int num_ctx;
+=20
+ 	num_ctx =3D ath10k_mac_num_chanctxs(ar);
+=20
+ 	/* FIXME: Current interface combinations and cfg80211/mac80211 code
+ 	 * shouldn't allow this but make sure to prevent handling the follow=
ing
+ 	 * case anyway since multi-channel DFS hasn't been tested at all.
+ 	 */
+ 	if (test_bit(ATH10K_CAC_RUNNING, &ar->dev_flags) && num_ctx > 1)
+ 		return false;
+=20
+ 	return true;
+ }
+=20
  static int ath10k_monitor_recalc(struct ath10k *ar)
  {
- 	bool should_start;
+ 	bool needed;
+ 	bool allowed;
+ 	int ret;
 =20
  	lockdep_assert_held(&ar->conf_mutex);
 =20
@@@ -871,12 -1231,46 +1211,46 @@@ static void ath10k_recalc_radar_detec=
ti
  	}
  }
 =20
- static int ath10k_vdev_start_restart(struct ath10k_vif *arvif, bool r=
estart)
+ static int ath10k_vdev_stop(struct ath10k_vif *arvif)
+ {
+ 	struct ath10k *ar =3D arvif->ar;
+ 	int ret;
+=20
+ 	lockdep_assert_held(&ar->conf_mutex);
+=20
+ 	reinit_completion(&ar->vdev_setup_done);
+=20
+ 	ret =3D ath10k_wmi_vdev_stop(ar, arvif->vdev_id);
+ 	if (ret) {
+ 		ath10k_warn(ar, "failed to stop WMI vdev %i: %d\n",
+ 			    arvif->vdev_id, ret);
+ 		return ret;
+ 	}
+=20
+ 	ret =3D ath10k_vdev_setup_sync(ar);
+ 	if (ret) {
+ 		ath10k_warn(ar, "failed to syncronise setup for vdev %i: %d\n",
+ 			    arvif->vdev_id, ret);
+ 		return ret;
+ 	}
+=20
+ 	WARN_ON(ar->num_started_vdevs =3D=3D 0);
+=20
+ 	if (ar->num_started_vdevs !=3D 0) {
+ 		ar->num_started_vdevs--;
+ 		ath10k_recalc_radar_detection(ar);
+ 	}
+=20
+ 	return ret;
+ }
+=20
+ static int ath10k_vdev_start_restart(struct ath10k_vif *arvif,
+ 				     const struct cfg80211_chan_def *chandef,
+ 				     bool restart)
  {
  	struct ath10k *ar =3D arvif->ar;
- 	struct cfg80211_chan_def *chandef =3D &ar->chandef;
  	struct wmi_vdev_start_request_arg arg =3D {};
 -	int ret =3D 0, ret2;
 +	int ret =3D 0;
 =20
  	lockdep_assert_held(&ar->conf_mutex);
 =20
@@@ -5499,9 -6915,14 +6884,15 @@@ int ath10k_mac_register(struct ath10k=
 *
  			IEEE80211_HW_AP_LINK_PS |
  			IEEE80211_HW_SPECTRUM_MGMT |
  			IEEE80211_HW_SW_CRYPTO_CONTROL |
+ 			IEEE80211_HW_CONNECTION_MONITOR |
+ 			IEEE80211_HW_SUPPORTS_PER_STA_GTK |
+ 			IEEE80211_HW_WANT_MONITOR_VIF |
+ 			IEEE80211_HW_CHANCTX_STA_CSA |
 -			IEEE80211_HW_QUEUE_CONTROL;
++			IEEE80211_HW_QUEUE_CONTROL |
 +			IEEE80211_HW_SUPPORT_FAST_XMIT;
 =20
  	ar->hw->wiphy->features |=3D NL80211_FEATURE_STATIC_SMPS;
+ 	ar->hw->wiphy->flags |=3D WIPHY_FLAG_IBSS_RSN;
 =20
  	if (ar->ht_cap_info & WMI_HT_CAP_DYNAMIC_SMPS)
  		ar->hw->wiphy->features |=3D NL80211_FEATURE_DYNAMIC_SMPS;
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
