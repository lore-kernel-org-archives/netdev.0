From: Olaf Hering <olh@suse.de>
Subject: Re: pcnet32 does not use the PROM address on powerpc
Date: Sat, 8 Oct 2005 14:03:16 +0200
Message-ID: <20051008120316.GA12122@suse.de>
References: <20051008104725.GA10248@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: netdev@vger.kernel.org, linuxppc64-dev@ozlabs.org
Content-Disposition: inline
In-Reply-To: <20051008104725.GA10248@suse.de>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

 On Sat, Oct 08, Olaf Hering wrote:

> I have a 44p 270, which gets all 0xFF as MAC address if I power if off
> and on again. Further reboots do not fix it.
> But it does get the correct one if I boot into SMS and do a netboot,
> further reboots will always get the correct MAC address

The CSR will get the correct value after the first ifup:

(none):/# modprobe -v pcnet32
insmod /lib/modules/2.6.13.3-20051007_rtas-ppc64/kernel/drivers/net/mii.ko 
insmod /lib/modules/2.6.13.3-20051007_rtas-ppc64/kernel/drivers/net/pcnet32.ko 
(none):/# ip link set eth0 up
(none):/# rmmod pcnet32
(none):/# modprobe -v pcnet32
insmod /lib/modules/2.6.13.3-20051007_rtas-ppc64/kernel/drivers/net/mii.ko 
insmod /lib/modules/2.6.13.3-20051007_rtas-ppc64/kernel/drivers/net/pcnet32.ko 
(none):/# dmesg | tail -n 15
pcnet32.c:v1.30j 29.04.2005 tsbogend@alpha.franken.de
PCI: Enabling device: (0000:00:10.0), cmd 143
pcnet32: PCnet/FAST 79C971 at 0xfff400, prom 0004ace4a6d7 csr ffffffffffff, warning: CSR address invalid,
    using instead PROM address of 00 04 ac e4 a6 d7
    tx_start_pt(0x0c00):~220 bytes, BCR18(68e1):BurstWrEn BurstRdEn DWordIO NoUFlow 
    SRAMSIZE=0x7f00, SRAM_BND=0x4000, assigned IRQ 18.
eth0: registered as PCnet/FAST 79C971
pcnet32: 1 cards_found.
eth0: link up, 100Mbps, half-duplex, lpa 0x40A1
pcnet32.c:v1.30j 29.04.2005 tsbogend@alpha.franken.de
pcnet32: PCnet/FAST 79C971 at 0xfff400, prom 0004ace4a6d7 csr 0004ace4a6d7, 00 04 ac e4 a6 d7
    tx_start_pt(0x0c00):~220 bytes, BCR18(68e1):BurstWrEn BurstRdEn DWordIO NoUFlow 
    SRAMSIZE=0x7f00, SRAM_BND=0x4000, assigned IRQ 18.
eth0: registered as PCnet/FAST 79C971
pcnet32: 1 cards_found.

-- 
short story of a lazy sysadmin:
 alias appserv=wotan
