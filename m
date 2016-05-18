From: Reinoud Koornstra <reinoudkoornstra@gmail.com>
Subject: Re: [GIT] Networking
Date: Wed, 18 May 2016 06:20:14 -0600
Message-ID: <CAAA5faF=SxqCt0yDTbPyUoc3gFD--_co+fRj2Jfuy=whEQvcBQ@mail.gmail.com>
References: <20160517.151113.367799295750703003.davem@davemloft.net>
	<CA+55aFw_JRGNo3HYP3c=3VoGw_uYBP_h2OmxOMcUGsU=L43btw@mail.gmail.com>
	<CANUX_P3n0ZkTw0fY8wD3biu2mLzrwyX7n=bo1otw9m0bpfS07Q@mail.gmail.com>
	<1463568714.13625.18.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"egrumbach@gmail.com" <egrumbach@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
To: "Coelho, Luciano" <luciano.coelho@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463568714.13625.18.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 18, 2016 at 4:51 AM, Coelho, Luciano
<luciano.coelho@intel.com> wrote:
> Hi Emmanuel, Linus,
>
>
> On Wed, 2016-05-18 at 06:37 +0300, Emmanuel Grumbach wrote:
>> On Wed, May 18, 2016 at 4:00 AM, Linus Torvalds
>> <torvalds@linux-foundation.org> wrote:
>> >
>> > On Tue, May 17, 2016 at 12:11 PM, David Miller <davem@davemloft.net
>> > > wrote:
>> > >
>> > >
>> > > Highlights:
>> > Lowlights:
>> >
>> >  1) the iwlwifi driver seems to be broken
>> >
>> > My laptop that uses the intel 7680 iwlwifi module no longer
>> > connects
>> > to the network. It fails with a "Microcode SW error detected." and
>> > spews out register state over and over again.
>> Can we have the register state and the ASSERT / NMI / whatever that
>> goes along with it?
>> This clearly means that the firmware is crashing, but I don't know
>> why,
>> I copied here the lines that I need from another bug with another
>> device with another firmware,
>> but the log that we will still explain what I need:
>
> I managed to reproduce this bug locally with Linus' master.  I'm
> investigating the cause and I'll let you how it goes.

I did run the latest git code as well 4.6+
iwlwifi went pearshape in my case as well.
I just updated the microcode as well, it didn't matter.
4.6-rc7 works fine and no errors are reported with iwlwifi.

Here's output that might come in handy

[   17.436340] iwlwifi 0000:04:00.0: loaded firmware version
16.242414.0 op_mode iwlmvm
[   17.714920] iwlwifi 0000:04:00.0: Detected Intel(R) Dual Band
Wireless AC 7260, REV=0x144

