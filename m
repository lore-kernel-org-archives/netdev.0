From: John Partridge <johnip@sgi.com>
Subject: Re: Tigon3 5701 PCI-X recv performance problem
Date: Wed, 12 Nov 2003 09:32:30 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB2528E.9020605@sgi.com>
References: <20031011105054.0e16a607.davem@redhat.com> <3F8C290A.3010508@sgi.com> <20031014095323.71c8b9fe.davem@redhat.com> <3FB03A56.7000709@sgi.com> <20031110182911.2c5a121b.davem@redhat.com> <3FB140E2.1070007@sgi.com> <20031111122403.2d7bcf28.davem@redhat.com> <3FB15725.4050705@sgi.com> <20031111235330.GA25553@wotan.suse.de> <3FB190FE.20005@sgi.com> <20031112061958.GA12065@wotan.suse.de> <3FB1DBBF.1010403@pobox.com>
Reply-To: johnip@sgi.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, "David S. Miller" <davem@redhat.com>,
        netdev@oss.sgi.com, jes@sgi.com, David Mosberger <davidm@hpl.hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3FB1DBBF.1010403@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeff Garzik wrote:
> Andi Kleen wrote:
>> Sorry to nitpick again and not catching it earlier, but are you sure 
>> it works this way? Normally the options in Kconfig are not prefixed 
>> with CONFIG_*
>> So
>> config UNALIGNED_EXPENSIVE
>> would be likely correct

Yes, that looks right to me. I'm still learning the whole 2.6 Kconfig thing

> 
> 
> 
> indeed.
> 
> For my part, I will apply the patch to drivers/net/tg3.c, which is fine, 
> and will let the arch/ia64/Kconfig patch go through normal channels 
> (since ia64 seems to be flowing these days).
> 
>     Jeff
> 
> 

Is this OK ?

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
+++ patch/arch/ia64/Kconfig     2003-11-12 09:31:14.000000000 -0600
@@ -468,6 +468,10 @@
           agent" (/sbin/hotplug) to load modules and set up software needed
           to use devices as you hotplug them.

+config UNALIGNED_EXPENSIVE
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
