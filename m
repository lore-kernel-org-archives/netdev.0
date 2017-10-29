From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [RFC] please clarify local_irq_disable() in
 pcpu_freelist_populate()
Date: Sun, 29 Oct 2017 13:21:21 -0700
Message-ID: <a4e7d2cb-de19-5449-fddd-8606d8ab6602@fb.com>
References: <20171027222354.bf3wv4ldnrmc5pbx@linutronix.de>
 <72432216-c082-2f79-65bd-ee082fa369dc@fb.com>
 <20171029201438.g6f7eivvgtofpdvq@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <tglx@linutronix.de>, <peterz@infradead.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44612 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751587AbdJ2UWN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Oct 2017 16:22:13 -0400
In-Reply-To: <20171029201438.g6f7eivvgtofpdvq@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/17 1:14 PM, Sebastian Andrzej Siewior wrote:
> On 2017-10-27 19:18:40 [-0700], Alexei Starovoitov wrote:
>> pcpu_freelist_push() is called by bpf programs from atomic context.
>
> so raw would still be correct because the content is locked.

it would be incorrect because this_* versions have good checks in them
and no need to avoid them.

>> lockdep thinks that __pcpu_freelist_push() can be called recursively
>> in the middle of pcpu_freelist_populate's loop and will deadlock
>> which is not the case here. That's why local_irq_save() is there.
>> Just to silence lockdep.
>
> do you mind giving me bunch of test-cases so I can test it myself?

samples/bpf/map_perf_test*

>> While developing pcpu_freelist I've benchmarked many different
>> approaches. Some of the numbers are in
>> commit 6c9059817432 ("bpf: pre-allocate hash map elements")
>> iirc I passed on llist, since llist_del_first still needs a lock,
>> so doesn't really help.
>
> Okay. I will look that up.
>
> Sebastian
>
