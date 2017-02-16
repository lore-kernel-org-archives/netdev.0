From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Thu, 16 Feb 2017 16:45:34 +1300
Message-ID: <87tw7u4x41.fsf@xmission.com>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
        <87h93xqlui.fsf@xmission.com>
        <cc15d1fa-dd38-c01b-7a42-9eaf206d98a2@cumulusnetworks.com>
        <878tp6al2z.fsf@xmission.com>
        <e7875566-efa3-ba75-2699-3866a091615c@cumulusnetworks.com>
        <CALCETrVv_j56fq1q=OWt6wpk3JukQiBR6bTFRLw6t-7uvZEtPg@mail.gmail.com>
        <648b2f87-5345-5a47-f2a7-2a6461d7506b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto@amacapital.net>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tejun Heo <tj@kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:49626 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdBPDuM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 22:50:12 -0500
In-Reply-To: <648b2f87-5345-5a47-f2a7-2a6461d7506b@cumulusnetworks.com> (David
        Ahern's message of "Wed, 15 Feb 2017 20:35:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> writes:

> On 2/15/17 8:25 PM, Andy Lutomirski wrote:
>> On Wed, Feb 15, 2017 at 7:18 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
>>> On 2/15/17 8:08 PM, Eric W. Biederman wrote:
>>>> David Ahern <dsa@cumulusnetworks.com> writes:
>>>>
>>>>> On 2/14/17 12:21 AM, Eric W. Biederman wrote:
>>>>>>> in cases where bpf programs are looking at sockets and packets
>>>>>>> that belong to different netns, it could be useful to get an id
>>>>>>> that uniquely identify a netns within the whole system.
>>>>>> It could be useful but there is no unique namespace id.
>>>>>>
>>>>>
>>>>> Have you given thought to a unique namespace id? Networking tracepoints
>>>>> for example could really benefit from a unique id.
>>>>
>>>> An id from the perspective of a process in the initial instance of every
>>>> namespace is certainly possible.
>>>>
>>>> A truly unique id is just not maintainable.  Think of the question how
>>>> do you assign every device in the world a rguaranteed unique ip address
>>>> without coordination, that is routable.  It is essentially the same
>>>> problem.
>>>>
>>>> AKA it is theoretically possible and very expensive.  It is much easier
>>>> and much more maintainable for identifiers to have scope and only be
>>>> unique within that scope.
>>>
>>>
>>> I don't mean unique in the entire world, I mean unique within a single
>>> system.
>>>
>>> Tracepoints are code based and have global scope. I would like to be
>>> able to correlate, for example, FIB lookups within a single network
>>> namespace. Having an id that I could filter on when collecting or match
>>> when dumping them goes a long way.
>> 
>> Why wouldn't an id relative to your logging program work?  Global ids
>> are problematic because they are incompatible with tools like CRIU.
>> 
>
> How would that work?
>
> To be specific with an example, I only want FIB lookups for network
> namespace "foo". The name "foo" only has meaning for iproute2, so I need
> something the kernel understands. Should that be a dev/inode match
> meaning the tracepoints contain the netns dev and inode?
>
> From a perf perspective, the command line is like this:
>    perf record -e fib:fib_table_lookup --filter="netns_dev == 3 &&
> netns_ino == 4026531957" -a -g -- sleep 5
>
> Cumbersome, but it would work if the tracepoints had netns_dev and
> netns_ino as variables. A single id would be better.

A netns_dev_ino variable perhaps?  Something that you could pass a netns
file descriptor to perf and perf would just sort out the rest?

I believe those are just tooling issues.

The practical issue with one id that is global everywhere is that it has
to work for checkpoint/restart.   At which point it truly has to be
globably unique or namespaced.

Eric
