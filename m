From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 11 Nov 2003 15:39:49 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB15725.4050705@sgi.com>
References: <3F844578.40306@sgi.com>	<20031008101046.376abc3b.davem@redhat.com>	<3F8455BE.8080300@sgi.com>	<20031008183742.GA24822@wotan.suse.de>	<20031008122223.1ba5ac79.davem@redhat.com>	<20031008202248.GA15611@oldwotan.suse.de>	<3F8702FF.70500@sgi.com>	<20031010192036.GA31727@wotan.suse.de>	<3F8802E6.5030601@sgi.com>	<20031011131921.GC21763@wotan.suse.de>	<20031011105054.0e16a607.davem@redhat.com>	<3F8C290A.3010508@sgi.com>	<20031014095323.71c8b9fe.davem@redhat.com>	<3FB03A56.7000709@sgi.com>	<20031110182911.2c5a121b.davem@redhat.com>	<3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@oss.sgi.com, jgarzik@pobox.com, jes@sgi.com,
        David Mosberger <davidm@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031111122403.2d7bcf28.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> Why are you depending upon MCKINLEY?  Don't all ia64 cpus
> give traps for unaligned memory accesses?
> 
> That is what this CONFIG option tells the whole kernel.

OK, I made it ALL IA64, but I only know for sure about Itanium2's

--- linux/drivers/net/tg3.c     2003-11-10 18:28:10.000000000 -0600
+++ patch/drivers/net/tg3.c     2003-11-10 18:58:35.000000000 -0600
@@ -2257,7 +2257,11 @@

                 len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4; /* omit crc */

-               if (len > RX_COPY_THRESHOLD) {
+               if (len > RX_COPY_THRESHOLD
+#if defined(CONFIG_UNALIGNED_EXPENSIVE)
+                        && tp->rx_offset == 2
+#endif
+               ) {
                         int skb_size;

                         skb_size = tg3_alloc_rx_skb(tp, opaque_key,
--- linux/arch/ia64/Kconfig     2003-10-25 13:44:46.000000000 -0500
+++ patch/arch/ia64/Kconfig     2003-11-11 15:37:58.000000000 -0600
@@ -468,6 +468,11 @@
           agent" (/sbin/hotplug) to load modules and set up software needed
           to use devices as you hotplug them.

+config CONFIG_UNALIGNED_EXPENSIVE
+       bool "Use kernel aligned buffers"
+       depends on IA64
+       default y
+
  source "drivers/pci/hotplug/Kconfig"

  source "drivers/pcmcia/Kconfig"

-- 
John Partridge

Silicon Graphics Inc
Tel:  651-683-3428
Vnet: 233-3428
E-Mail: johnip@sgi.com