SNIP
[  114.837923] wlp4s0: authenticate with 00:30:44:1d:cf:2b
[  114.841365] wlp4s0: send auth to 00:30:44:1d:cf:2b (try 1/3)
[  114.842073] wlp4s0: send auth to 00:30:44:1d:cf:2b (try 2/3)
[  115.041992] iwlwifi 0000:04:00.0: Microcode SW error detected.
Restarting 0x2000000.
[  115.041995] iwlwifi 0000:04:00.0: CSR values:
[  115.041996] iwlwifi 0000:04:00.0: (2nd byte of CSR_INT_COALESCING
is CSR_INT_PERIODIC_REG)
[  115.042000] iwlwifi 0000:04:00.0:        CSR_HW_IF_CONFIG_REG: 0X40489204
[  115.042003] iwlwifi 0000:04:00.0:          CSR_INT_COALESCING: 0X80000040
[  115.042006] iwlwifi 0000:04:00.0:                     CSR_INT: 0X00000000
[  115.042009] iwlwifi 0000:04:00.0:                CSR_INT_MASK: 0X00000000
[  115.042013] iwlwifi 0000:04:00.0:           CSR_FH_INT_STATUS: 0X00000000
[  115.042016] iwlwifi 0000:04:00.0:                 CSR_GPIO_IN: 0X00000000
[  115.042019] iwlwifi 0000:04:00.0:                   CSR_RESET: 0X00000000
[  115.042022] iwlwifi 0000:04:00.0:                CSR_GP_CNTRL: 0X080403c5
[  115.042026] iwlwifi 0000:04:00.0:                  CSR_HW_REV: 0X00000144
[  115.042029] iwlwifi 0000:04:00.0:              CSR_EEPROM_REG: 0X00000000
[  115.042032] iwlwifi 0000:04:00.0:               CSR_EEPROM_GP: 0X80000000
[  115.042035] iwlwifi 0000:04:00.0:              CSR_OTP_GP_REG: 0X803a0000
[  115.042038] iwlwifi 0000:04:00.0:                 CSR_GIO_REG: 0X001f0044
[  115.042042] iwlwifi 0000:04:00.0:            CSR_GP_UCODE_REG: 0X00000000
[  115.042045] iwlwifi 0000:04:00.0:           CSR_GP_DRIVER_REG: 0X00000000
[  115.042048] iwlwifi 0000:04:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
[  115.042051] iwlwifi 0000:04:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
[  115.042054] iwlwifi 0000:04:00.0:                 CSR_LED_REG: 0X00000060
[  115.042058] iwlwifi 0000:04:00.0:        CSR_DRAM_INT_TBL_REG: 0X88035a74
[  115.042061] iwlwifi 0000:04:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
[  115.042064] iwlwifi 0000:04:00.0:             CSR_ANA_PLL_CFG: 0Xd55555d5
[  115.042067] iwlwifi 0000:04:00.0:      CSR_MONITOR_STATUS_REG: 0X3d0801bd
[  115.042070] iwlwifi 0000:04:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
[  115.042074] iwlwifi 0000:04:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
[  115.042075] iwlwifi 0000:04:00.0: FH register values:
[  115.042086] iwlwifi 0000:04:00.0:
FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X455fd200
[  115.042097] iwlwifi 0000:04:00.0:
FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X04556370
[  115.042108] iwlwifi 0000:04:00.0:
FH_RSCSR_CHNL0_WPTR: 0X00000078
[  115.042119] iwlwifi 0000:04:00.0:
FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X00801114
[  115.042129] iwlwifi 0000:04:00.0:
FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
[  115.042140] iwlwifi 0000:04:00.0:
FH_MEM_RSSR_RX_STATUS_REG: 0X03030000
[  115.042151] iwlwifi 0000:04:00.0:
FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
[  115.042162] iwlwifi 0000:04:00.0:
FH_TSSR_TX_STATUS_REG: 0X07ff0001
[  115.042173] iwlwifi 0000:04:00.0:
FH_TSSR_TX_ERROR_REG: 0X00000000
[  115.042278] iwlwifi 0000:04:00.0: Start IWL Error Log Dump:
[  115.042279] iwlwifi 0000:04:00.0: Status: 0x00000000, count: 6
[  115.042280] iwlwifi 0000:04:00.0: Loaded firmware version: 16.242414.0
[  115.042281] iwlwifi 0000:04:00.0: 0x00000034 | NMI_INTERRUPT_WDG
[  115.042282] iwlwifi 0000:04:00.0: 0x059002A0 | trm_hw_status0
[  115.042283] iwlwifi 0000:04:00.0: 0x00000000 | trm_hw_status1
[  115.042284] iwlwifi 0000:04:00.0: 0x00000B2C | branchlink2
[  115.042285] iwlwifi 0000:04:00.0: 0x00016A90 | interruptlink1
[  115.042286] iwlwifi 0000:04:00.0: 0x00017E2A | interruptlink2
[  115.042287] iwlwifi 0000:04:00.0: 0x00000000 | data1
[  115.042288] iwlwifi 0000:04:00.0: 0x00000002 | data2
[  115.042289] iwlwifi 0000:04:00.0: 0x07030000 | data3
[  115.042290] iwlwifi 0000:04:00.0: 0xFE86F74B | beacon time
[  115.042291] iwlwifi 0000:04:00.0: 0x0500DB8F | tsf low
[  115.042292] iwlwifi 0000:04:00.0: 0x00000000 | tsf hi
[  115.042293] iwlwifi 0000:04:00.0: 0x0FFCF2CD | time gp1
[  115.042294] iwlwifi 0000:04:00.0: 0x0500DB90 | time gp2
[  115.042295] iwlwifi 0000:04:00.0: 0x00000000 | uCode revision type
[  115.042296] iwlwifi 0000:04:00.0: 0x00000010 | uCode version major
[  115.042297] iwlwifi 0000:04:00.0: 0x0003B2EE | uCode version minor
[  115.042298] iwlwifi 0000:04:00.0: 0x00000144 | hw version
[  115.042299] iwlwifi 0000:04:00.0: 0x40489204 | board version
[  115.042300] iwlwifi 0000:04:00.0: 0x0000001C | hcmd
[  115.042301] iwlwifi 0000:04:00.0: 0xA6EA3808 | isr0
[  115.042302] iwlwifi 0000:04:00.0: 0x10818000 | isr1
[  115.042303] iwlwifi 0000:04:00.0: 0x00000002 | isr2
[  115.042304] iwlwifi 0000:04:00.0: 0x4041FCC7 | isr3
[  115.042305] iwlwifi 0000:04:00.0: 0x00000000 | isr4
[  115.042306] iwlwifi 0000:04:00.0: 0x10810112 | last cmd Id
[  115.042307] iwlwifi 0000:04:00.0: 0x00000000 | wait_event
[  115.042307] iwlwifi 0000:04:00.0: 0x00000050 | l2p_control
[  115.042308] iwlwifi 0000:04:00.0: 0x00018020 | l2p_duration
[  115.042309] iwlwifi 0000:04:00.0: 0x0000003F | l2p_mhvalid
[  115.042310] iwlwifi 0000:04:00.0: 0x00000081 | l2p_addr_match
[  115.042311] iwlwifi 0000:04:00.0: 0x00000005 | lmpm_pmg_sel
[  115.042312] iwlwifi 0000:04:00.0: 0x17111905 | timestamp
[  115.042313] iwlwifi 0000:04:00.0: 0x00347888 | flow_handler
[  115.042316] ieee80211 phy0: Hardware restart was requested
[  115.385259] iwlwifi 0000:04:00.0: L1 Disabled - LTR Enabled
[  115.385483] iwlwifi 0000:04:00.0: L1 Disabled - LTR Enabled
[  115.590186] iwlwifi 0000:04:00.0: L1 Disabled - LTR Enabled
[  115.590424] iwlwifi 0000:04:00.0: L1 Disabled - LTR Enabled
[  115.605968] wlp4s0: send auth to 00:30:44:1d:cf:2b (try 3/3)
[  116.219795] iwlwifi 0000:04:00.0: No association and the time event
is over already...
[  116.219850] wlp4s0: Connection to AP 00:30:44:1d:cf:2b lost
[  116.781404] wlp4s0: authentication with 00:30:44:1d:cf:2b timed out
[  116.793625] iwlwifi 0000:04:00.0: Couldn't drain frames for staid 0
[  116.793631] ------------[ cut here ]------------
[  116.793660] WARNING: CPU: 0 PID: 70 at net/mac80211/sta_info.c:963
__sta_info_destroy_part2+0x1a7/0x1b0 [mac80211]
[  116.793662] Modules linked in: pl2303 usbserial
x86_pkg_temp_thermal intel_powerclamp arc4 snd_hda_codec_hdmi iwlmvm
coretemp mac80211 snd_hda_codec_realtek snd_hda_codec_generic
kvm_intel kvm irqbypass crct10dif_pclmul crc32_pclmul i2c_design
ware_platform ghash_clmulni_intel 8250_dw iwlwifi i2c_designware_core
aesni_intel aes_x86_64 snd_hda_intel lrw snd_hda_codec gf128mul
glue_helper ablk_helper cryptd input_leds snd_hda_core snd_hwdep
cfg80211 serio_raw 8250_fintek snd_pcm snd_seq_
midi snd_seq_midi_event snd_rawmidi snd_seq snd_seq_device snd_timer
shpchp snd mei_me mei soundcore intel_lpss_acpi intel_lpss_pci
intel_lpss acpi_als mac_hid kfifo_buf industrialio acpi_pad parport_pc
ppdev lp parport autofs4 xfs libcrc32c i915
 i2c_algo_bit drm_kms_helper syscopyarea sysfillrect sysimgblt hid_generic
