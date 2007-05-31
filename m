From: Doug Chapman <doug.chapman@hp.com>
Subject: Re: REGRESSION: panic on e1000 driver
Date: Thu, 31 May 2007 18:38:28 -0400
Message-ID: <1180651108.23536.35.camel@athlon>
References: <1180560150.29081.35.camel@deimos.americas.hpqcorp.net>
	 <20070531010814.GA30709@gondor.apana.org.au>
	 <1180624569.23536.7.camel@athlon>
	 <20070531221036.GA9644@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33403 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983AbXEaWjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 May 2007 18:39:11 -0400
In-Reply-To: <20070531221036.GA9644@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-06-01 at 08:10 +1000, Herbert Xu wrote:
> On Thu, May 31, 2007 at 11:16:09AM -0400, Doug Chapman wrote:
> > 
> > # dmesg | grep e1000
> > e1000: 0000:01:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f8
> > e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
> > e1000: 0000:01:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:15:60:04:d7:f9
> > e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
> > e1000: 0000:15:02.0: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c4
> > e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
> > e1000: 0000:15:02.1: e1000_probe: (PCI-X:66MHz:64-bit) 00:12:79:9e:b7:c5
> > e1000: eth3: e1000_probe: Intel(R) PRO/1000 Network Connection
> > e1000: Unexpected interrupt icr=0x4
> > e1000: eth0: e1000_watchdog: NIC Link is Up 1000 Mbps Full Duplex, Flow
> > Control: RX
> 
> OK that's interesting.
> 
> Does this patch (please unapply the last one first) make the printk
> go away or does it trigger a backtrace?
> 
> Thanks,

I get a backtrace as it probes each e1000 device and I also still get
the unexpected interrupt message.


WARNING: at drivers/net/e1000/e1000_main.c:1331 e1000_sw_init()

Call Trace:
 [<a000000100013c20>] show_stack+0x40/0xa0
                                sp=e0000017e50c7b30 bsp=e0000017e50c1120
 [<a000000100013cb0>] dump_stack+0x30/0x60
                                sp=e0000017e50c7d00 bsp=e0000017e50c1108
 [<a000000236c47a40>] e1000_probe+0xce0/0x1ee0 [e1000]
                                sp=e0000017e50c7d00 bsp=e0000017e50c1098
 [<a0000001002d5540>] pci_device_probe+0x260/0x3a0
                                sp=e0000017e50c7d10 bsp=e0000017e50c1050
 [<a0000001003e2d10>] driver_probe_device+0x250/0x380
                                sp=e0000017e50c7de0 bsp=e0000017e50c1010
 [<a0000001003e3120>] __driver_attach+0x100/0x1a0
                                sp=e0000017e50c7de0 bsp=e0000017e50c0fd8
 [<a0000001003e10c0>] bus_for_each_dev+0x80/0x100
                                sp=e0000017e50c7de0 bsp=e0000017e50c0fa0
 [<a0000001003e28e0>] driver_attach+0x40/0x60
                                sp=e0000017e50c7e00 bsp=e0000017e50c0f80
 [<a0000001003e18b0>] bus_add_driver+0xf0/0x3c0
                                sp=e0000017e50c7e00 bsp=e0000017e50c0f40
 [<a0000001003e3680>] driver_register+0x140/0x160
                                sp=e0000017e50c7e00 bsp=e0000017e50c0f20
 [<a0000001002d5a10>] __pci_register_driver+0xd0/0x160
                                sp=e0000017e50c7e00 bsp=e0000017e50c0ee8
 [<a0000002363400b0>] e1000_init_module+0xb0/0x1b0 [e1000]
                                sp=e0000017e50c7e00 bsp=e0000017e50c0ec8
 [<a0000001000cd440>] sys_init_module+0x2dc0/0x31a0
                                sp=e0000017e50c7e00 bsp=e0000017e50c0d48
 [<a00000010000bae0>] ia64_ret_from_syscall+0x0/0x20
                                sp=e0000017e50c7e30 bsp=e0000017e50c0d48


- Doug


