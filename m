From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: brcm80211 breakage..
Date: Tue, 10 Jan 2012 12:15:29 -0800
Message-ID: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:63431 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754842Ab2AJUPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 15:15:51 -0500
Received: by wibhm6 with SMTP id hm6so3710795wib.19
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2012 12:15:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So the wireless on my Macbook Air no longer seems to work with the
current -git tree.

The BRCMSMAC driver *used* to work, and no longer does. Also, very
annoyingly, it's even hard to *compile* the thing, because it used to
be

  depends on BCMA=n

but now it is the exact reverse:

  depends on BCMA

so there is no sane way to carry a configuration over from before, and
things like bisection is a major pain due to having to play idiotic
configuration games to get it to work across all these modifications.

Ragardless, even once you actually enable BCMA and can get the driver
to come back, it just doesn't do anything. Maybe there is some
remaining config problem, but I don't think so. I think the driver is
just buggered.

The kernel messages don't say much. A working config for me has
messages like this:

  brcmsmac 0000:02:00.0: bus 2 slot 0 func 0 irq 11
  brcmsmac 0000:02:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
  brcmsmac 0000:02:00.0: setting latency timer to 64
  ieee80211 phy0: brcms_ops_config: change monitor mode: false (implement)
  ieee80211 phy0: brcms_ops_config: change power-save mode: false (implement)
  ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: false (implement)
  ieee80211 phy0: brcms_ops_bss_info_changed: qos enabled: true (implement)
  ieee80211 phy0: brcmsmac: brcms_ops_bss_info_changed: associated
  ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled
true, count 0 (implement)
  ieee80211 phy0: brcms_ops_bss_info_changed: arp filtering: enabled
true, count 1 (implement)

while the nonworking one says:

  brcmsmac bcma0:0: mfg 4bf core 812 rev 23 class 0 irq 17
  ieee80211 phy0: wl0: brcms_b_attach: si_attach failed
  ieee80211 phy0: wl0: brcms_b_attach: failed with err 11
  ieee80211 phy0: wl0: brcms_c_attach: failed with err 11
  ieee80211 phy0: brcmsmac: attach() failed with code 11
  brcmsmac: brcms_bcma_probe: brcms_attach failed!
  brcms_module_init: register returned 0

and no wireless device ever shows up.

lspci for this device says:

  02:00.0 Network controller: Broadcom Corporation BCM43224
802.11a/b/g/n (rev 01)
          Subsystem: Apple Computer Inc. Device 00e9
          Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
          Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast
>TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
          Latency: 0, Cache Line Size: 256 bytes
          Interrupt: pin A routed to IRQ 17
          Region 0: Memory at a0400000 (64-bit, non-prefetchable) [size=16K]
          Capabilities: <access denied>
          Kernel driver in use: brcmsmac
  00: e4 14 53 43 06 00 10 00 01 00 80 02 40 00 00 00
  10: 04 00 40 a0 00 00 00 00 00 00 00 00 00 00 00 00
  20: 00 00 00 00 00 00 00 00 00 00 00 00 6b 10 e9 00
  30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00

(this is from the working kernel, obviously).

Please look into this. I'll obviously be happy test any reasonable suggestions,

                 Linus
