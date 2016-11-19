From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 4/5] virtio_net: add dedicated XDP transmit queues
Date: Sat, 19 Nov 2016 13:33:31 -0800
Message-ID: <5830C52B.8000108@gmail.com>
References: <20161118185517.16137.92123.stgit@john-Precision-Tower-5810>
 <20161118190041.16137.48399.stgit@john-Precision-Tower-5810>
 <20161118130953.7bf2d71d@laptop> <20161118181004.4c15a6a1@laptop>
 <582FBC6B.8000902@gmail.com> <20161118185728.67e2b53a@laptop>
 <1479525658.8455.313.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161118192317.6c283867@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, shm@cumulusnetworks.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        davem@davemloft.net, john.r.fastabend@intel.com,
        netdev@vger.kernel.org, bblanco@plumgrid.com, brouer@redhat.com
To: Jakub Kicinski <kubakici@wp.pl>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35292 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753117AbcKSVdv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 16:33:51 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so24224931pga.2
        for <netdev@vger.kernel.org>; Sat, 19 Nov 2016 13:33:51 -0800 (PST)
In-Reply-To: <20161118192317.6c283867@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-11-18 07:23 PM, Jakub Kicinski wrote:
> On Fri, 18 Nov 2016 19:20:58 -0800, Eric Dumazet wrote:
>> On Fri, 2016-11-18 at 18:57 -0800, Jakub Kicinski wrote:
>>> On Fri, 18 Nov 2016 18:43:55 -0800, John Fastabend wrote:  
>>>> On 16-11-18 06:10 PM, Jakub Kicinski wrote:  
>>  [...]  
>>>>
>>>> Seem like a valid concerns to me how about num_possible_cpus() instead.  
>>>
>>> That would solve problem 1, but could cpu_possible_mask still be sparse
>>> on strange setups?  Let me try to dig into this, I recall someone
>>> (Eric?) was fixing similar problems some time ago.  
>>
>> nr_cpu_ids is probably what you want ;)
> 
> Thank you :)
> 

Yep poked around a bit and the common pattern seems to be to use
nr_cpu_ids to build a cpu array and then index it with
smp_processor_id(). So I'll do this as well.

Although I'm not sure I entirely follow on the x86 platforms at
least how/if nr_cpu_ids != num_possible_cpus().

Nice catch Jakub.

Thanks,
John
