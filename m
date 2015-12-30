From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 05/12] net: sched: per cpu gso handlers
Date: Wed, 30 Dec 2015 12:42:09 -0800
Message-ID: <568441A1.2030302@gmail.com>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>	<20151230175249.26257.99.stgit@john-Precision-Tower-5810> <20151230212633.23fc9b7c@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, davem@davemloft.net,
	john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32831 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753983AbbL3UmX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 15:42:23 -0500
Received: by mail-pa0-f42.google.com with SMTP id cy9so142757508pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 12:42:23 -0800 (PST)
In-Reply-To: <20151230212633.23fc9b7c@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-12-30 12:26 PM, Jesper Dangaard Brouer wrote:
> On Wed, 30 Dec 2015 09:52:49 -0800
> John Fastabend <john.fastabend@gmail.com> wrote:
> 
>> The net sched infrastructure has a gso ptr that points to skb structs
>> that have failed to be enqueued by the device driver.
> 
> What about fixing up the naming "gso" to something else like "requeue",
> in the process (or by an pre-patch) ?

Sure I'll throw a patch in front of this to rename it.

> 
> 
>> This can happen when multiple cores try to push a skb onto the same
>> underlying hardware queue resulting in lock contention. This case is
>> handled by a cpu collision handler handle_dev_cpu_collision(). Another
>> case occurs when the stack overruns the drivers low level tx queues
>> capacity. Ideally these should be a rare occurrence in a well-tuned
>> system but they do happen.
>>
>> To handle this in the lockless case use a per cpu gso field to park
>> the skb until the conflict can be resolved. Note at this point the
>> skb has already been popped off the qdisc so it has to be handled
>> by the infrastructure.
> 
> I generally like this idea of resolving this per cpu.  (I stalled here,
> on the requeue issue, last time I implemented a lockless qdisc
> approach).
> 

Great, this approach seems to work OK.

On another note even if we only get a single skb dequeued at a time in
the initial implementation this is still a win as soon as we start
running classifiers/actions. Even if doing simple pfifo_fast sans
classifiers raw throughput net gain is minimal.

.John
