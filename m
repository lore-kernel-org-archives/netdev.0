From: Alan Curry <rlwinm@sdf.org>
Subject: Re: PROBLEM: network data corruption (bisected to e5a4b0bb803b)
Date: Wed, 27 Jul 2016 01:14:25 +0000 (UTC)
Message-ID: <201607270114.u6R1EPxB018526@sdf.org>
References: <2589898.190WVraD7Z@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alan Curry <rlwinm@sdf.org>, Al Viro <viro@zeniv.linux.org.uk>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, alexmcwhirter@triadic.us
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ol.sdf.org ([192.94.73.20]:52740 "EHLO sdf.lonestar.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757869AbcG0BOm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 21:14:42 -0400
In-Reply-To: <2589898.190WVraD7Z@debian64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christian Lamparter wrote:
> Thanks, I gave the program a try with my WNDA3100 and a WN821N v2 devices.
> I did not see any corruptions in any of the tests though. Can you tell me
> something about your wireless network too? I would like to know what router
> and firmware are you using? Also important: what's your wireless configuration?

The router/access-point is a Comcast-issued Technicolor cable modem, model
TC8305C. The only thing I can find on it that looks like it might identify
a firmware version is this:

    System Software Version

    eMTA & DOCSIS Software Version: 01.E6.01.22.25
    Packet Cable: 2.0

I assume Comcast pushes firmware updates whenever they feel like it.

There is possibly another clue. I get this message from the kernel sometimes:

    ieee80211 phy0: invalid plcp cck rate (0).

I had this message appearing long before the data corruption bug started.
It never correlated with any actual problems, so I turned down the priority
level of the message to get it off the console, and forgot about it. I
was unable to discover what a "plcp" or "cck" is so the message means
nothing to me.

> (WPA?, CCMP or TKIP? HT40, HT20 or Legacy rates? ...)
> 
> Probably the quickest and easiest way to get that information is by running
> the following commands as root, when you are connected to your wifi network
> and post the results:
> # iw dev wlan0 link
> # iw dev wlan0 scan dump

Connected to cc:03:fa:bf:e9:ea (on wlan0)
	SSID: HOME-E9EA
	freq: 2462
	RX: 20726719 bytes (106483 packets)
	TX: 5902478 bytes (44707 packets)
	signal: -43 dBm
	tx bitrate: 54.0 MBit/s

	bss flags:	short-slot-time
	dtim period:	1
	beacon int:	100

BSS cc:03:fa:bf:e9:ea(on wlan0) -- associated
	TSF: 236407205748 usec (2d, 17:40:07)
	freq: 2462
	beacon interval: 100 TUs
	capability: ESS Privacy ShortSlotTime (0x0411)
	signal: -33.00 dBm
	last seen: 634452 ms ago
	Information elements from Probe Response frame:
	SSID: HOME-E9EA
	Supported rates: 1.0* 2.0* 5.5* 11.0* 18.0 24.0* 36.0 54.0 
	DS Parameter set: channel 11
	ERP: <no flags>
	ERP D4.0: <no flags>
	RSN:	 * Version: 1
		 * Group cipher: TKIP
		 * Pairwise ciphers: CCMP TKIP
		 * Authentication suites: PSK
		 * Capabilities: 16-PTKSA-RC 1-GTKSA-RC (0x000c)
	Extended supported rates: 6.0* 9.0 12.0* 48.0 
	HT capabilities:
		Capabilities: 0x18bd
			RX LDPC
			HT20
			SM Power Save disabled
			RX Greenfield
			RX HT20 SGI
			TX STBC
			No RX STBC
			Max AMSDU length: 7935 bytes
			DSSS/CCK HT40
		Maximum RX AMPDU length 65535 bytes (exponent: 0x003)
		Minimum RX AMPDU time spacing: 8 usec (0x06)
		HT RX MCS rate indexes supported: 0-23
		HT TX MCS rate indexes are undefined
	HT operation:
		 * primary channel: 11
		 * secondary channel offset: no secondary
		 * STA channel width: 20 MHz
		 * RIFS: 1
		 * HT protection: nonmember
		 * non-GF present: 1
		 * OBSS non-GF present: 1
		 * dual beacon: 0
		 * dual CTS protection: 0
		 * STBC beacon: 0
		 * L-SIG TXOP Prot: 0
		 * PCO active: 0
		 * PCO phase: 0
	WPS:	 * Version: 1.0
		 * Wi-Fi Protected Setup State: 2 (Configured)
		 * Response Type: 3 (AP)
		 * UUID: 6d1b1911-14a9-391c-cdee-89850a5aa1ef
		 * Manufacturer: Technicolor
		 * Model: Technicolor
		 * Model Number: 123456
		 * Serial Number: 0000001
		 * Primary Device Type: 6-0050f204-1
		 * Device name: TechnicolorAP
		 * Config methods: Display
		 * RF Bands: 0x1
		 * Unknown TLV (0x1049, 6 bytes): 00 37 2a 00 01 20
	WPA:	 * Version: 1
		 * Group cipher: TKIP
		 * Pairwise ciphers: CCMP TKIP
		 * Authentication suites: PSK
		 * Capabilities: 16-PTKSA-RC 1-GTKSA-RC (0x000c)
	WMM:	 * Parameter version 1
		 * u-APSD
		 * BE: CW 15-1023, AIFSN 3
		 * BK: CW 15-1023, AIFSN 7
		 * VI: CW 7-15, AIFSN 2, TXOP 3008 usec
		 * VO: CW 3-7, AIFSN 2, TXOP 1504 usec

-- 
Alan Curry
