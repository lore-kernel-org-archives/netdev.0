From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sat, 31 Jan 2009 02:37:05 +0100
Message-ID: <200901310237.06067.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901310138.51214.rjw@sisk.pl> <alpine.DEB.2.00.0901302016170.5643@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:51170 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521AbZAaBhw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 20:37:52 -0500
In-Reply-To: <alpine.DEB.2.00.0901302016170.5643@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 31 January 2009, Parag Warudkar wrote:
> 
> On Sat, 31 Jan 2009, Rafael J. Wysocki wrote:
> 
> > This gets more and more interesting.
> > 
> > Can you test the patch below, please?
> > 
> > Rafael
> > 
> > ---
> > Subject: PCI PCIe portdrv: Implement pm object
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> > 
> > Implement pm object for the PCI Express port driver in order to use
> > the new power management framework.
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > ---
> 
> Excellent! This patch works - tg3 comes back and gets link after resume.
> 
> Thank you!

Great, thanks for testing.

It's in the Jesse's linux-next branch, so it should be easy to push
upstream, perhaps with a better changelog.

> Are the below differences worth worrying about - especially since post 
> suspend some DevID/VendorID and some capabilities seem to be changed?

I can't tell you right now, I'm too tired. :-)

Anyway, they seem to be worth investigating.

Can you attach one of the files?  That will make it easier to look at the
differences.

Thanks,
Rafael


