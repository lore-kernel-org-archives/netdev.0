From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 13:21:34 +0300
Message-ID: <1241000494.6554.307.camel@blade.ines.ro>
References: <20090423082052.GA4243@ff.dom.local>
	 <1240495002.6554.155.camel@blade.ines.ro>
	 <20090423181936.GA2756@ami.dom.local>
	 <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
	 <1240566136.6554.220.camel@blade.ines.ro>
	 <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-172-Unkn.Local.iNES.RO ([80.86.100.172]:38581 "EHLO
	blade.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751545AbZD2KVs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 06:21:48 -0400
In-Reply-To: <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the oprofile newbie guide - it saved much time and digging
through man pages.

Normal report looks like this:
samples  %        image name               app name                 symbol name
38424    30.7350  cls_u32.ko               cls_u32                  u32_classify
5321      4.2562  e1000e.ko                e1000e                   e1000_clean_rx_irq
4690      3.7515  vmlinux                  vmlinux                  ipt_do_table
3825      3.0596  sch_htb.ko               sch_htb                  htb_dequeue
3458      2.7660  vmlinux                  vmlinux                  __hash_conntrack
2597      2.0773  vmlinux                  vmlinux                  nf_nat_setup_info
2531      2.0245  vmlinux                  vmlinux                  kmem_cache_alloc
2229      1.7830  vmlinux                  vmlinux                  ip_route_input
1722      1.3774  vmlinux                  vmlinux                  nf_conntrack_in
1547      1.2374  sch_htb.ko               sch_htb                  htb_enqueue
1519      1.2150  vmlinux                  vmlinux                  kmem_cache_free
1471      1.1766  vmlinux                  vmlinux                  __slab_free
1435      1.1478  vmlinux                  vmlinux                  dev_queue_xmit
1313      1.0503  vmlinux                  vmlinux                  __qdisc_run
1277      1.0215  vmlinux                  vmlinux                  netif_receive_skb

All other symbols are below 1%.

sch_htb.ko report is this:

samples  %        image name               symbol name
-------------------------------------------------------------------------------
3825     49.0762  sch_htb.ko               htb_dequeue
  3825     100.000  sch_htb.ko               htb_dequeue [self]
-------------------------------------------------------------------------------
1547     19.8486  sch_htb.ko               htb_enqueue
  1547     100.000  sch_htb.ko               htb_enqueue [self]
-------------------------------------------------------------------------------
608       7.8009  sch_htb.ko               htb_lookup_leaf
  608      100.000  sch_htb.ko               htb_lookup_leaf [self]
-------------------------------------------------------------------------------
459       5.8891  sch_htb.ko               htb_deactivate_prios
  459      100.000  sch_htb.ko               htb_deactivate_prios [self]
-------------------------------------------------------------------------------
417       5.3503  sch_htb.ko               htb_add_to_wait_tree
  417      100.000  sch_htb.ko               htb_add_to_wait_tree [self]
-------------------------------------------------------------------------------
372       4.7729  sch_htb.ko               htb_change_class_mode
  372      100.000  sch_htb.ko               htb_change_class_mode [self]
-------------------------------------------------------------------------------
276       3.5412  sch_htb.ko               htb_activate_prios
  276      100.000  sch_htb.ko               htb_activate_prios [self]
-------------------------------------------------------------------------------
189       2.4249  sch_htb.ko               htb_add_to_id_tree
  189      100.000  sch_htb.ko               htb_add_to_id_tree [self]
-------------------------------------------------------------------------------
101       1.2959  sch_htb.ko               htb_safe_rb_erase
  101      100.000  sch_htb.ko               htb_safe_rb_erase [self]
-------------------------------------------------------------------------------

Am I misinterpreting the results, or does it look like the real problem
is actually packet classification?

Thanks,

Radu Rendec

On Tue, 2009-04-28 at 12:15 +0200, Jesper Dangaard Brouer wrote:
> Remember to keep/copy the file "vmlinux".
> 
> Here is the steps I usually use:
> 
>   opcontrol --vmlinux=/boot/vmlinux-`uname -r`
> 
>   opcontrol --stop
>   opcontrol --reset
>   opcontrol --start
> 
>   <perform stuff that needs profiling>
> 
>   opcontrol --stop
> 
> "Normal" report
>   opreport --symbols --image-path=/lib/modules/`uname -r`/kernel/ | less
> 
> Looking at specific module "sch_htb"
> 
>   opreport --symbols -cl sch_htb.ko --image-path=/lib/modules/`uname 
> -r`/kernel/


