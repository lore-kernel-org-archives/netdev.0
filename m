From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Thu, 5 May 2011 08:52:07 -0500
Message-ID: <20110505135207.GA13727@thinkpad-t410>
References: <20110504153819.GA4551@thinkpad-t410>
 <20110504172716.GC18541@tuxdriver.com>
 <20110504192639.GB4551@thinkpad-t410>
 <BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Slaby <jirislaby@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nick Kossifidis <mickflemm@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2011 at 11:09:03PM +0300, Nick Kossifidis wrote:
> 2011/5/4 Seth Forshee <seth.forshee@canonical.com>:
> > On Wed, May 04, 2011 at 01:27:17PM -0400, John W. Linville wrote:
> >> On Wed, May 04, 2011 at 10:38:19AM -0500, Seth Forshee wrote:
> >> > I've been investigating some reports of a regression in associat=
ing with
> >> > APs with AR2413 in 2.6.38. Association repeatedly fails with som=
e
> >> > "direct probe to x timed out" messages (see syslog excerpt below=
),
> >> > although it will generally associate eventually, after many trie=
s.
> >> >
> >> > Bisection identifies 8aec7af (ath5k: Support synth-only channel =
change
> >> > for AR2413/AR5413) as offending commit. Prior to this commit the=
re are
> >> > no direct probe messages at all in the logs. I've also found tha=
t
> >> > forcing fast to false at the top of ath5k_hw_reset() fixes the i=
ssue.
> >> > I'm not sure what the connection is between this commit and the
> >> > timeouts. Any suggestions?
> >>
> >> Have you tried reverting that commit on top of 2.6.38? =C2=A0Can y=
ou
> >> recreate the issue with 2.6.39-rc6 (or later)?
> >
> > I started to revert that commit, but it wasn't straight-forward due=
 to
> > later changes. Forcing fast to false in ath5k_hw_reset() acts as a
> > functional revert of sorts since that should force it back to a ful=
l
> > reset for all channel changes, and it's much simpler than working o=
ut
> > the right way to revert the commit. I think the results suggest str=
ongly
> > that a revert is likely to fix the problem. I can finish the work t=
o
> > revert if you'd still like to see the results.
> >
> > Testing a previous .39-rc kernel still exhibited the failure. I don=
't
> > recall which one it was and apparently forgot to make note of it. I=
'll
> > request testing against rc6.
> >
> > Thanks,
> > Seth
> >
>=20
> Do you get scan results ?
> Can you enable ATH5K_DEBUG_RESET and see what you get ?

2.6.39-rc6 still fails. A more comprehensive log with ATH5K_DEBUG_RESET
enabled is below.

Scanning looks to be failing according to this log. I was thinking that
I saw successfull scans in some of the previous logs, but I'll have to
go back and check to be sure.

Thanks,
Seth


kernel: [   23.421242] ath5k 0000:06:02.0: PCI INT A -> GSI 22 (level, =
low) -> IRQ 22
kernel: [   23.421312] ath5k 0000:06:02.0: registered as 'phy0'
kernel: [   24.132959] ath: EEPROM regdomain: 0x63
kernel: [   24.132962] ath: EEPROM indicates we should expect a direct =
regpair map
kernel: [   24.132967] ath: Country alpha2 being used: 00
kernel: [   24.132969] ath: Regpair used: 0x63
kernel: [   24.136125] cfg80211: Updating information on frequency 2412=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136131] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136134] cfg80211: Updating information on frequency 2417=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136137] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136140] cfg80211: Updating information on frequency 2422=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136143] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136146] cfg80211: Updating information on frequency 2427=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136149] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136151] cfg80211: Updating information on frequency 2432=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136155] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136157] cfg80211: Updating information on frequency 2437=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136160] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136163] cfg80211: Updating information on frequency 2442=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136166] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136168] cfg80211: Updating information on frequency 2447=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136172] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136174] cfg80211: Updating information on frequency 2452=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136177] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136180] cfg80211: Updating information on frequency 2457=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136183] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136186] cfg80211: Updating information on frequency 2462=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136189] cfg80211: 2402000 KHz - 2472000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136191] cfg80211: Updating information on frequency 2467=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136195] cfg80211: 2457000 KHz - 2482000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136197] cfg80211: Updating information on frequency 2472=
 MHz for a 20 MHz width channel with regulatory rule:
