From: Nick Kossifidis <mickflemm@gmail.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Thu, 5 May 2011 18:15:46 +0300
Message-ID: <BANLkTinVT7cwkuBt3x+JrSU-pDNj7mtT7w@mail.gmail.com>
References: <20110504153819.GA4551@thinkpad-t410>
	<20110504172716.GC18541@tuxdriver.com>
	<20110504192639.GB4551@thinkpad-t410>
	<BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
	<20110505135207.GA13727@thinkpad-t410>
	<BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
	<4DC2BBBE.1090607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DC2BBBE.1090607@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/5/5 Justin P. Mattock <justinmattock@gmail.com>:
> On 05/05/2011 07:30 AM, Nick Kossifidis wrote:
>>
>> 2011/5/5 Seth Forshee<seth.forshee@canonical.com>:
>>>
>>> On Wed, May 04, 2011 at 11:09:03PM +0300, Nick Kossifidis wrote:
>>>>
>>>> 2011/5/4 Seth Forshee<seth.forshee@canonical.com>:
>>>>>
>>>>> On Wed, May 04, 2011 at 01:27:17PM -0400, John W. Linville wrote:
>>>>>>
>>>>>> On Wed, May 04, 2011 at 10:38:19AM -0500, Seth Forshee wrote:
>>>>>>>
>>>>>>> I've been investigating some reports of a regression in associa=
ting
>>>>>>> with
>>>>>>> APs with AR2413 in 2.6.38. Association repeatedly fails with so=
me
>>>>>>> "direct probe to x timed out" messages (see syslog excerpt belo=
w),
>>>>>>> although it will generally associate eventually, after many tri=
es.
>>>>>>>
>>>>>>> Bisection identifies 8aec7af (ath5k: Support synth-only channel
>>>>>>> change
>>>>>>> for AR2413/AR5413) as offending commit. Prior to this commit th=
ere
>>>>>>> are
>>>>>>> no direct probe messages at all in the logs. I've also found th=
at
>>>>>>> forcing fast to false at the top of ath5k_hw_reset() fixes the =
issue.
>>>>>>> I'm not sure what the connection is between this commit and the
>>>>>>> timeouts. Any suggestions?
>>>>>>
>>>>>> Have you tried reverting that commit on top of 2.6.38? =C2=A0Can=
 you
>>>>>> recreate the issue with 2.6.39-rc6 (or later)?
>>>>>
>>>>> I started to revert that commit, but it wasn't straight-forward d=
ue to
>>>>> later changes. Forcing fast to false in ath5k_hw_reset() acts as =
a
>>>>> functional revert of sorts since that should force it back to a f=
ull
>>>>> reset for all channel changes, and it's much simpler than working=
 out
>>>>> the right way to revert the commit. I think the results suggest
>>>>> strongly
>>>>> that a revert is likely to fix the problem. I can finish the work=
 to
>>>>> revert if you'd still like to see the results.
>>>>>
>>>>> Testing a previous .39-rc kernel still exhibited the failure. I d=
on't
>>>>> recall which one it was and apparently forgot to make note of it.=
 I'll
>>>>> request testing against rc6.
>>>>>
>>>>> Thanks,
>>>>> Seth
>>>>>
>>>>
>>>> Do you get scan results ?
>>>> Can you enable ATH5K_DEBUG_RESET and see what you get ?
>>>
>>> 2.6.39-rc6 still fails. A more comprehensive log with ATH5K_DEBUG_R=
ESET
>>> enabled is below.
>>>
>>> Scanning looks to be failing according to this log. I was thinking =
that
>>> I saw successfull scans in some of the previous logs, but I'll have=
 to
