From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Thu, 22 Sep 2016 17:53:58 +0200
Message-ID: <ec6b6344-f548-8605-fcad-846d9e48b1f0@zonque.org>
References: <20160919191910.GA984@salvia>
 <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
 <20160919203533.GA888@salvia>
 <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org>
 <20160920142931.GA31438@salvia>
 <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org>
 <20160921154533.GA13656@salvia> <20160921184827.GA15732@pox.localdomain>
 <20160922092138.GA12108@salvia> <20160922095411.GA5654@pox.localdomain>
 <20160922120554.GA1738@salvia> <57E3F4F9.70300@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org,
        fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57E3F4F9.70300-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/22/2016 05:12 PM, Daniel Borkmann wrote:
> On 09/22/2016 02:05 PM, Pablo Neira Ayuso wrote:

>> Benefits are, rewording previous email:
>>
>> * You get access to all of the existing netfilter hooks in one go
>>    to run bpf programs. No need for specific redundant hooks. This
>>    provides raw access to the netfilter hook, you define the little
>>    code that your hook runs before you bpf run invocation. So there
>>    is *no need to bloat the stack with more hooks, we use what we
>>    have.*
> 
> But also this doesn't really address the fundamental underlying problem
> that is discussed here. nft doesn't even have cgroups v2 support, only
> xt_cgroups has it so far, but even if it would have it, then it's still
> a scalability issue that this model has over what is being proposed by
> Daniel, since you still need to test linearly wrt cgroups v2 membership,
> whereas in the set that is proposed it's integral part of cgroups and can
> be extended further, also for non-networking users to use this facility.
> Or would the idea be that the current netfilter hooks would be redone in
> a way that they are generic enough so that any other user could make use
> of it independent of netfilter?

Yes, that part I don't understand either.

Pablo, could you outline in more detail (in terms of syscalls, commands,
resulting nftables layout etc) how your proposed model would support
having per-cgroup byte and packet counters for both ingress and egress,
and filtering at least for ingress?

And how would that mitigate the race gaps you have been worried about,
between cgroup creation and filters taking effect for a task?


Thanks,
Daniel
