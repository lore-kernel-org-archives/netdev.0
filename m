From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: TG3 kernel lockup with 2.6.30
Date: Thu, 11 Jun 2009 16:11:54 -0700
Message-ID: <20090611231154.GA6380@xw6200.broadcom.net>
References: <455ea5df0906111501n77316560rf4d445891560a3e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Web Visum" <webvisum@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3392 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754380AbZFKXME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 19:12:04 -0400
In-Reply-To: <455ea5df0906111501n77316560rf4d445891560a3e0@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Can you give us the following :

* The driver sign-on messages that appear in the syslog.
* The output of 'ethtool -i ethx'.  I'm interested in the firmware
  version.  The 2.6.30 kernel will probably yeild better results here.
* The output of 'ethtool -d ethx' after the device is up.

Can you think of anything else about the system that changed from the
point where you started?  (BIOS settings, etc)

On Thu, Jun 11, 2009 at 03:01:27PM -0700, Web Visum wrote:
> Guys,
> 
> Apologies for emailing the world, but the situation is an emergency for me.
> 
> The box has been running 2.6.22.1 for over a year without a glitch.  Today I tried 2.6.30 and while things looked fine at the beginning, after a few minutes of traffic though the tg3 interface I've gotten a hard lockup, no kernel message, nothing to netconsole, just a total and complete lockup.   Not even sysrq was able to boot the box and it had to be power cycled.
> 
> Worse, it's reproducible.  And catastrophic, now kernel 2.6.22.1 also locks up in exactly the same manner.
> 
> I've tried turning off TSO via ethtool and that *appears* to delay the onset of the lockup, but it does not prevent it entirely.
> 
> The motherboard is a Tyan S2882, lspci -v -v output follows:
> 
> 02:09.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5704 Gigabit Ethernet (rev 03)
>         Subsystem: Broadcom Corporation Device 1644
>         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
>         Latency: 64 (16000ns min), Cache Line Size: 64 bytes
>         Interrupt: pin A routed to IRQ 24
>         Region 0: Memory at fc9c0000 (64-bit, non-prefetchable) [size=64K]
>         Region 2: Memory at fc9b0000 (64-bit, non-prefetchable) [size=64K]
>         Expansion ROM at fc9a0000 [disabled] [size=64K]
>         Capabilities: [40] PCI-X non-bridge device
>                 Command: DPERE- ERO- RBC=2048 OST=1
>                 Status: Dev=02:09.0 64bit+ 133MHz+ SCD- USC- DC=simple DMMRBC=2048 DMOST=1 DMCRS=16 RSCEM- 266MHz- 533MHz-
>         Capabilities: [48] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable+ DSel=0 DScale=1 PME-
>         Capabilities: [50] Vital Product Data
>                 Not readable
>         Capabilities: [58] MSI: Mask- 64bit+ Count=1/8 Enable-
>                 Address: 866a048401200080  Data: 1c08
>         Kernel driver in use: tg3
> 
> tg3 driver version on the  2.6.22.1 kernel is: v3.77 (May 31, 2007) while on 2.6.30 it is v3.98 (February 25, 2009)
> 
> I would very much appreciate any ideas you may have on how we can fix this.
> 
> Best,
> Richard