>>> go back and check to be sure.
>>>
>>> Thanks,
>>> Seth
>>>
>>>
>>> kernel: [ =C2=A0 23.421242] ath5k 0000:06:02.0: PCI INT A -> =C2=A0=
GSI 22 (level,
>>> low) -> =C2=A0IRQ 22
>>> kernel: [ =C2=A0 23.421312] ath5k 0000:06:02.0: registered as 'phy0=
'
>>> kernel: [ =C2=A0 24.132959] ath: EEPROM regdomain: 0x63
>>> kernel: [ =C2=A0 24.132962] ath: EEPROM indicates we should expect =
a direct
>>> regpair map
>>> kernel: [ =C2=A0 24.132967] ath: Country alpha2 being used: 00
>>> kernel: [ =C2=A0 24.132969] ath: Regpair used: 0x63
>>> kernel: [ =C2=A0 24.136125] cfg80211: Updating information on frequ=
ency 2412
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136131] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136134] cfg80211: Updating information on frequ=
ency 2417
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136137] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136140] cfg80211: Updating information on frequ=
ency 2422
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136143] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136146] cfg80211: Updating information on frequ=
ency 2427
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136149] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136151] cfg80211: Updating information on frequ=
ency 2432
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136155] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136157] cfg80211: Updating information on frequ=
ency 2437
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136160] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136163] cfg80211: Updating information on frequ=
ency 2442
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136166] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136168] cfg80211: Updating information on frequ=
ency 2447
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136172] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136174] cfg80211: Updating information on frequ=
ency 2452
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136177] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136180] cfg80211: Updating information on frequ=
ency 2457
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136183] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136186] cfg80211: Updating information on frequ=
ency 2462
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136189] cfg80211: 2402000 KHz - 2472000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136191] cfg80211: Updating information on frequ=
ency 2467
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136195] cfg80211: 2457000 KHz - 2482000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136197] cfg80211: Updating information on frequ=
ency 2472
>>> MHz for a 20 MHz width channel with regulatory rule:
>>> kernel: [ =C2=A0 24.136200] cfg80211: 2457000 KHz - 2482000 KHz @ =C2=
=A0KHz), (N/A
>>> mBi, 2000 mBm)
>>> kernel: [ =C2=A0 24.136203] cfg80211: Disabling freq 2484 MHz as cu=
stom regd
>>> has no rule that fits a 20 MHz wide channel
>>> kernel: [ =C2=A0 24.136404] cfg80211: Ignoring regulatory request S=
et by core
>>> since the driver uses its own custom regulatory domain
>>> kernel: [ =C2=A0 24.393924] ieee80211 phy0: Selected rate control a=
lgorithm
>>> 'minstrel_ht'
>>> kernel: [ =C2=A0 24.394588] ath5k phy0: Atheros AR2413 chip found (=
MAC: 0x78,
>>> PHY: 0x45)
>>> ...
>>> NetworkManager[725]:<info> =C2=A0(wlan0): driver supports SSID scan=
s
>>> (scan_capa 0x01).
>>> NetworkManager[725]:<info> =C2=A0(wlan0): new 802.11 WiFi device (d=
river:
>>> 'ath5k' ifindex: 3)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): exported as
>>> /org/freedesktop/NetworkManager/Devices/1
>>> NetworkManager[725]:<info> =C2=A0(wlan0): now managed
>>> NetworkManager[725]:<info> =C2=A0(wlan0): device state change: 1 ->=
 =C2=A02 (reason
>>> 2)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): bringing up device.
>>> NetworkManager[725]:<info> =C2=A0(wlan0): preparing device.
>>> NetworkManager[725]:<info> =C2=A0(wlan0): deactivating device (reas=
on: 2).
>>> NetworkManager[725]: supplicant_interface_acquire: assertion `mgr_s=
tate
>>> =3D=3D NM_SUPPLICANT_MANAGER_STATE_IDLE' failed
>>> kernel: [ =C2=A0 25.149294] ADDRCONF(NETDEV_UP): wlan0: link is not=
 ready
>>> ...
>>> NetworkManager[725]:<info> =C2=A0Trying to start the supplicant...
>>> ...
>>> NetworkManager[725]:<info> =C2=A0(wlan0): supplicant manager state:=
 =C2=A0down ->
>>> =C2=A0idle
>>> NetworkManager[725]:<info> =C2=A0(wlan0): device state change: 2 ->=
 =C2=A03 (reason
>>> 0)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): supplicant interface stat=
e:
>>> =C2=A0starting -> =C2=A0ready
>>> ...
>>> NetworkManager[725]:<info> =C2=A0(wlan0): device state change: 3 ->=
 =C2=A02 (reason
>>> 0)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): deactivating device (reas=
on: 0).
>>> NetworkManager[725]:<info> =C2=A0(wlan0): taking down device.
>>> NetworkManager[725]:<info> =C2=A0(wlan0): bringing up device.
>>> kernel: [ =C2=A0104.430292] ath5k phy0: (ath5k_init_hw:2522): mode =
2
>>> kernel: [ =C2=A0104.430297] ath5k phy0: (ath5k_stop_locked:2481): i=
nvalid 0
>>> kernel: [ =C2=A0104.431000] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0104.434475] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0104.434683] ath5k phy0: (ath5k_rfkill_disable:42): =
rfkill
>>> disable (gpio:0 polarity:0)
>>> kernel: [ =C2=A0104.435759] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02412 MHz)
>>> kernel: [ =C2=A0104.435762] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0104.436845] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0104.437191] ath5k phy0: (ath5k_conf_tx:602): Config=
ure tx
>>> [queue 0], =C2=A0aifs: 2, cw_min: 7, cw_max: 15, txop: 102
>>> kernel: [ =C2=A0104.437212] ath5k phy0: (ath5k_conf_tx:602): Config=
ure tx
>>> [queue 1], =C2=A0aifs: 2, cw_min: 15, cw_max: 31, txop: 188
>>> kernel: [ =C2=A0104.438337] ADDRCONF(NETDEV_UP): wlan0: link is not=
 ready
>>> NetworkManager[725]:<info> =C2=A0(wlan0): supplicant interface stat=
e:
>>> =C2=A0starting -> =C2=A0ready
>>> NetworkManager[725]:<info> =C2=A0(wlan0): device state change: 2 ->=
 =C2=A03 (reason
>>> 42)
>>> wpa_supplicant[745]: Failed to initiate AP scan.
>>> kernel: [ =C2=A0125.188087] net_ratelimit: 41 callbacks suppressed
>>> kernel: [ =C2=A0125.188100] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0125.188109] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0125.291007] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0125.344076] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0125.344090] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0125.447014] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0125.500078] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0125.500091] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0125.602999] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0125.656070] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> kernel: [ =C2=A0155.188052] net_ratelimit: 29 callbacks suppressed
>>> kernel: [ =C2=A0155.188058] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0155.188061] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0155.290844] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0155.344032] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0155.344038] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0155.446810] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0155.500031] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0155.500036] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0155.602811] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0155.656033] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> kernel: [ =C2=A0195.184088] net_ratelimit: 29 callbacks suppressed
>>> kernel: [ =C2=A0195.184102] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0195.184110] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0195.287022] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0195.340066] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0195.340079] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0195.442967] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0195.496076] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0195.496088] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0195.599009] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0195.652078] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> kernel: [ =C2=A0245.188077] net_ratelimit: 29 callbacks suppressed
>>> kernel: [ =C2=A0245.188091] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0245.188100] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0245.290997] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0245.344084] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0245.344092] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0245.446882] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0245.500053] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0245.500058] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0245.602808] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0245.656046] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> kernel: [ =C2=A0305.188050] net_ratelimit: 29 callbacks suppressed
>>> kernel: [ =C2=A0305.188063] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0305.188071] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0305.290945] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0305.344070] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0305.344082] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0305.446943] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0305.500047] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0305.500058] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0305.602967] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0305.656090] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): device state change: 3 ->=
 =C2=A02 (reason
>>> 0)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): deactivating device (reas=
on: 0).
>>> NetworkManager[725]:<info> =C2=A0(wlan0): taking down device.
>>> kernel: [ =C2=A0310.887530] net_ratelimit: 29 callbacks suppressed
>>> kernel: [ =C2=A0310.887535] ath5k phy0: (ath5k_stop_locked:2481): i=
nvalid 0
>>> kernel: [ =C2=A0310.990264] ath5k phy0: (ath5k_stop_hw:2619): putti=
ng device
>>> to sleep
>>> kernel: [ =C2=A0310.990554] ath5k phy0: (ath5k_rfkill_enable:51): r=
fkill
>>> enable (gpio:0 polarity:0)
>>> NetworkManager[725]:<info> =C2=A0(wlan0): bringing up device.
>>> kernel: [ =C2=A0315.755891] ath5k phy0: (ath5k_init_hw:2522): mode =
2
>>> kernel: [ =C2=A0315.755903] ath5k phy0: (ath5k_stop_locked:2481): i=
nvalid 0
>>> kernel: [ =C2=A0315.756624] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0315.760236] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0315.760474] ath5k phy0: (ath5k_rfkill_disable:42): =
rfkill
>>> disable (gpio:0 polarity:0)
>>> kernel: [ =C2=A0315.762566] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02412 MHz)
>>> kernel: [ =C2=A0315.762574] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0315.764972] ADDRCONF(NETDEV_UP): wlan0: link is not=
 ready
>>> NetworkManager[725]:<info> =C2=A0(wlan0): supplicant interface stat=
e:
>>> =C2=A0starting -> =C2=A0ready
>>> NetworkManager[725]:<info> =C2=A0(wlan0): device state change: 2 ->=
 =C2=A03 (reason
>>> 42)
>>> wpa_supplicant[745]: Failed to initiate AP scan.
>>> kernel: [ =C2=A0316.036068] net_ratelimit: 8 callbacks suppressed
>>> kernel: [ =C2=A0316.036080] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0316.036089] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0316.140039] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0316.196067] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0316.196079] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0316.298940] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0316.352063] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> kernel: [ =C2=A0316.352071] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0316.455003] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0316.508080] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2432 -> =C2=A02437 MHz)
>>> kernel: [ =C2=A0336.188067] net_ratelimit: 26 callbacks suppressed
>>> kernel: [ =C2=A0336.188080] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0336.188088] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0336.290966] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0336.344059] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0336.344068] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0336.446912] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0336.500068] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0336.500077] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0336.602937] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0336.656058] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>> kernel: [ =C2=A0366.188084] net_ratelimit: 29 callbacks suppressed
>>> kernel: [ =C2=A0366.188097] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2412 -> =C2=A02417 MHz)
>>> kernel: [ =C2=A0366.188105] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0366.290999] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0366.344099] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2417 -> =C2=A02422 MHz)
>>> kernel: [ =C2=A0366.344112] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0366.447030] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0366.500094] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2422 -> =C2=A02427 MHz)
>>> kernel: [ =C2=A0366.500106] ath5k phy0: (ath5k_reset:2648): resetti=
ng
>>> kernel: [ =C2=A0366.603008] ath5k phy0: (ath5k_rx_start:1099): cach=
elsz 32
>>> rx_bufsize 2368
>>> kernel: [ =C2=A0366.656103] ath5k phy0: (ath5k_chan_set:434): chann=
el set,
>>> resetting (2427 -> =C2=A02432 MHz)
>>>
>>>
>>
>> Hmm I don't see any errors from reset/phy code, can you disable
>> Network Manager/wpa-supplicant and test connection on an open networ=
k
>> using iw ? It 'll give us a better picture...
>>
>> If iw doesn't return any scan results we are probably hitting a PHY/=
RF
>> error specific to your device (not all vendors follow the reference
>> design). Maybe we should follow a blacklist/whitelist approach for
>> this feature.
>>
>
> yeah Im getting this over here with my macbook pro. all of a sudden i=
nternet
> craps out, unable to reconnect.. reboot is the only way to get back o=
nline.
> dmesg here:
> http://fpaste.org/mwGn/
>
> I can try bisecting, but might take a while due to this occuring ever=
y few
> days or so.
>
> Justin P. Mattock
>

[   26.219909] ath9k 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> =
IRQ 17

Different card, different driver...

--=20
GPG ID: 0xD21DB2DB
As you read this post global entropy rises. Have Fun ;-)
Nick
