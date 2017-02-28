From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: usb/net/hso: WARNING: ungligned urb->setup_dma
Date: Tue, 28 Feb 2017 20:07:00 +0200
Message-ID: <20170228180700.3fxpimfysnhm6uis@tarshish>
References: <20170228082810.syn656o2zzms7urf@tarshish>
 <20170228120134.4f65yihw7x22hfwd@tarshish>
 <36230d64-4ba0-7515-1131-ecf3ab9f352c@i2se.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ierjizk7cpd5qbvt"
Cc: John Youn <johnyoun@synopsys.com>, netdev@vger.kernel.org,
 linux-usb@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>,
 linux-rpi-kernel@lists.infradead.org, linux-arm-kernel@lists.infradead.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <36230d64-4ba0-7515-1131-ecf3ab9f352c@i2se.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--ierjizk7cpd5qbvt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Stefan,

On Tue, Feb 28, 2017 at 05:21:18PM +0100, Stefan Wahren wrote:
> Am 28.02.2017 um 13:01 schrieb Baruch Siach:
> > On Tue, Feb 28, 2017 at 10:28:10AM +0200, Baruch Siach wrote:
> > > I'm hitting this warning consistently on my Raspberry Pi 3 running 
> > > kernel
> > > v4.10.1 with some unrelated device tree changes, and a debug print (below).
> > > The device identifies as "GlobeTrotter HSDPA Modem", VID: 0af0, PID: 6971.
> > > The warning triggers consistently on first write access to /dev/ttyHS0 that
> > > ModemManager attempts. The first line in the log is my debug print.
> > I tested the same hardware successfully on an i.MX6 CuBox-i (ARM32) using the
> > same kernel version (4.10.1), and on an x86_64 PC (4.9). So this seems to be
> > platform specific. I don't have any other ARM64 machine at the moment, though.
> 
> those platforms usually doesn't use the dwc2 USB host controller. So it
> should be tested with another dwc2 platform.

The code that initializes setup_dma is not under drivers/usb/dwc2/. Though the 
problem looks like memory corruption, so its cause might be anywhere.

> Is the issue reproducible with other USB devices like keyboards?

Other USB devices, including a different cellular USB dongle, do not exhibit 
the same problem.

> Are you using arm64 defconfig?

I'm using that attached arm64 defconfig.

> Are you able to bisect this issue?

I don't have any previously working point.

Thanks,
baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -

--ierjizk7cpd5qbvt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=defconfig

