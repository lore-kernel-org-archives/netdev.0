From: Seth Forshee <seth.forshee@canonical.com>
Subject: Re: ath5k regression associating with APs in 2.6.38
Date: Thu, 5 May 2011 09:54:30 -0500
Message-ID: <20110505145430.GB13727@thinkpad-t410>
References: <20110504153819.GA4551@thinkpad-t410>
 <20110504172716.GC18541@tuxdriver.com>
 <20110504192639.GB4551@thinkpad-t410>
 <BANLkTimEmBRyxbZgffJMrH4TTc4f6peuTg@mail.gmail.com>
 <20110505135207.GA13727@thinkpad-t410>
 <BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Slaby <jirislaby@gmail.com>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Bob Copeland <me@bobcopeland.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@venema.h4ckr.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nick Kossifidis <mickflemm@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <BANLkTinkiTQU2k7vBEc0JPGa01AUVCvp2Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 05, 2011 at 05:30:42PM +0300, Nick Kossifidis wrote:
> Hmm I don't see any errors from reset/phy code, can you disable
> Network Manager/wpa-supplicant and test connection on an open network
> using iw ? It 'll give us a better picture...
> 
> If iw doesn't return any scan results we are probably hitting a PHY/RF
> error specific to your device (not all vendors follow the reference
> design). Maybe we should follow a blacklist/whitelist approach for
> this feature.

Will do. I just got another log from my tester, which is more typical of
what he's been getting. I've pasted a portion of it below. The full log
can be viewed at

https://launchpadlibrarian.net/71137619/20110504_020639rc6%23201105050227_boot4_syslog

Thanks,
Seth


May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): new 802.11 WiFi device (driver: 'ath5k' ifindex: 3)
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): exported as /org/freedesktop/NetworkManager/Devices/1
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): now managed
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 1 -> 2 (reason 2)
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): bringing up device.
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): preparing device.
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): deactivating device (reason: 2).
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: supplicant_interface_acquire: assertion `mgr_state == NM_SUPPLICANT_MANAGER_STATE_IDLE' failed
May  5 08:57:16 AcerAspire5100 kernel: [   25.844302] ADDRCONF(NETDEV_UP): wlan0: link is not ready
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> modem-manager is now available
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <warn> bluez error getting default adapter: The name org.bluez was not provided by any .service files
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> Trying to start the supplicant...
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant manager state:  down -> idle
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 2 -> 3 (reason 0)
May  5 08:57:16 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant interface state:  starting -> ready
...
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) starting connection 'Auto aureola'
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 3 -> 4 (reason 0)
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 1 of 5 (Device Prepare) scheduled...
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 1 of 5 (Device Prepare) started...
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 2 of 5 (Device Configure) scheduled...
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 1 of 5 (Device Prepare) complete.
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 2 of 5 (Device Configure) starting...
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 4 -> 5 (reason 0)
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0/wireless): access point 'Auto aureola' has security, but secrets are required.
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 5 -> 6 (reason 0)
May  5 08:57:38 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 2 of 5 (Device Configure) complete.
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 1 of 5 (Device Prepare) scheduled...
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 1 of 5 (Device Prepare) started...
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 6 -> 4 (reason 0)
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 2 of 5 (Device Configure) scheduled...
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 1 of 5 (Device Prepare) complete.
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 2 of 5 (Device Configure) starting...
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> (wlan0): device state change: 4 -> 5 (reason 0)
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0/wireless): connection 'Auto aureola' has security, and secrets exist.  No new secrets needed.
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Config: added 'ssid' value 'aureola'
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Config: added 'scan_ssid' value '1'
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Config: added 'key_mgmt' value 'WPA-PSK'
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Config: added 'psk' value '<omitted>'
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: nm_setting_802_1x_get_pkcs11_engine_path: assertion `NM_IS_SETTING_802_1X (setting)' failed
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: nm_setting_802_1x_get_pkcs11_module_path: assertion `NM_IS_SETTING_802_1X (setting)' failed
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Activation (wlan0) Stage 2 of 5 (Device Configure) complete.
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> Config: set interface ap_scan to 1
May  5 08:57:39 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant connection state:  inactive -> scanning
May  5 08:57:41 AcerAspire5100 wpa_supplicant[734]: Trying to associate with c0:3f:0e:b9:f3:b2 (SSID='aureola' freq=2452 MHz)
May  5 08:57:41 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant connection state:  scanning -> associating
May  5 08:57:41 AcerAspire5100 kernel: [   51.261113] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
May  5 08:57:41 AcerAspire5100 kernel: [   51.460049] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
May  5 08:57:41 AcerAspire5100 kernel: [   51.660091] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
May  5 08:57:42 AcerAspire5100 kernel: [   51.860048] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
May  5 08:57:51 AcerAspire5100 wpa_supplicant[734]: Authentication with c0:3f:0e:b9:f3:b2 timed out.
May  5 08:57:51 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant connection state:  associating -> disconnected
May  5 08:57:51 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant connection state:  disconnected -> scanning
May  5 08:57:51 AcerAspire5100 kernel: [   61.396045] ath5k phy0: (ath5k_chan_set:434): channel set, resetting (2452 -> 2412 MHz)
May  5 08:57:51 AcerAspire5100 kernel: [   61.396051] ath5k phy0: (ath5k_reset:2648): resetting
May  5 08:57:51 AcerAspire5100 kernel: [   61.397135] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 rx_bufsize 2368
May  5 08:57:51 AcerAspire5100 kernel: [   61.452053] ath5k phy0: (ath5k_chan_set:434): channel set, resetting (2412 -> 2417 MHz)
May  5 08:57:51 AcerAspire5100 kernel: [   61.452059] ath5k phy0: (ath5k_reset:2648): resetting
May  5 08:57:51 AcerAspire5100 kernel: [   61.453143] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 rx_bufsize 2368
May  5 08:57:51 AcerAspire5100 kernel: [   61.508053] ath5k phy0: (ath5k_chan_set:434): channel set, resetting (2417 -> 2422 MHz)
May  5 08:57:51 AcerAspire5100 kernel: [   61.508059] ath5k phy0: (ath5k_reset:2648): resetting
May  5 08:57:51 AcerAspire5100 kernel: [   61.509143] ath5k phy0: (ath5k_rx_start:1099): cachelsz 32 rx_bufsize 2368
May  5 08:57:51 AcerAspire5100 kernel: [   61.564045] ath5k phy0: (ath5k_chan_set:434): channel set, resetting (2422 -> 2427 MHz)
May  5 08:57:52 AcerAspire5100 wpa_supplicant[734]: Trying to associate with c0:3f:0e:b9:f3:b2 (SSID='aureola' freq=2452 MHz)
May  5 08:57:52 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant connection state:  scanning -> associating
May  5 08:57:52 AcerAspire5100 kernel: [   62.364741] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 1/3)
May  5 08:57:52 AcerAspire5100 kernel: [   62.564061] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 2/3)
May  5 08:57:53 AcerAspire5100 kernel: [   62.764058] wlan0: direct probe to c0:3f:0e:b9:f3:b2 (try 3/3)
May  5 08:57:53 AcerAspire5100 kernel: [   62.964061] wlan0: direct probe to c0:3f:0e:b9:f3:b2 timed out
May  5 08:58:02 AcerAspire5100 wpa_supplicant[734]: Authentication with c0:3f:0e:b9:f3:b2 timed out.
May  5 08:58:02 AcerAspire5100 NetworkManager[703]: <info> (wlan0): supplicant connection state:  associating -> disconnected
