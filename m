From: bhartin@straus-frank.com
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Tue, 27 Jan 2004 00:51:44 -0600 (CST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0401261834110.10626@edp12.straus-frank.int>
References: <Pine.LNX.4.58.0401261443190.7894@edp12.straus-frank.int>
 <20040126235559.A3832@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040126235559.A3832@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Okay, I patched using only the patches listed below.  These are actually 
applied against 2.6.2-rc2, since I don't have 2.6.2-rc1 on hand at the 
moment, and your patches still apply cleanly.

acpi=off 
- RX - Pushed about a gig, averaging 8.2MB/sec.  Appeared to work ok.
- TX - Once I hit 642MB transfered (avg 8.9MB/sec), the system locked up 
hard.

SMP off, acpi on
- TX - Hard lock at 307MB.

SMP off, acpi off
- TX - Hard lock at 345MB.

I'll try to investigate further tomorrow.  I have to go out of town 
starting Thursday, and was hoping to have everything working by then.  
Unfortunately, I have other problems to deal with as well (ati-drivers, 
slmodem, etc).

Thanks

On Mon, 26 Jan 2004, Francois Romieu wrote:

> bhartin@straus-frank.com <bhartin@straus-frank.com> :
> [...]
> > Attached is a tar.gz containing the outputs you request in your README, 
> > plus 'lspci -v' output and my .config for the kernel.  This data was 
> > collected from a fresh 2.6.2-rc2 bootup, using your full set of 2.6.2-rc1 
> > patches, manually doing a 'modprobe r8169' once booted up.  The system is 
> > running a P4 with HT enabled, with an SMP kernel.
> 
> There has been report of non-regression on non-SMP kernel with the following
> patches applied (2.6.2-rc1 serie):
> r8169-tx-index-overflow.patch
> r8169-dma-api-tx.patch
> r8169-dma-api-rx-buffers.patch
> r8169-dma-api-tx-buffers.patch
> r8169-rx_copybreak.patch
> r8169-mac-phy-version.patch
> r8169-init_one.patch
> r8169-timer.patch
> r8169-hw_start.patch
> r8169-intr_mask.patch
> r8169-suspend.patch
> r8169-endianness.patch
> r8169-getstats.patch
> 
> Can you confirm that the driver behaves the same as the standard driver
> with a non-SMP enabled kernel ?
> 
> Does it make a difference if you give an 'acpi=off' option at boot time ?
> 
> r8169-addr-high.patch is not doing its job on amd64 so it is not suggested
> to use it at all.
> 
> There is something broken wrt SMP and the r8169 patches: do not use both at
> the same time. I still have to find what happens here.
> 
> --
> Ueimor
> 

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company