CONFIG_SYSVIPC=y
CONFIG_POSIX_MQUEUE=y
CONFIG_AUDIT=y
CONFIG_NO_HZ_IDLE=y
CONFIG_HIGH_RES_TIMERS=y
CONFIG_BSD_PROCESS_ACCT=y
CONFIG_BSD_PROCESS_ACCT_V3=y
CONFIG_TASKSTATS=y
CONFIG_TASK_DELAY_ACCT=y
CONFIG_TASK_XACCT=y
CONFIG_TASK_IO_ACCOUNTING=y
CONFIG_IKCONFIG=y
CONFIG_IKCONFIG_PROC=y
CONFIG_MEMCG=y
CONFIG_MEMCG_SWAP=y
CONFIG_BLK_CGROUP=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CPUSETS=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_PERF=y
CONFIG_USER_NS=y
CONFIG_SCHED_AUTOGROUP=y
CONFIG_BLK_DEV_INITRD=y
# CONFIG_RD_BZIP2 is not set
# CONFIG_RD_LZMA is not set
# CONFIG_RD_XZ is not set
# CONFIG_RD_LZO is not set
# CONFIG_RD_LZ4 is not set
CONFIG_KALLSYMS_ALL=y
# CONFIG_COMPAT_BRK is not set
CONFIG_PROFILING=y
CONFIG_JUMP_LABEL=y
CONFIG_BLK_DEV_INTEGRITY=y
# CONFIG_IOSCHED_DEADLINE is not set
CONFIG_ARCH_BCM2835=y
CONFIG_ARM64_VA_BITS_48=y
CONFIG_SCHED_MC=y
CONFIG_HOTPLUG_CPU=y
CONFIG_PREEMPT=y
CONFIG_KSM=y
CONFIG_TRANSPARENT_HUGEPAGE=y
CONFIG_CMA=y
CONFIG_SECCOMP=y
CONFIG_CMDLINE="root=/dev/mmcblk0p2 rootwait console=ttyS0,115200"
CONFIG_CMDLINE_FORCE=y
# CONFIG_EFI is not set
# CONFIG_CORE_DUMP_DEFAULT_ELF_HEADERS is not set
CONFIG_COMPAT=y
# CONFIG_SUSPEND is not set
CONFIG_PM=y
CONFIG_CPU_IDLE=y
CONFIG_ARM_CPUIDLE=y
CONFIG_CPU_FREQ=y
CONFIG_CPUFREQ_DT=y
CONFIG_ARM_BIG_LITTLE_CPUFREQ=y
CONFIG_NET=y
CONFIG_PACKET=y
CONFIG_UNIX=y
CONFIG_INET=y
CONFIG_IP_MULTICAST=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
CONFIG_IP_PNP_BOOTP=y
CONFIG_NETFILTER=y
CONFIG_NF_CONNTRACK=y
CONFIG_NF_CONNTRACK_EVENTS=y
CONFIG_NETFILTER_XT_TARGET_CHECKSUM=y
CONFIG_NETFILTER_XT_TARGET_LOG=y
CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NF_CONNTRACK_IPV4=y
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_NAT=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_MANGLE=y
CONFIG_NF_CONNTRACK_IPV6=y
CONFIG_IP6_NF_IPTABLES=y
CONFIG_IP6_NF_FILTER=y
CONFIG_IP6_NF_TARGET_REJECT=y
CONFIG_IP6_NF_MANGLE=y
CONFIG_IP6_NF_NAT=y
CONFIG_IP6_NF_TARGET_MASQUERADE=y
CONFIG_BRIDGE=y
CONFIG_BRIDGE_VLAN_FILTERING=y
CONFIG_VLAN_8021Q=y
CONFIG_VLAN_8021Q_GVRP=y
CONFIG_VLAN_8021Q_MVRP=y
CONFIG_BT=y
CONFIG_BT_BNEP=y
CONFIG_BT_BNEP_MC_FILTER=y
CONFIG_BT_BNEP_PROTO_FILTER=y
CONFIG_BT_HIDP=y
# CONFIG_BT_HS is not set
CONFIG_BT_LEDS=y
CONFIG_BT_HCIUART=y
CONFIG_BT_HCIUART_BCM=y
CONFIG_RFKILL=y
CONFIG_RFKILL_REGULATOR=y
CONFIG_UEVENT_HELPER_PATH="/sbin/hotplug"
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
CONFIG_DMA_CMA=y
CONFIG_VEXPRESS_CONFIG=y
CONFIG_BLK_DEV_LOOP=y
CONFIG_SRAM=y
# CONFIG_VEXPRESS_SYSCFG is not set
CONFIG_SCSI=y
# CONFIG_SCSI_PROC_FS is not set
CONFIG_BLK_DEV_SD=y
CONFIG_CHR_DEV_SG=y
CONFIG_SCSI_SAS_LIBSAS=y
# CONFIG_SCSI_LOWLEVEL is not set
CONFIG_NETDEVICES=y
CONFIG_TUN=y
CONFIG_VETH=y
# CONFIG_ETHERNET is not set
CONFIG_PPP=y
CONFIG_PPP_BSDCOMP=y
CONFIG_PPP_DEFLATE=y
CONFIG_PPP_ASYNC=y
CONFIG_USB_USBNET=y
# CONFIG_USB_NET_AX8817X is not set
# CONFIG_USB_NET_AX88179_178A is not set
CONFIG_USB_NET_HUAWEI_CDC_NCM=y
CONFIG_USB_NET_CDC_MBIM=y
CONFIG_USB_NET_SMSC95XX=y
# CONFIG_USB_NET_NET1080 is not set
# CONFIG_USB_NET_CDC_SUBSET is not set
# CONFIG_USB_NET_ZAURUS is not set
CONFIG_USB_HSO=y
# CONFIG_WLAN is not set
CONFIG_INPUT_EVDEV=y
CONFIG_KEYBOARD_GPIO=y
CONFIG_INPUT_MISC=y
# CONFIG_SERIO_SERPORT is not set
CONFIG_SERIO_AMBAKMI=y
CONFIG_LEGACY_PTY_COUNT=16
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_EXTENDED=y
CONFIG_SERIAL_8250_SHARE_IRQ=y
CONFIG_SERIAL_8250_BCM2835AUX=y
CONFIG_SERIAL_8250_DW=y
CONFIG_SERIAL_OF_PLATFORM=y
CONFIG_SERIAL_AMBA_PL011=y
CONFIG_SERIAL_AMBA_PL011_CONSOLE=y
CONFIG_SERIAL_XILINX_PS_UART=y
CONFIG_SERIAL_XILINX_PS_UART_CONSOLE=y
CONFIG_I2C=y
CONFIG_I2C_CHARDEV=y
CONFIG_I2C_MUX=y
CONFIG_I2C_BCM2835=y
CONFIG_SPI=y
CONFIG_SPI_BCM2835=y
CONFIG_SPI_BCM2835AUX=y
CONFIG_PPS=y
CONFIG_PINCTRL_SINGLE=y
CONFIG_GPIO_GENERIC_PLATFORM=y
CONFIG_POWER_RESET_GPIO=y
# CONFIG_HWMON is not set
CONFIG_WATCHDOG=y
CONFIG_BCM2835_WDT=y
CONFIG_MFD_RK808=y
CONFIG_MFD_SYSCON=y
# CONFIG_MFD_VEXPRESS_SYSREG is not set
CONFIG_REGULATOR=y
CONFIG_REGULATOR_FIXED_VOLTAGE=y
CONFIG_REGULATOR_GPIO=y
CONFIG_REGULATOR_PWM=y
CONFIG_REGULATOR_RK808=y
CONFIG_FB=y
CONFIG_FB_ARMCLCD=y
# CONFIG_LCD_CLASS_DEVICE is not set
# CONFIG_BACKLIGHT_GENERIC is not set
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y
# CONFIG_HID_GENERIC is not set
# CONFIG_HID_A4TECH is not set
# CONFIG_HID_APPLE is not set
# CONFIG_HID_BELKIN is not set
# CONFIG_HID_CHERRY is not set
# CONFIG_HID_CHICONY is not set
# CONFIG_HID_CYPRESS is not set
# CONFIG_HID_EZKEY is not set
# CONFIG_HID_KENSINGTON is not set
# CONFIG_HID_LOGITECH is not set
# CONFIG_HID_MICROSOFT is not set
# CONFIG_HID_MONTEREY is not set
# CONFIG_USB_HID is not set
CONFIG_USB=y
CONFIG_USB_EHCI_HCD=y
CONFIG_USB_EHCI_ROOT_HUB_TT=y
CONFIG_USB_EHCI_HCD_PLATFORM=y
CONFIG_USB_OHCI_HCD=y
CONFIG_USB_OHCI_HCD_PLATFORM=y
CONFIG_USB_STORAGE=y
CONFIG_USB_DWC2=y
CONFIG_USB_ULPI=y
CONFIG_MMC=y
# CONFIG_PWRSEQ_SIMPLE is not set
CONFIG_MMC_SDHCI=y
CONFIG_MMC_SDHCI_PLTFM=y
CONFIG_MMC_SDHCI_IPROC=y
CONFIG_NEW_LEDS=y
CONFIG_LEDS_CLASS=y
CONFIG_LEDS_GPIO=y
CONFIG_LEDS_SYSCON=y
CONFIG_LEDS_TRIGGER_HEARTBEAT=y
CONFIG_LEDS_TRIGGER_CPU=y
CONFIG_DMADEVICES=y
CONFIG_DMA_BCM2835=y
CONFIG_SYNC_FILE=y
# CONFIG_COMMON_CLK_XGENE is not set
# CONFIG_FSL_ERRATUM_A008585 is not set
CONFIG_MAILBOX=y
CONFIG_BCM2835_MBOX=y
# CONFIG_IOMMU_SUPPORT is not set
CONFIG_RASPBERRYPI_POWER=y
CONFIG_PWM=y
CONFIG_PWM_BCM2835=y
CONFIG_RASPBERRYPI_FIRMWARE=y
CONFIG_EXT4_FS=y
CONFIG_EXT4_FS_POSIX_ACL=y
# CONFIG_DNOTIFY is not set
CONFIG_FANOTIFY=y
CONFIG_QUOTA=y
CONFIG_VFAT_FS=y
CONFIG_TMPFS=y
CONFIG_HUGETLBFS=y
CONFIG_CONFIGFS_FS=y
# CONFIG_MISC_FILESYSTEMS is not set
# CONFIG_NETWORK_FILESYSTEMS is not set
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_ISO8859_1=y
CONFIG_PRINTK_TIME=y
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_FS=y
CONFIG_MAGIC_SYSRQ=y
CONFIG_DEBUG_KERNEL=y
CONFIG_LOCKUP_DETECTOR=y
# CONFIG_SCHED_DEBUG is not set
# CONFIG_DEBUG_PREEMPT is not set
# CONFIG_FTRACE is not set
CONFIG_MEMTEST=y
CONFIG_CRYPTO_AUTHENC=y
CONFIG_CRYPTO_CCM=y
CONFIG_CRYPTO_GCM=y
CONFIG_CRYPTO_ARC4=y
CONFIG_CRYPTO_ANSI_CPRNG=y
CONFIG_ARM64_CRYPTO=y
CONFIG_CRYPTO_SHA1_ARM64_CE=y
CONFIG_CRYPTO_SHA2_ARM64_CE=y
CONFIG_CRYPTO_GHASH_ARM64_CE=y
CONFIG_CRYPTO_AES_ARM64_CE_CCM=y
CONFIG_CRYPTO_AES_ARM64_CE_BLK=y
CONFIG_CRYPTO_CRC32_ARM64=y
CONFIG_CRC_ITU_T=y
CONFIG_CRC7=y

--ierjizk7cpd5qbvt
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--ierjizk7cpd5qbvt--
