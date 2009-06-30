From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Tue, 30 Jun 2009 06:40:22 +0000
Message-ID: <20090630064022.GA5589@ff.dom.local>
References: <4A450955.1010806@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:47977 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbZF3Gk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 02:40:26 -0400
Received: by bwz9 with SMTP id 9so3684056bwz.37
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 23:40:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A450955.1010806@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26-06-2009 19:45, Pawe. Staszewski wrote:
> Eric Dumazet pisze:
...
>> Pawel made some reports errors in fib thread, so I am not sure he really
>>  tried 2.6.30 and had same oprofile results.
>>
>> rt_worker_func() taking 13% of cpu0 is an alarm for me :)
>> And 21% of cpu0 and 34% of cpu6 taken by oprofiled seems odd too...
>>
>> Pawel, could you give us :
>>
>> grep . /proc/sys/net/ipv4/route/*
>> cat /proc/interrupts
>>
>> on your various kernels (previous to 2.6.29, 2.6.29, 2.6.30, ...)
>>
>> I suspect a change in hash table size, and/or change in interrupt affinities...

Btw., Pawel these eth0's don't look like affined or I miss something?

Jarek P.
...
> 
> cat /proc/interrupts
>            CPU0       CPU1       CPU2       CPU3       CPU4       
> CPU5       CPU6       CPU7
...
>  29:    1139988   18351004      89662          3          0          
> 1          0          3   PCI-MSI-edge      eth0
>  30:          0          2   20221692          1          0          
> 3          0          0   PCI-MSI-edge      eth1
...
> second machine:
> Linux TM_02_C1 2.6.30 #1 SMP Thu Jun 25 21:49:58 CEST 2009 i686 Intel(R) 
> Xeon(R) CPU 3075 @ 2.66GHz GenuineIntel GNU/Linux
> 
> cat /proc/interrupts
>            CPU0       CPU1
...
>  28:      13482      11260   PCI-MSI-edge      eth2
>  29:          3 1326457765   PCI-MSI-edge      eth1
>  30: 1240943198  137973134   PCI-MSI-edge      eth0
