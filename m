From: Eric Wheeler <netdev@lists.ewheeler.net>
Subject: Re: [PATCH net] bna: page allocation during interrupts to use a
 mempool.
Date: Wed, 8 Oct 2014 17:46:03 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1410081745160.18846@ware.dreamhost.com>
References: <alpine.DEB.2.00.1409271631530.26069@ware.dreamhost.com>     <20140929092833.6c2cb7e9@urahara>     <262CB373A6D1F14F9B81E82F74F77D5A4704FAE7@avmb2.qlogic.org>     <alpine.DEB.2.00.1410061850120.5129@ware.dreamhost.com>   
 <1412646735.11091.93.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.00.1410061956410.7392@ware.dreamhost.com>   <1412651746.11091.98.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.00.1410071746230.3503@ware.dreamhost.com>
 <1412731718.11091.175.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.00.1410081157470.16668@ware.dreamhost.com> <1412795092.11091.197.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>,
	Rasesh Mody <rasesh.mody@qlogic.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from homie.mail.dreamhost.com ([208.97.132.208]:45762 "EHLO
	homiemail-a9.g.dreamhost.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751347AbaJIAaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 20:30:22 -0400
In-Reply-To: <1412795092.11091.197.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> Further inspection of the driver told me that unmap->vector.len should
>>> be 16384 already. (same than PAGE_SIZE << 2)
>>> (set at line 304, drivers/net/ethernet/brocade/bna/bnad.c)
>>>
>>> So you might hit memory fragmentation issues.
>>>
>>> Do you have CONFIG_COMPACTION=y in your .config ?
>>
>> We're still having the backtrace.
>
> What is the output of
>
> free
> cat /proc/sys/vm/min_free_kbytes
> cat /proc/buddyinfo


[root@hv2 ~]# cat /proc/sys/vm/min_free_kbytes
262144

[root@hv2 ~]# cat /proc/buddyinfo
Node 0, zone      DMA      1      2      1      1      1      1      1      0      1      1      3
Node 0, zone    DMA32   2221  28306    771   2964    148      9      4      1      0      0      1
Node 0, zone   Normal 956207  99272      0      0      0      0      0      0      0      0      1

[root@hv2 ~]# free
              total       used       free     shared    buffers     cached
Mem:      33051552   28058192    4993360          0    3058040     158224
-/+ buffers/cache:   24841928    8209624
Swap:      8388604      21540    8367064

[root@hv2 ~]# free -m
              total       used       free     shared    buffers     cached
Mem:         32276      27401       4875          0       2986        154
-/+ buffers/cache:      24260       8016
Swap:         8191         21       8170
