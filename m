From: Paul Hampson <Paul.Hampson@Pobox.com>
Subject: Re: bcm43xx-d80211 broadcast reception with WPA
Date: Sat, 11 Nov 2006 06:32:10 +0000 (UTC)
Message-ID: <loom.20061111T070237-788@post.gmane.org>
References: <ej09qf$2nv$1@sea.gmane.org> <200611102112.33050.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:9122 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1947109AbWKKGcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Nov 2006 01:32:25 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GimPc-0000ji-44
	for netdev@vger.kernel.org; Sat, 11 Nov 2006 07:32:20 +0100
Received: from 202.55.154.140 ([202.55.154.140])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 11 Nov 2006 07:32:20 +0100
Received: from Paul.Hampson by 202.55.154.140 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 11 Nov 2006 07:32:20 +0100
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch <mb <at> bu3sch.de> writes:

> On Thursday 09 November 2006 23:23, Paul Hampson wrote:
> > I've been backporting the bcm43xx-d80211 driver to whatever the released
> > 2.6 kernel was using the rt2x00 project's d80211 stack (equivalent to
> > current wireless-dev but with a workaround for not having a ieee80211_dev
> > pointer and still using the _tfm interface instead of the _cypher interface.)

> > As of last night's wireless-dev tree bcm43xx, everything seems to be
> > operating fine except incoming broadcast traffic is coming in 14 bytes too
> > long and scrambled. I presume this means it's not decrypting properly...

> It sounds like a bug in the hardware decryption setup.
> Are you using TKIP or not?

Yes, it's using TKIP. The router docs and the loading of the tkip module
when I use the softmac driver agree on this.

> Incoming mcast frames are handled in a special way in hardware.
> The keyidx field of the packet is used to lookup the key, as
> far as I know. (Otherwise the MAC address is used).
> Can I see a full dmesg log and a capture log on the broken machine, please?

Sending first some ipv6 broadcast pings and then some ipv4 broadcast pings:
(Commands "ping -b 192.168.192.255 -c 1" and "ping6 -I intel0 -c 1 ip6-allnodes")

17:04:08.794400 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0x26 >
33:33:00:00:00:01 (oui Unknown) Unknown DSAP 0x9c Unnumbered, eb, Flags [Poll],
length 116
        0x0000:  9d26 fbda 7284 bd60 6cdf 58c4 d064 71c6
        0x0010:  2a09 adab 4a19 a691 5640 9216 eae8 df70
        0x0020:  b94e 9ee9 fd75 6c25 ab16 36fb cdac c231
        0x0030:  0f17 f965 4d20 4a11 ab50 c77f 66ca 54e4
        0x0040:  e469 e458 5d6c c13d cc78 48fd da5c 7f71
        0x0050:  2f06 0728 c8da 689b b790 ec22 4d62 5a92
        0x0060:  221b b3cb 65e5 dc8a 8e57 3486 2a1e a2c2
        0x0070:  faf6 ae71
17:04:10.104111 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0xa8 >
33:33:00:00:00:01 (oui Unknown) Unknown DSAP 0xb8 Supervisory, Reject, rcv seq
78, Flags [Final], length 116
        0x0000:  b8a9 099d 0afb f9f3 8ef6 1c31 81c0 f1eb
        0x0010:  3869 1952 9762 f4f0 c743 7613 fd9c 99cd
        0x0020:  1644 a454 df14 5481 a35a 8c96 59b3 9391
        0x0030:  8579 a165 3da2 58ad a6a8 d499 e40c 4c4c
        0x0040:  3b33 a4ce 2b2e 439b 77f6 da5d 1d18 1685
        0x0050:  1e64 39cb 3565 5596 30eb fa1c 1cbd cec8
        0x0060:  395b a38c f7a4 a754 7c19 d694 a94b a4f9
        0x0070:  5785 64aa
17:04:10.938418 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0x1c >
33:33:00:00:00:01 (oui Unknown) Unknown DSAP 0x64 Unnumbered, 23, Flags [Poll],
length 116
        0x0000:  641c 338d 7f62 2bcd 4fff c7dd 4a6e efa1
        0x0010:  07ed f39b 5b88 c68e 27dd f35b 70cf df3c
        0x0020:  0cb8 f3ba 0b97 9069 43f9 e74f 1cb2 e4d7
        0x0030:  bf97 fbd8 94d8 efc5 284d 5393 604b 13ef
        0x0040:  1cd7 46e1 7b35 008b 8247 89bb 0a6a 4dac
        0x0050:  45e3 49af 853d 13fa e263 dea8 26ca 7076
        0x0060:  bec6 938f bd75 19bd a3ea 9f79 ea65 2c2d
        0x0070:  a45c b3d1
