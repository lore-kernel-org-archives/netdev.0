From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Tue, 11 Nov 2003 19:46:38 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB190FE.20005@sgi.com>
References: <3F8802E6.5030601@sgi.com> <20031011131921.GC21763@wotan.suse.de> <20031011105054.0e16a607.davem@redhat.com> <3F8C290A.3010508@sgi.com> <20031014095323.71c8b9fe.davem@redhat.com> <3FB03A56.7000709@sgi.com> <20031110182911.2c5a121b.davem@redhat.com> <3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com> <3FB15725.4050705@sgi.com> <20031111235330.GA25553@wotan.suse.de>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        jgarzik@pobox.com, jes@sgi.com, David Mosberger <davidm@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031111235330.GA25553@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks Andi,

Andi Kleen wrote:
> Drop the "bool" line. Then it will be invisible, which is the right thing here.


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
+++ patch/arch/ia64/Kconfig     2003-11-11 19:45:06.000000000 -0600
@@ -468,6 +468,10 @@
           agent" (/sbin/hotplug) to load modules and set up software needed
           to use devices as you hotplug them.

+config CONFIG_UNALIGNED_EXPENSIVE
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
