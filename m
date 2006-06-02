From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.17-rc4: netfilter LOG messages truncated via NETCONSOLE (2)
Date: Fri, 2 Jun 2006 16:39:22 +0200
Message-ID: <20060602143922.GA8572@janus>
References: <447DAEC9.3050003@trash.net> <20060531160611.GA25637@janus> <447DC613.10102@trash.net> <20060531172936.GB25788@janus> <447DD66C.30605@trash.net> <20060601091124.GA31642@janus> <447F2537.1080807@trash.net> <20060602123559.GA7505@janus> <20060602140212.GA7881@janus> <44804828.2050909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:14208 "EHLO
	janus.localdomain") by vger.kernel.org with ESMTP id S932118AbWFBOjY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 10:39:24 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44804828.2050909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 02, 2006 at 04:16:08PM +0200, Patrick McHardy wrote:
> Which network driver are you using?

I've seen it with two completely different NICs at the sender side:
0000:02:08.0 Ethernet controller: Intel Corporation 82557/8/9 [Ethernet Pro 100] (rev 05)
0000:02:00.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5751 Gigabit Ethernet PCI Express (rev 01)

Snippet from bootlog:
Jun  2 16:24:05 posio kernel: e100: Intel(R) PRO/100 Network Driver, 3.5.10-k2-NAPI
Jun  2 16:24:05 posio kernel: e100: Copyright(c) 1999-2005 Intel Corporation
Jun  2 16:24:05 posio kernel: ACPI: PCI Interrupt 0000:02:08.0[A] -> GSI 16 (level, low) -> IRQ 16
Jun  2 16:24:05 posio kernel: e100: eth0: e100_probe: addr 0x40400000, irq 16, MAC addr 00:08:C7:69:29:AE
Jun  2 16:24:05 posio kernel: netconsole: device eth0 not up yet, forcing it
Jun  2 16:24:05 posio kernel: e100: eth0: e100_watchdog: link up, 100Mbps, full-duplex
Jun  2 16:24:05 posio kernel: netconsole: carrier detect appears untrustworthy, waiting 4 seconds
Jun  2 16:24:05 posio kernel: netconsole: network logging started

> Does this patch show anything in
> the ringbuffer?

no.

> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -302,6 +302,9 @@ static void netpoll_send_skb(struct netp
>  		netpoll_poll(np);
>  		udelay(50);
>  	} while (npinfo->tries > 0);
> +
> +	printk("failed to transmit\n");
> +	kfree_skb(skb);
>  }
>  
>  void netpoll_send_udp(struct netpoll *np, const char *msg, int len)


-- 
Frank