17:04:14.491735 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0x8a > Broadcast
Unknown DSAP 0xe4 Information, send seq 49, rcv seq 14, Flags [Final], length 96
        0x0000:  e58b 621d 383b 5114 c37d 54de da9e dd8b
        0x0010:  7d28 87d2 7d53 cd57 f0b4 c079 54a5 0bbe
        0x0020:  3eb2 f0b9 e1e6 e82b e52b ffaf f833 217c
        0x0030:  dbe7 c9f1 db0f 592e b432 5f7d 8041 f73f
        0x0040:  7267 662b d64e 170d c619 a447 b2c0 bd17
        0x0050:  b97b b032 dd1b d8f5 c007 eae9 0aee ea9f
17:04:16.489911 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0xa4 > Broadcast
ProWay NM Information, send seq 122, rcv seq 28, Flags [Final], length 96
        0x0000:  0fa5 f439 af38 57a6 564c 0c25 e2c0 7a09
        0x0010:  61fb a1f1 adb0 3718 cb39 3a03 6ecf ad42
        0x0020:  6e9c 75d7 cd06 0566 30c9 0238 4cf8 61a9
        0x0030:  0928 9414 f48b 2a07 3eca 05de a8a9 9787
        0x0040:  1ed5 2643 f82a b9a8 8e5a 5410 6858 b5c0
        0x0050:  ecb2 72a3 2dfb 66ac 0ce8 c4f8 ea87 ab14
17:04:18.449142 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0xb4 > Broadcast
Unknown DSAP 0x6a Supervisory, Receiver not Ready, rcv seq 23, Flags [Command],
length 96
        0x0000:  6bb4 252e 2888 d3b1 68bc 6129 9087 4170
        0x0010:  f4e2 4a47 adc9 9bce 7bf2 51b3 ac20 bd10
        0x0020:  7d67 3e00 6b6f 41ff 3e0c 2940 d31c 6143
        0x0030:  f7e4 caa6 879f 4663 e04b 0f6d 37eb 1db5
        0x0040:  fffd 0dfa 9b78 80e1 a30a 799e 9b1a 9d4a
        0x0050:  61c8 f041 e564 d566 b697 aaf6 8336 a6f3

And the dmesg output:

bcm43xx_d80211: no version for "ssb_init" found: kernel tainted.
PCI: Enabling device 0001:10:12.0 (0004 -> 0006)
ssb: Core 0 found: cc 0800, rev 04, vendor 4243
ssb: Core 1 found: cc 0812, rev 05, vendor 4243
ssb: Core 2 found: cc 080D, rev 02, vendor 4243
ssb: Core 3 found: cc 0807, rev 02, vendor 4243
ssb: Core 4 found: cc 0804, rev 09, vendor 4243
bcm43xx_d80211: Broadcom 4306 WLAN found
ssb: Switching to core 4
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: Detected PHY: Version: 2, Type 2, Revision 2
bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
bcm43xx_d80211: Radio turned off
bcm43xx_d80211: Radio turned off
wmaster0: Selected rate control algorithm 'simple'
bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 6, MAC:
00:0d:93:ef:57:2d)
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: firmware revision 15F, patchlevel 7E, date 2006-07-29 05:54:02
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Radio turned on
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: 30-bit DMA initialized
bcm43xx_d80211: Keys cleared
bcm43xx_d80211: Selected 802.11 core (phytype 2)
wlan0.11: Does not support passive scan, disabled
wlan0: starting scan
wlan0: scan completed
wlan0: Initial auth_alg=0
wlan0: authenticate with AP 00:14:6c:ed:c1:76
wlan0: RX authentication from 00:14:6c:ed:c1:76 (alg=0 transaction=2 status=0)
wlan0: authenticated
wlan0: associate with AP 00:14:6c:ed:c1:76
wlan0: RX AssocResp from 00:14:6c:ed:c1:76 (capab=0x471 status=0 aid=1)
wlan0: associated
bcm43xx_d80211: Using software based encryption for keyidx: 0, mac:
00:14:6c:ed:c1:76
bcm43xx_d80211: Using software based encryption for keyidx: 1, mac:
ff:ff:ff:ff:ff:ff
agpgart: Putting AGP V2 device at 0000:00:0b.0 into 4x mode
agpgart: Putting AGP V2 device at 0000:00:10.0 into 4x mode
[drm] Loading R300 Microcode
wlan0: no IPv6 routers present
device wlan0 entered promiscuous mode
audit(1163225045.337:6): dev=wlan0 prom=256 old_prom=0 auid=4294967295
wlan0: TKIP decrypt failed for RX frame from 00:14:6c:ed:c1:76 (res=-3)
wlan0: TKIP decrypt failed for RX frame from 00:14:6c:ed:c1:76 (res=-3)
device wlan0 left promiscuous mode
audit(1163225061.805:7): dev=wlan0 prom=0 old_prom=256 auid=4294967295

I can't reliably reproduce those "TKIP decrypt failed", I suspect that might be
annoyingly co-incidental failures from SSH, NMB, DHCP or IPv6 RA traffic.

