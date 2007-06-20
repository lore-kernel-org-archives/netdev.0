From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8654] New: possible connect() bug
Date: Wed, 20 Jun 2007 09:57:46 -0700
Message-ID: <20070620095746.5b054da8.akpm@linux-foundation.org>
References: <bug-8654-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: risky@mail.ru,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>,
	Auke Kok <auke-jan.h.kok@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52445 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752952AbXFTQ56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 12:57:58 -0400
In-Reply-To: <bug-8654-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Wed, 20 Jun 2007 03:56:28 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=8654
> 
>            Summary: possible connect() bug
>            Product: Networking
>            Version: 2.5
>      KernelVersion: Linux version 2.6.21.1 (risky@001134.localnet) (gcc
>                     version 3.3.
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: low
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: risky@mail.ru
> 
> 
> ...
>
> 01:01.0 Ethernet controller: Intel Corp. 82547GI Gigabit Ethernet Controller
>         Subsystem: Micro-Star International Co., Ltd.: Unknown device 1490
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B-
>         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 0 (63750ns min), cache line size 08
>         Interrupt: pin A routed to IRQ 11
>         Region 0: Memory at fb100000 (32-bit, non-prefetchable) [size=128K]
>         Region 2: I/O ports at b000 [size=32]
>         Capabilities: [dc] Power Management version 2
>                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> 
> ...
> 
> Minimal slackware installation, kernel downloaded from kernel.org
> 
> Problem Description:
> 
> connect() syscall normally reports "no route to host" when is called while
> network cable is
> unplugged, and ethernet interface is up and configured. But it hangs eternally
> and utilizes
> processor up to 100% if one tries to plug ethernet cable in, here two cases:
> a) socket is blocking, connect() is called and did not completed, current
> syscall hangs
> b) socket is non-blocking, connect() normally returns EINPROGRESS, next syscall
> hangs
> 
> Steps to reproduce:
> 
> Just try to plug ethernet cable in while trying to connect()
> 

That might be a device driver bug.  Please generate a kernel profile while
it is occuring (Documentation/basic_profiling.txt) and/or generate a few
sysrq-P traces.  Send them via emailed reply-to-all to this email.

I'll be travelling for the next few days, but hopefully one of the netdev
developers will be able to work with you on this, thanks.  

