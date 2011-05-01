From: zhou rui <zhourui.cn@gmail.com>
Subject: ask help for analysising oprofile result (higher mwait_idle_with_hints)
Date: Sun, 1 May 2011 22:08:23 +0800
Message-ID: <BANLkTikJfXBYsXpPBJUrOb37aaLCX8PbMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: jon.zhou@jdsu.com
To: linux-kernel@vger.kernel.org, linux-smp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60381 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab1EAOIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 10:08:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

A network application (with its kernel network driver),
it uses 5-8% cpu(I have tested it on kernel 2.6.34, seen from 'top'),
but I got 40% cpu usage on kernel 2.6.36
so that I tried oprofile to see what happen:

opcontrol --vmlinux=/home/kho56208/linux-2.6.36.4/vmlinux
...


compared with profile result on kernel 2.6.34, the
"mwait_idle_with_hints" got a higher "CPU_CLK_UNHALTED " event sample,

what does it mean? any clue?

CPU: Intel Architectural Perfmon, speed 2666.01 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a
unit mask of 0x00 (No unit mask) count 100000
samples  %        symbol name
115595   17.5906  mwait_idle_with_hints
27098     4.1236  __alloc_skb
25992     3.9553  __slab_free
25707     3.9120  __netif_receive_skb
18784     2.8584  __kmalloc_node_track_caller
18223     2.7731  get_partial_node
17860     2.7178  add_partial
17662     2.6877  kfree
17655     2.6866  kmem_cache_alloc_node
...

(kernel 2.6.34):

CPU: Intel Architectural Perfmon, speed 1600 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a
unit mask of 0x00 (No unit mask) count 100000
samples  %        symbol name
389859    7.9392  mwait_idle_with_hints
306288    6.2374  kfree
273832    5.5764  kmem_cache_alloc_node
268486    5.4675  netif_receive_skb
219047    4.4607  __alloc_skb
192371    3.9175  kmem_cache_free
138046    2.8112  memcpy
133959    2.7280  dev_gro_receive



system wide profile (2.6.36)

"MY_APPLICATION" got 40%  cpu usage,why it is  only 0.8799% seen from oprofile?
(the machine has 12 cores, and the oprofile is to measure all cores

CPU: Intel Architectural Perfmon, speed 2666.01 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a
unit mask of 0x00 (No unit mask) count 100000
CPU_CLK_UNHALT...|
  samples|      %|
------------------
   656980 40.1202 vmlinux
   473114 28.8919 vmlinux
   298978 18.2579 MY_KERNEL_DRIVER
   165838 10.1273 ixgbe
    14408  0.8799 MY_APPLICATION
    10443  0.6377 libc-2.11.1.so
     8251  0.5039 processor
     4658  0.2845 oprofiled
     3103  0.1895 libpthread-2.11.1.so
     1209  0.0738 oprofile
