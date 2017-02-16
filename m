From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v4 net] bpf: add bpf_sk_netns_id() helper
Date: Wed, 15 Feb 2017 19:25:23 -0800
Message-ID: <CALCETrVv_j56fq1q=OWt6wpk3JukQiBR6bTFRLw6t-7uvZEtPg@mail.gmail.com>
References: <1486432968-3255218-1-git-send-email-ast@fb.com>
 <87h93xqlui.fsf@xmission.com> <cc15d1fa-dd38-c01b-7a42-9eaf206d98a2@cumulusnetworks.com>
 <878tp6al2z.fsf@xmission.com> <e7875566-efa3-ba75-2699-3866a091615c@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tejun Heo <tj@kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:32891 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753017AbdBPDZp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 22:25:45 -0500
Received: by mail-ua0-f171.google.com with SMTP id x12so3388097uax.0
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 19:25:45 -0800 (PST)
In-Reply-To: <e7875566-efa3-ba75-2699-3866a091615c@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 15, 2017 at 7:18 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/15/17 8:08 PM, Eric W. Biederman wrote:
>> David Ahern <dsa@cumulusnetworks.com> writes:
>>
>>> On 2/14/17 12:21 AM, Eric W. Biederman wrote:
>>>>> in cases where bpf programs are looking at sockets and packets
>>>>> that belong to different netns, it could be useful to get an id
>>>>> that uniquely identify a netns within the whole system.
>>>> It could be useful but there is no unique namespace id.
>>>>
>>>
>>> Have you given thought to a unique namespace id? Networking tracepoints
>>> for example could really benefit from a unique id.
>>
>> An id from the perspective of a process in the initial instance of every
>> namespace is certainly possible.
>>
>> A truly unique id is just not maintainable.  Think of the question how
>> do you assign every device in the world a rguaranteed unique ip address
>> without coordination, that is routable.  It is essentially the same
>> problem.
>>
>> AKA it is theoretically possible and very expensive.  It is much easier
>> and much more maintainable for identifiers to have scope and only be
>> unique within that scope.
>
>
> I don't mean unique in the entire world, I mean unique within a single
> system.
>
> Tracepoints are code based and have global scope. I would like to be
> able to correlate, for example, FIB lookups within a single network
> namespace. Having an id that I could filter on when collecting or match
> when dumping them goes a long way.

Why wouldn't an id relative to your logging program work?  Global ids
are problematic because they are incompatible with tools like CRIU.

-- 
Andy Lutomirski
AMA Capital Management, LLC
