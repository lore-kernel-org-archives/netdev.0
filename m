From: Jean-Pascal Billaud <billaud@vmware.com>
Subject: RE: GRO with non napi driver: BUG in __napi_complete
Date: Tue, 17 Mar 2009 08:49:10 -0700
Message-ID: <AF9CD7A487028E428749836D21102612201DA51F5D@PA-EXMBX02.vmware.com>
References: <49BF60C9.1080100@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.115.85.69]:46500 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752748AbZCQPtN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 11:49:13 -0400
In-Reply-To: <49BF60C9.1080100@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More generally, is there still a point to support non-napi drivers? Shouldn't we have a unique way to process traffic at the driver level?

--jp

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Frank Blaschka
> Sent: Tuesday, March 17, 2009 1:35 AM
> To: netdev@vger.kernel.org
> Cc: David Miller; Herbert Xu
> Subject: GRO with non napi driver: BUG in __napi_complete
> 
> Hi,
> 
> I try to activate GRO on a non napi driver (2.6.29-rc8). Running an
> iperf test
> causes a bug in __napi_complete.
> 
> kernel BUG at net/core/dev.c:2625!
> illegal operation: 0001 <DD>#1<A8> PREEMPT SMP
> Modules linked in:
> CPU: 1 Not tainted 2.6.29-rc8-00124-g5bee17f #8
> Process swapper (pid: 0, task: 000000002ff7ccc0, ksp: 000000002ff97d48)
> Krnl PSW : 0404d00180000000 00000000002d1f4e
> (__napi_complete+0x82/0x88)
>            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:3 CC:1 PM:0 EA:3
> ...
> <DD>  261.377396<A8> Call Trace:
> <DD>  261.377400<A8> (<DD><00000000002cb752><A8>
> process_backlog+0xba/0x104)
> <DD>  261.377410<A8>  <DD><00000000002cb5ba><A8>
> net_rx_action+0x102/0x1e0
> <DD>  261.377418<A8>  <DD><000000000004921e><A8>
> __do_softirq+0x92/0x168
> <DD>  261.377428<A8>  <DD><0000000000020936><A8> do_softirq+0x96/0xb0
> <DD>  261.377436<A8>  <DD><00000000000493c0><A8> irq_exit+0x70/0x80
> <DD>  261.377444<A8>  <DD><000000000025789c><A8> do_IRQ+0x174/0x194
> <DD>  261.377455<A8>  <DD><00000000000258da><A8> io_return+0x0/0x8
> <DD>  261.377464<A8>  <DD><00000000000246fe><A8>
> vtime_stop_cpu+0xb2/0xc0
> <DD>  261.377473<A8> (<DD><00000007005b1007><A8> 0x7005b1007)
> 
> What is the intention process_backlog calls __napi_complete() instead
> of
> napi_complete(), this looks suspicious to me. Can anybody help?
> 
> Thanks,
> 
> Frank
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