Unloading the driver dmesg:
bcm43xx_d80211: Radio turned off
ssb: Switching to core 0
bcm43xx_d80211: DMA-32 0x0200 (RX) max used slots: 2/64
ssb: Switching to core 1
bcm43xx_d80211: DMA-32 0x02A0 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0280 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0260 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0240 (TX) max used slots: 0/128
bcm43xx_d80211: DMA-32 0x0220 (TX) max used slots: 20/128
bcm43xx_d80211: DMA-32 0x0200 (TX) max used slots: 0/128
bcm43xx_d80211: Virtual interface removed (type: 0x00000002, ID: 6, MAC:
00:0d:93:ef:57:2d)
wlan0: deauthenticate(reason=3)
wlan0: set_encrypt - low-level disable failed
wlan0: set_encrypt - low-level disable failed
wlan0: Initial auth_alg=0
wlan0: authenticate with AP 00:00:00:00:00:00

And loading up with v3 firmware:
ssb: Core 0 found: cc 0800, rev 04, vendor 4243
ssb: Core 1 found: cc 0812, rev 05, vendor 4243
ssb: Core 2 found: cc 080D, rev 02, vendor 4243
ssb: Core 3 found: cc 0807, rev 02, vendor 4243
ssb: Core 4 found: cc 0804, rev 09, vendor 4243
bcm43xx_d80211: Broadcom 4306 WLAN found
ssb: Switching to core 4
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: Detected PHY: Version: 2, Type 2, Revision 2
bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
bcm43xx_d80211: Radio turned off
bcm43xx_d80211: Radio turned off
wmaster0: Selected rate control algorithm 'simple'
bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 8, MAC:
00:0d:93:ef:57:2d)
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: PHY connected
bcm43xx_d80211: firmware revision 122, patchlevel 9A, date 2005-08-15 18:44:03
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Radio turned on
ssb: Switching to core 0
ssb: Switching to core 1
bcm43xx_d80211: Chip initialized
bcm43xx_d80211: 30-bit DMA initialized
bcm43xx_d80211: Keys cleared
bcm43xx_d80211: Selected 802.11 core (phytype 2)
wlan0.11: Does not support passive scan, disabled
wlan0: starting scan
wlan0: scan completed
wlan0: Initial auth_alg=0
wlan0: authenticate with AP 00:14:6c:ed:c1:76
wlan0: RX authentication from 00:14:6c:ed:c1:76 (alg=0 transaction=2 status=0)
wlan0: authenticated
wlan0: associate with AP 00:14:6c:ed:c1:76
wlan0: RX AssocResp from 00:14:6c:ed:c1:76 (capab=0x471 status=0 aid=1)
wlan0: associated
bcm43xx_d80211: Using software based encryption for keyidx: 0, mac:
00:14:6c:ed:c1:76
bcm43xx_d80211: Using software based encryption for keyidx: 2, mac:
ff:ff:ff:ff:ff:ff

One each of the ip4 and ip6 pings under v3 firmware
17:18:29.454625 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0xdc > Broadcast
Unknown DSAP 0xa6 Unnumbered, 07, Flags [Poll], length 96
        0x0000:  a6dc 1759 5095 ed4f 92f6 17dc d10c 9538
        0x0010:  e3e5 e302 e8f0 bfd8 0970 3dc7 315a c5eb
        0x0020:  ab6c 0c17 76a8 69ff c316 4955 1762 7ca0
        0x0030:  ba7f e65f e490 57e4 ad6c 53d5 fd4e d6de
        0x0040:  41b2 5ab9 4749 52e4 1a9d bad9 e2a7 8544
        0x0050:  91a6 eeef 5cc4 958c bc83 d7af 31f6 09a3
17:18:44.738765 00:02:a5:40:8d:61 (oui Unknown) Unknown SSAP 0xd2 >
33:33:00:00:00:01 (oui Unknown) Unknown DSAP 0x0a Information, send seq 103, rcv
seq 95, Flags [Command], length 116
        0x0000:  0ad2 cebe 311a edd5 4e6c 3c2f 2e53 5120
        0x0010:  d4da 94b6 a481 0d02 d802 cc6d 9f85 5106
        0x0020:  8c41 d771 4e8f 79cf bf2f 39c9 1dbd ad05
        0x0030:  544d 060d 154c 61d2 87d9 e6a2 b17c c353
        0x0040:  506c 2b3b e9d5 227f c849 aace 6b8f 3dbc
        0x0050:  55fa d232 65dd 51eb 4da5 84fe 95dc bb14
        0x0060:  7ba1 4e21 3215 816d c3e9 c7bf 05d9 812b
        0x0070:  ea8a f5af

The only other thing that jumped out as relevant is that
/sys/class/ieee80211/phy0/device/net:wlan0/keys/default/key (also 2/key)
had a different value from
/sys/class/ieee80211/phy0/sta/00:14:6c:ed:c1:76/key
and the former matched iwconfig's key listing, which had a [3] following it.

-- 
Paul "TBBle" Hampson
Paul.Hampson@Pobox.com

