From: Jurriaan <thunder7@xs4all.nl>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sat, 14 Aug 2004 15:56:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040814135606.GA6001@middle.of.nowhere>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com>
Reply-To: Jurriaan <thunder7@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040814121533.GB18754@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, Aug 14, 2004 at 02:15:33PM +0200
> > What could be the problem here?
> 
> The transition from 2.6.8-rc3-mm1 to 2.6.8-rc4-mm1 changes both the
> point outlined above and the 8139too driver.
> 
> You may:
> 1 - try the "pci=routeirq" argument at startup on your 2.6.8-rc4-mm1 if you
>     have not done so;

that didn't help

> 2 - apply to your 2.6.8-rc4-mm1 tree:
>     http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch

I don't get it.

INTEL :patch -p1 -R --dry-run < ../268rc4mm1_8139too-mm-revert.patch 
patching file drivers/net/8139too.c
Hunk #1 FAILED at 593.
Hunk #2 FAILED at 1935.
Hunk #3 FAILED at 1951.
Hunk #4 FAILED at 1979.
Hunk #5 FAILED at 2006.
Hunk #6 FAILED at 2042.
Hunk #7 FAILED at 2062.
7 out of 7 hunks FAILED -- saving rejects to file drivers/net/8139too.c.rej
INTEL :patch -p1 --dry-run < ../268rc4mm1_8139too-mm-revert.patch
patching file drivers/net/8139too.c
Hunk #1 FAILED at 593.
Hunk #2 FAILED at 1934.
Hunk #3 FAILED at 1947.
Hunk #4 FAILED at 1976.
Hunk #5 FAILED at 1989.
Hunk #6 FAILED at 2024.
Hunk #7 FAILED at 2047.
7 out of 7 hunks FAILED -- saving rejects to file drivers/net/8139too.c.rej

This patch fails both with and without -R - how am I supposed to apply
it?

> 3 - apply to your 2.6.8-rc4-mm1 tree:
>     http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch
>     http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-10.patch
>     http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-20.patch
> 
I can get the -20 patch to apply with -R (with offsets), but after that
-10 with -R fails. 

Since it's the network card, here's some extra info:

0000:02:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+ (rev 10)
	Subsystem: Unex Technology Corp. ND010
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (8000ns min, 16000ns max)
	Interrupt: pin A routed to IRQ 23
	Region 0: I/O ports at a800
	Region 1: Memory at f3051000 (32-bit, non-prefetchable) [size=256]
	Capabilities: [50] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

Thanks,
Jurriaan [ please cc me: I'm not on netdev ]
-- 
No, no my lord. What I mean is we could get a mad wild killer bull
and disguise it as a bird.
	Baldrik in Blackadder II
Debian (Unstable) GNU/Linux 2.6.8-rc4-mm1 2x6078 bogomips load 0.31
