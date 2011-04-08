From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 8 Apr 2011 20:19:41 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
 <1302253651.4409.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:64055 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755685Ab1DHMUC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 08:20:02 -0400
In-Reply-To: <1302253651.4409.2.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,
I tried more testing with by disable this CONFIG_DMAR with shipped 2.6.=
38 ixgbe and Intel released 3.2.10/3.1.15.
All these test looks we can get >1Mpps 400bype packtes but not stable a=
t all, there will huge number missing errors with 100% CPU IDLE:
ethtool -S eth10 |grep rx_missed_errors

        rx_missed_errors: 76832040

SUM: 1102212 ETH8: 0  ETH10: 1102212 ETH6: 0 ETH4: 0
SUM: 521841 ETH8: 0  ETH10: 521841 ETH6: 0 ETH4: 0
SUM: 426776 ETH8: 0  ETH10: 426776 ETH6: 0 ETH4: 0
SUM: 927520 ETH8: 0  ETH10: 927520 ETH6: 0 ETH4: 0
SUM: 1171995 ETH8: 0  ETH10: 1171995 ETH6: 0 ETH4: 0
SUM: 855980 ETH8: 0  ETH10: 855980 ETH6: 0 ETH4: 0


Do you know if there is other options in the kernel will cause high rat=
e rx_missed_errors with low CPU usage. (No problem on 2.6.32 with same =
test case)

perf  record:
+     69.74%          swapper  [kernel.kallsyms]          [k] poll_idle
+     11.62%          swapper  [kernel.kallsyms]          [k] intel_idl=
e
+      0.80%          swapper  [ixgbe]                    [k] ixgbe_pol=
l
+      0.79%             perf  [ixgbe]                    [k] ixgbe_pol=
l
+      0.77%             perf  [kernel.kallsyms]          [k] skb_copy_=
bits
+      0.64%          swapper  [kernel.kallsyms]          [k] skb_copy_=
bits
+      0.48%             perf  [kernel.kallsyms]          [k] __kmalloc=
_node_track_caller
+      0.44%          swapper  [kernel.kallsyms]          [k] __kmalloc=
_node_track_caller
+      0.36%          swapper  [kernel.kallsyms]          [k] kmem_cach=
e_alloc_node
+      0.35%          swapper  [kernel.kallsyms]          [k] kfree
+      0.35%             perf  [kernel.kallsyms]          [k] kmem_cach=
e_alloc_node


-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Friday, April 08, 2011 5:08 PM
To: Wei Gu
Cc: Alexander Duyck; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le vendredi 08 avril 2011 =E0 16:59 +0800, Wei Gu a =E9crit :
> Hi,
> On my configuration of Linux 2.6.38 we do enabled the CONFIG_DMAR
> CONFIG_DMAR=3Dy CONFIG_DMAR_DEFAULT_ON=3Dy CONFIG_DMAR_FLOPPY_WA=3Dy
> CONFIG_INTR_REMAP=3Dy
>
> But I enabled this DMAR also by default of the RHEL6 2.6.32 kernel,
> which we don't see this problem on this kernel. The only different I
> can see on the config is "CONFIG_DMAR_DEFAULT_ON"
> CONFIG_DMAR=3Dy
> # CONFIG_DMAR_DEFAULT_ON is not set
> CONFIG_DMAR_FLOPPY_WA=3Dy
> CONFIG_INTR_REMAP=3Dy
>
> I could try the same configuration as 2.6.32 for the 2.6.38 kernel by
> unset the CONFIG_DMAR_DEFAULT_ON. And run the test again, hopefully w=
e
> can get the test result next Monday:)

Just say no to CONFIG_DMAR, end of problems, no need to try various kno=
bs and find the solution next month ;)

Unless you have a reason to use it.



