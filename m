From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: htb parallelism on multi-core platforms
Date: Wed, 29 Apr 2009 12:31:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0904291225010.23626@tyr.diku.dk>
References: <20090423082052.GA4243@ff.dom.local>  <1240495002.6554.155.camel@blade.ines.ro>
  <20090423181936.GA2756@ami.dom.local>  <Pine.LNX.4.64.0904232148120.13815@ask.diku.dk>
  <1240566136.6554.220.camel@blade.ines.ro>  <Pine.LNX.4.64.0904281142270.21301@tyr.diku.dk>
 <1241000494.6554.307.camel@blade.ines.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Denys Fedoryschenko <denys@visp.net.lb>,
	netdev <netdev@vger.kernel.org>
To: Radu Rendec <radu.rendec@ines.ro>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:47918 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751748AbZD2KbW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 06:31:22 -0400
In-Reply-To: <1241000494.6554.307.camel@blade.ines.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 29 Apr 2009, Radu Rendec wrote:

> Thanks for the oprofile newbie guide - it saved much time and digging
> through man pages.

You are welcome :-)

Just noticed that Jeremy Kerr has made some python scripts to make it even 
easier to use oprofile.
See http://ozlabs.org/~jk/diary/tech/linux/hiprofile-v1.0.diary/


> Normal report looks like this:
> samples  %        image name               app name                 symbol name
> 38424    30.7350  cls_u32.ko               cls_u32                  u32_classify
> 5321      4.2562  e1000e.ko                e1000e                   e1000_clean_rx_irq
> 4690      3.7515  vmlinux                  vmlinux                  ipt_do_table
> 3825      3.0596  sch_htb.ko               sch_htb                  htb_dequeue
> 3458      2.7660  vmlinux                  vmlinux                  __hash_conntrack
> 2597      2.0773  vmlinux                  vmlinux                  nf_nat_setup_info
> 2531      2.0245  vmlinux                  vmlinux                  kmem_cache_alloc
> 2229      1.7830  vmlinux                  vmlinux                  ip_route_input
> 1722      1.3774  vmlinux                  vmlinux                  nf_conntrack_in
> 1547      1.2374  sch_htb.ko               sch_htb                  htb_enqueue
> 1519      1.2150  vmlinux                  vmlinux                  kmem_cache_free
> 1471      1.1766  vmlinux                  vmlinux                  __slab_free
> 1435      1.1478  vmlinux                  vmlinux                  dev_queue_xmit
> 1313      1.0503  vmlinux                  vmlinux                  __qdisc_run
> 1277      1.0215  vmlinux                  vmlinux                  netif_receive_skb
>
> All other symbols are below 1%.
>
> sch_htb.ko report is this:
> ...

I would rather want to see the output from cls_u32.ko

opreport --symbols -cl cls_u32.ko --image-path=/lib/modules/`uname -r`/kernel/


> Am I misinterpreting the results, or does it look like the real problem
> is actually packet classification?

Yes, it looks like the problem is your u32 classification setup... Perhaps 
its not doing what you think its doing...  didn't Jarek provide some hints 
for you to follow?


> On Tue, 2009-04-28 at 12:15 +0200, Jesper Dangaard Brouer wrote:
>> Remember to keep/copy the file "vmlinux".
>>
>> Here is the steps I usually use:
>>
>>   opcontrol --vmlinux=/boot/vmlinux-`uname -r`
>>
>>   opcontrol --stop
>>   opcontrol --reset
>>   opcontrol --start
>>
>>   <perform stuff that needs profiling>
>>
>>   opcontrol --stop
>>
>> "Normal" report
>>   opreport --symbols --image-path=/lib/modules/`uname -r`/kernel/ | less
>>
>> Looking at specific module "sch_htb"
>>
>>   opreport --symbols -cl sch_htb.ko --image-path=/lib/modules/`uname
>> -r`/kernel/


Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
