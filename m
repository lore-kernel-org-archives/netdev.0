From: bhartin@straus-frank.com
Subject: Re: r8169, 2.6.2-rc2, Sager 4780 laptop
Date: Sun, 4 Apr 2004 16:05:39 -0500 (CDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0404041553010.6853@edp12.straus-frank.int>
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


Francois:

I don't remember if I ever did reply to you last time concerning this.  
Since I emailed you, I've tried many, many versions of the 2.6.x series 
kernels and superpatch variants.  The only change was with today's release 
of 2.6.5.  I now get the message "eth0: Too much work at interrupt!" prior 
to the interface locking up.

I still have absolutely no problems with the 2.4.x kernels with respect to 
the networking (I have video/AGP issues with it though, but that's another 
story).

Trying the same kernel with SMP and ACPI disabled:  Rather than the 
interface locking up (the NIC failing to transmit or receive), the entire 
system locks up hard.

All of these tests are done on a 100Mbit network, both on an unmanaged 
Linksys switch and on a Cisco 2948G, with the same results.  The test is 
done by doing an scp to copy a remote file to the local filesystem.  The 
lockups occur anywhere from 45MBytes to 95MBytes transferred.

I haven't tried your latest set of patches because I haven't been able to 
find the URL for them again (I got carried away cleaning up my bookmarks 
recently).  Let me know if there are any newer ones you'd like for me to 
try.

Bradley Hartin - bhartin@straus-frank.com
Communications and Network Administrator
Straus-Frank Company
Thanks,

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