> parag@parag-desktop:~$ diff -u lspci-pre-suspend lspci-post-fix 
> --- lspci-pre-suspend   2009-01-30 18:19:50.752275695 -0500     
> +++ lspci-post-fix      2009-01-30 20:14:22.605607870 -0500     
> @@ -286,9 +286,9 @@                                             
>  10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 86 80            
>  30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
> -40: 00 00 00 00 00 00 0d 00 00 00 00 00 00 00 00 00            
> +40: 00 00 00 00 00 00 0f 00 00 00 00 00 00 00 00 00            
>  50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
> -60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
> +60: 00 00 00 00 00 00 00 00 00 01 00 00 00 00 00 00            
>  70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
> @@ -353,7 +353,7 @@                                             
>  40: 00 00 00 80 14 14 b0 b0 ff 01 00 30 ff 01 00 30            
>  50: 00 00 00 07 00 00 00 00 ff 3f ff 3f 00 40 00 40            
>  60: 00 40 00 40 01 80 01 80 00 00 00 00 00 00 00 00            
> -70: 00 00 00 00 6b e0 6b e0 00 00 0b a9 00 00 0b a9            
> +70: 00 00 00 00 00 c0 00 c0 01 1b 4c b8 01 1b 4c b8            
>  80: 24 07 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  90: 01 01 08 00 01 01 08 00 01 01 08 00 01 01 08 00            
>  a0: 01 01 08 00 00 00 00 00 00 00 00 00 00 00 00 00            
> @@ -395,7 +395,7 @@                                             
>  40: 00 00 00 80 14 14 b0 b0 ff 01 00 30 ff 01 00 30            
>  50: 00 00 00 07 00 00 00 00 ff 3f ff 3f 00 40 00 40            
>  60: 00 40 00 40 01 80 01 80 00 00 00 00 00 00 00 00            
> -70: 00 00 00 00 69 e0 69 e0 00 00 0b a9 00 00 0b a9            
> +70: 00 00 00 00 00 40 00 40 01 1b 4c b8 01 1b 4c b8            
>  80: 65 06 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  90: 01 01 20 00 01 01 20 00 01 01 20 00 01 01 20 00            
>  a0: 01 01 20 00 00 00 00 00 00 00 00 00 00 00 00 00            
> @@ -645,8 +645,8 @@                                             
>  30: 00 00 00 00 50 00 00 00 00 00 00 00 03 01 00 00            
>  40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  50: 01 58 c2 c9 00 00 00 00 0a 00 a0 20 00 00 00 00            
> -60: 20 20 ff 01 00 00 00 00 01 00 00 00 00 00 08 80            
> -70: 00 00 df 3f 00 00 00 00 00 00 00 00 00 00 00 00            
> +60: 20 20 ff 01 00 00 00 00 01 00 00 00 00 00 08 c0            
> +70: 00 00 dd 3f 00 00 00 00 00 00 00 00 00 00 00 00            
>  80: 00 00 00 00 01 00 00 00 00 00 00 00 00 00 00 00            
>  90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
> @@ -698,7 +698,7 @@                                             
>  70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  80: 10 00 09 14 01 04 00 00 81 04 00 00 00 00 00 00            
>  90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
> -a0: 10 06 00 00 01 00 00 00 00 00 00 00 00 13 00 00            
> +a0: 10 06 00 00 00 00 00 00 00 00 00 00 00 13 00 00            
>  b0: 00 00 00 00 00 00 00 00 00 10 00 04 00 00 00 00            
>  c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00            
>  d0: 33 22 11 00 67 45 00 00 c0 c0 00 00 02 00 00 00            
> @@ -754,7 +754,7 @@                                             
>         Capabilities: [50] Vital Product Data <?>               
>         Capabilities: [58] Vendor Specific Information <?>      
>         Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ 
> Queue=0/0 Enable+
> -               Address: 00000000fee0f00c  Data: 41c1                                  
> +               Address: 00000000fee0f00c  Data: 41c9                                  
>         Capabilities: [d0] Express (v1) Endpoint, MSI 00                               
>                 DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
> <4us, L1 unlimited
>                         ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-                  
> @@ -778,24 +778,24 @@                                                                    
>  20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13                                     
>  30: 00 00 04 20 48 00 00 00 00 00 00 00 03 01 00 00                                     
>  40: 00 00 00 00 00 00 00 00 01 50 03 c0 08 20 00 64                                     
> -50: 03 58 fc 00 00 00 00 78 09 e8 78 00 95 ef 08 88                                     
> +50: 03 58 fc 00 00 00 00 78 09 e8 78 00 9a f7 08 58                                     
>  60: 00 00 00 00 00 00 00 00 98 02 02 a0 00 00 18 76                                     
>  70: f2 10 00 00 c0 00 00 00 20 70 00 00 00 00 00 00                                     
>  80: 00 00 00 00 00 00 00 00 34 00 13 04 82 70 08 fc                                     
> -90: 19 be 00 01 00 00 00 00 00 00 00 00 94 01 00 00                                     
> -a0: 00 00 00 00 cc 00 00 00 00 00 00 00 29 01 00 00                                     
> -b0: 00 00 00 00 00 00 00 8e 00 00 00 00 00 00 00 00                                     
> +90: 19 be 00 01 00 00 00 44 00 00 00 00 e7 00 00 00                                     
> +a0: 00 00 00 00 1f 00 00 00 00 00 00 00 24 00 00 00                                     
> +b0: 00 00 00 00 00 00 00 44 00 00 00 00 00 00 00 00                                     
>  c0: 00 00 00 00 00 00 00 00 0e 00 00 00 00 00 00 00                                     
>  d0: 10 00 01 00 a0 8f 00 00 00 50 10 00 11 64 03 00                                     
>  e0: 40 00 11 10 00 00 00 00 05 d0 81 00 0c f0 e0 fe                                     
> -f0: 00 00 00 00 c1 41 00 00 00 00 00 00 00 00 00 00                                     
> +f0: 00 00 00 00 c9 41 00 00 00 00 00 00 00 00 00 00                                     
>                                                                                          
>  10:00.0 PCI bridge: Intel Corporation 6311ESB/6321ESB PCI Express 
> Upstream Port (rev 01)
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
> ParErr- Stepping- SERR+ FastB2B- DisINTx-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx- 
>         Latency: 0, Cache Line Size: 64 bytes                                                                
>         Bus: primary=10, secondary=1e, subordinate=40, sec-latency=0                                         
> -       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort+ <SERR- <PERR-       
> +       Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- <SERR- <PERR-       
>         BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-                                        
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-                                          
>         Capabilities: [44] Express (v1) Upstream Port, MSI 00                                                
> @@ -818,7 +818,7 @@                                                                                          
>         Kernel driver in use: pcieport-driver                                                                
>         Kernel modules: shpchp                                                                               
>  00: 86 80 00 35 07 01 10 00 01 00 04 06 10 00 81 00                                                         
> -10: 00 00 00 00 00 00 00 00 10 1e 40 00 f0 00 00 20                                                         
> +10: 00 00 00 00 00 00 00 00 10 1e 40 00 f0 00 00 00                                                         
>  20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00                                                         
>  30: 00 00 00 00 44 00 00 00 00 00 00 00 ff 01 06 00                                                         
>  40: 00 28 02 10 10 70 51 00 01 00 00 00 0f 50 0a 00                                                         
> @@ -839,7 +839,7 @@                                                                                          
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
> <TAbort- <MAbort- >SERR- <PERR- INTx- 
>         Latency: 0, Cache Line Size: 64 bytes                                                                
>         Bus: primary=10, secondary=11, subordinate=1d, sec-latency=32                                        
> -       Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- 
> <TAbort- <MAbort+ <SERR- <PERR-     
> +       Secondary status: 66MHz+ FastB2B+ ParErr- DEVSEL=medium >TAbort- 
> <TAbort- <MAbort- <SERR- <PERR-     
>         BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-                                        
>                 PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-                                          
>         Capabilities: [44] Express (v1) PCI/PCI-X Bridge, MSI 00                                             
> @@ -848,7 +848,7 @@                                                                                          
>                 DevCtl: Report errors: Correctable- Non-Fatal- Fatal- 
> Unsupported-                           
>                         RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop- 
> BrConfRtry-                             
>                         MaxPayload 128 bytes, MaxReadReq 512 bytes                                           
> -               DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr- 
> TransPend-                          
> +               DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- 
> TransPend-                          
>                 LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s, 
> Latency L0 unlimited, L1 unlimited       
>                         ClockPM- Suprise- LLActRep- BwNot-
>                 LnkCtl: ASPM Disabled; Disabled- Retrain- CommClk-
> @@ -857,7 +857,7 @@
>         Capabilities: [6c] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA 
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> -       Capabilities: [80] Subsystem: Hewlett-Packard Company Device 1307
> +       Capabilities: [80] Subsystem: Gammagraphx, Inc. Device 0000
>         Capabilities: [d8] PCI-X bridge device
>                 Secondary Status: 64bit+ 133MHz+ SCD- USC- SCO- SRD- 
> Freq=133MHz
>                 Status: Dev=00:00.3 64bit- 133MHz- SCD- USC- SCO- SRD-
> @@ -866,14 +866,14 @@
>         Capabilities: [100] Advanced Error Reporting <?>
>         Kernel modules: shpchp
>  00: 86 80 0c 35 07 01 10 00 01 00 04 06 10 00 81 00
> -10: 00 00 00 00 00 00 00 00 10 11 1d 20 f0 00 a0 22
> +10: 00 00 00 00 00 00 00 00 10 11 1d 20 f0 00 a0 02
>  20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
>  30: 00 00 00 00 44 00 00 00 00 00 00 00 00 00 06 00
> -40: 80 6e 00 ff 10 6c 71 00 01 00 00 00 00 20 0a 00
> +40: 80 6e 00 ff 10 6c 71 00 01 00 00 00 00 20 00 00
>  50: 81 f4 03 00 00 00 41 00 00 00 00 00 05 6c 80 00
>  60: 00 00 00 00 00 00 00 00 00 00 00 00 01 80 02 c8
>  70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> -80: 0d d8 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
> +80: 0d d8 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> @@ -916,7 +916,7 @@
>  20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
>  30: 00 00 00 00 44 00 00 00 00 00 00 00 00 01 06 00
>  40: 00 00 c0 00 10 60 61 00 01 00 00 00 0f 50 00 00
> -50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 48 00
> +50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 58 00
>  60: 05 70 81 00 0c f0 e0 fe 00 00 00 00 91 41 00 00
>  70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
>  80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
> @@ -962,7 +962,7 @@
>  20: f0 ff 00 00 f1 ff 01 00 00 00 00 00 00 00 00 00
>  30: 00 00 00 00 44 00 00 00 00 00 00 00 00 01 06 00
>  40: 00 00 c0 00 10 60 61 00 01 00 00 00 0f 50 00 00
> -50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 48 00
> +50: 41 f4 03 00 20 00 01 10 80 0c 00 00 c0 03 58 00
>  60: 05 70 81 00 0c f0 e0 fe 00 00 00 00 99 41 00 00
>  70: 01 80 02 c8 00 00 00 00 00 00 00 00 00 00 00 00
>  80: 0d 00 00 00 3c 10 07 13 00 00 00 00 00 00 00 00
> parag@parag-desktop:~$