[  116.793714]  fb_sys_fops usbhid mxm_wmi i2c_hid ahci r8169 mii drm
libahci hid wmi pinctrl_sunrisepoint video pinctrl_intel
[  116.793727] CPU: 0 PID: 70 Comm: kworker/u16:1 Tainted: G     U
     4.6.0+ #1
[  116.793730] Hardware name: MSI MS-7971/Z170A PC MATE (MS-7971),
BIOS A.70 01/25/2016
[  116.793755] Workqueue: phy0 ieee80211_iface_work [mac80211]
[  116.793758]  0000000000000286 00000000212b48cb ffff88045a4c7c58
ffffffff813ec315
[  116.793762]  0000000000000000 0000000000000000 ffff88045a4c7c98
ffffffff81081d7b
[  116.793766]  000003c3c0728d9a ffff88042b85a000 ffff880459054720
ffff88045bd4c840
[  116.793770] Call Trace:
[  116.793777]  [<ffffffff813ec315>] dump_stack+0x85/0xc0
[  116.793782]  [<ffffffff81081d7b>] __warn+0xcb/0xf0
[  116.793786]  [<ffffffff81081ead>] warn_slowpath_null+0x1d/0x20
[  116.793807]  [<ffffffffc072dfd7>]
__sta_info_destroy_part2+0x1a7/0x1b0 [mac80211]
[  116.793826]  [<ffffffffc072e00a>] __sta_info_destroy+0x2a/0x40 [mac80211]
[  116.793845]  [<ffffffffc072e058>] sta_info_destroy_addr+0x38/0x60 [mac80211]
[  116.793874]  [<ffffffffc0773227>]
ieee80211_destroy_auth_data+0x37/0xc0 [mac80211]
[  116.793904]  [<ffffffffc077a551>] ieee80211_sta_work+0x511/0x760 [mac80211]
[  116.793927]  [<ffffffffc073d750>] ieee80211_iface_work+0x370/0x410 [mac80211]
[  116.793932]  [<ffffffff810a981b>] ? finish_task_switch+0x7b/0x200
[  116.793937]  [<ffffffff8109c32d>] process_one_work+0x16d/0x480
[  116.793942]  [<ffffffff8109c68b>] worker_thread+0x4b/0x510
[  116.793947]  [<ffffffff8109c640>] ? process_one_work+0x480/0x480
[  116.793951]  [<ffffffff8109c640>] ? process_one_work+0x480/0x480
[  116.793955]  [<ffffffff810a2968>] kthread+0xd8/0xf0
[  116.793961]  [<ffffffff81845d0f>] ret_from_fork+0x1f/0x40
[  116.793964]  [<ffffffff810a2890>] ? kthread_create_on_node+0x1a0/0x1a0
[  116.793967] ---[ end trace 8fa8ad606433a1bc ]---



>
> --
> Cheers,
> Luca.