kernel: [   24.136200] cfg80211: 2457000 KHz - 2482000 KHz @  KHz), (N/=
A mBi, 2000 mBm)
kernel: [   24.136203] cfg80211: Disabling freq 2484 MHz as custom regd=
 has no rule that fits a 20 MHz wide channel
kernel: [   24.136404] cfg80211: Ignoring regulatory request Set by cor=
e since the driver uses its own custom regulatory domain=20
kernel: [   24.393924] ieee80211 phy0: Selected rate control algorithm =
'minstrel_ht'
kernel: [   24.394588] ath5k phy0: Atheros AR2413 chip found (MAC: 0x78=
, PHY: 0x45)
=2E..
NetworkManager[725]: <info> (wlan0): driver supports SSID scans (scan_c=
apa 0x01).
NetworkManager[725]: <info> (wlan0): new 802.11 WiFi device (driver: 'a=
th5k' ifindex: 3)
NetworkManager[725]: <info> (wlan0): exported as /org/freedesktop/Netwo=
rkManager/Devices/1
NetworkManager[725]: <info> (wlan0): now managed
NetworkManager[725]: <info> (wlan0): device state change: 1 -> 2 (reaso=
n 2)
NetworkManager[725]: <info> (wlan0): bringing up device.
NetworkManager[725]: <info> (wlan0): preparing device.
NetworkManager[725]: <info> (wlan0): deactivating device (reason: 2).
NetworkManager[725]: supplicant_interface_acquire: assertion `mgr_state=
 =3D=3D NM_SUPPLICANT_MANAGER_STATE_IDLE' failed
kernel: [   25.149294] ADDRCONF(NETDEV_UP): wlan0: link is not ready
=2E..
NetworkManager[725]: <info> Trying to start the supplicant...
=2E..
NetworkManager[725]: <info> (wlan0): supplicant manager state:  down ->=
 idle
NetworkManager[725]: <info> (wlan0): device state change: 2 -> 3 (reaso=
n 0)
NetworkManager[725]: <info> (wlan0): supplicant interface state:  start=
ing -> ready
=2E..
NetworkManager[725]: <info> (wlan0): device state change: 3 -> 2 (reaso=
n 0)
NetworkManager[725]: <info> (wlan0): deactivating device (reason: 0).
NetworkManager[725]: <info> (wlan0): taking down device.
NetworkManager[725]: <info> (wlan0): bringing up device.
kernel: [  104.430292] ath5k phy0: (ath5k_init_hw:2522): mode 2
kernel: [  104.430297] ath5k phy0: (ath5k_stop_locked:2481): invalid 0
kernel: [  104.431000] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  104.434475] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  104.434683] ath5k phy0: (ath5k_rfkill_disable:42): rfkill di=
sable (gpio:0 polarity:0)
kernel: [  104.435759] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2412 MHz)
kernel: [  104.435762] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  104.436845] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  104.437191] ath5k phy0: (ath5k_conf_tx:602): Configure tx [q=
ueue 0],  aifs: 2, cw_min: 7, cw_max: 15, txop: 102
kernel: [  104.437212] ath5k phy0: (ath5k_conf_tx:602): Configure tx [q=
ueue 1],  aifs: 2, cw_min: 15, cw_max: 31, txop: 188
kernel: [  104.438337] ADDRCONF(NETDEV_UP): wlan0: link is not ready
NetworkManager[725]: <info> (wlan0): supplicant interface state:  start=
ing -> ready
NetworkManager[725]: <info> (wlan0): device state change: 2 -> 3 (reaso=
n 42)
wpa_supplicant[745]: Failed to initiate AP scan.
kernel: [  125.188087] net_ratelimit: 41 callbacks suppressed
kernel: [  125.188100] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  125.188109] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  125.291007] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  125.344076] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  125.344090] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  125.447014] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  125.500078] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  125.500091] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  125.602999] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  125.656070] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
kernel: [  155.188052] net_ratelimit: 29 callbacks suppressed
kernel: [  155.188058] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  155.188061] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  155.290844] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  155.344032] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  155.344038] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  155.446810] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  155.500031] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  155.500036] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  155.602811] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  155.656033] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
kernel: [  195.184088] net_ratelimit: 29 callbacks suppressed
kernel: [  195.184102] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  195.184110] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  195.287022] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  195.340066] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  195.340079] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  195.442967] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  195.496076] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  195.496088] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  195.599009] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  195.652078] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
kernel: [  245.188077] net_ratelimit: 29 callbacks suppressed
kernel: [  245.188091] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  245.188100] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  245.290997] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  245.344084] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  245.344092] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  245.446882] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  245.500053] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  245.500058] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  245.602808] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  245.656046] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
kernel: [  305.188050] net_ratelimit: 29 callbacks suppressed
kernel: [  305.188063] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  305.188071] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  305.290945] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  305.344070] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  305.344082] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  305.446943] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  305.500047] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  305.500058] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  305.602967] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  305.656090] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
NetworkManager[725]: <info> (wlan0): device state change: 3 -> 2 (reaso=
n 0)
NetworkManager[725]: <info> (wlan0): deactivating device (reason: 0).
NetworkManager[725]: <info> (wlan0): taking down device.
kernel: [  310.887530] net_ratelimit: 29 callbacks suppressed
kernel: [  310.887535] ath5k phy0: (ath5k_stop_locked:2481): invalid 0
kernel: [  310.990264] ath5k phy0: (ath5k_stop_hw:2619): putting device=
 to sleep
kernel: [  310.990554] ath5k phy0: (ath5k_rfkill_enable:51): rfkill ena=
ble (gpio:0 polarity:0)
NetworkManager[725]: <info> (wlan0): bringing up device.
kernel: [  315.755891] ath5k phy0: (ath5k_init_hw:2522): mode 2
kernel: [  315.755903] ath5k phy0: (ath5k_stop_locked:2481): invalid 0
kernel: [  315.756624] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  315.760236] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  315.760474] ath5k phy0: (ath5k_rfkill_disable:42): rfkill di=
sable (gpio:0 polarity:0)
kernel: [  315.762566] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2412 MHz)
kernel: [  315.762574] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  315.764972] ADDRCONF(NETDEV_UP): wlan0: link is not ready
NetworkManager[725]: <info> (wlan0): supplicant interface state:  start=
ing -> ready
NetworkManager[725]: <info> (wlan0): device state change: 2 -> 3 (reaso=
n 42)
wpa_supplicant[745]: Failed to initiate AP scan.
kernel: [  316.036068] net_ratelimit: 8 callbacks suppressed
kernel: [  316.036080] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  316.036089] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  316.140039] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  316.196067] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  316.196079] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  316.298940] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  316.352063] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
kernel: [  316.352071] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  316.455003] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  316.508080] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2432 -> 2437 MHz)
kernel: [  336.188067] net_ratelimit: 26 callbacks suppressed
kernel: [  336.188080] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  336.188088] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  336.290966] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  336.344059] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  336.344068] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  336.446912] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  336.500068] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  336.500077] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  336.602937] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  336.656058] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
kernel: [  366.188084] net_ratelimit: 29 callbacks suppressed
kernel: [  366.188097] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2412 -> 2417 MHz)
kernel: [  366.188105] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  366.290999] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  366.344099] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2417 -> 2422 MHz)
kernel: [  366.344112] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  366.447030] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  366.500094] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2422 -> 2427 MHz)
kernel: [  366.500106] ath5k phy0: (ath5k_reset:2648): resetting
kernel: [  366.603008] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 r=
x_bufsize 2368
kernel: [  366.656103] ath5k phy0: (ath5k_chan_set:434): channel set, r=
esetting (2427 -> 2432 MHz)
