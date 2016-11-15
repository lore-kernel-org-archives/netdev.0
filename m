From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 1/5] bpf: Refactor cgroups code in prep for
 new type
Date: Mon, 14 Nov 2016 18:23:17 -0800
Message-ID: <582A7195.60101@fb.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
 <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
 <20161031.125801.874510216543796824.davem@davemloft.net>
 <542e0d3e-2f57-96f9-1da1-b71e2c970395@zonque.org>
 <44b37825-d001-c708-963f-cbdedb559710@cumulusnetworks.com>
 <7d2a099d-1039-ef2d-86e6-2fca151d316c@zonque.org>
 <20161031174942.GF32374@pox.localdomain>
 <65b46edc-02bd-415c-4b1d-af36928d22da@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>, <maheshb@google.com>
To: David Ahern <dsa@cumulusnetworks.com>, Thomas Graf <tgraf@suug.ch>,
        "Daniel Mack" <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:59109 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754630AbcKOCXs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 21:23:48 -0500
In-Reply-To: <65b46edc-02bd-415c-4b1d-af36928d22da@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/13/16 7:51 PM, David Ahern wrote:
> On 10/31/16 11:49 AM, Thomas Graf wrote:
>> On 10/31/16 at 06:16pm, Daniel Mack wrote:
>>> On 10/31/2016 06:05 PM, David Ahern wrote:
>>>> On 10/31/16 11:00 AM, Daniel Mack wrote:
>>>>> Yeah, I'm confused too. I changed that name in my v7 from
>>>>> BPF_PROG_TYPE_CGROUP_SOCK to BPF_PROG_TYPE_CGROUP_SKB on David's
>>>>> (Ahern) request. Why is it now renamed again?
>>>>
>>>> Thomas pushed back on adding another program type in favor of using
>>>> subtypes. So this makes the program type generic to CGROUP and patch
>>>> 2 in this v2 set added Mickaël's subtype patch with the socket
>>>> mangling done that way in patch 3.
>>>>
>>>
>>> Fine for me. I can change it around again.
>>
>> I would like to hear from Daniel B and Alexei as well. We need to
>> decide whether to use subtypes consistently and treat prog types as
>> something more high level or whether to bluntly introduce a new prog
>> type for every distinct set of verifier limits. I will change lwt_bpf
>> as well accordingly.
>>
>
> Alexei / Daniel - any comments/preferences on subtypes vs program types?

looks like in this particular case it's better to use different program
types, since they all serve different purpose and context is different.
Daniel Mack's programs can stay BPF_PROG_TYPE_CGROUP_SKB and operate on 
skb, whereas your ifindex changing programs can be 
BPF_PROG_TYPE_CGROUP_SOCK.

regarding DanielM's patches.. Dave's comment regarding skb->sk vs sk
made us think hard about it. We looked into tunnels and at the end
realized that skb->sk won't fly, since the program will be called
multiple times on tx for every ip_output. And since we were not sure
that using 'sk' will fix it, we had to do a bunch of tests with
different tunnels and analyze the code to make sure it's all good.
We'll repost soon.
