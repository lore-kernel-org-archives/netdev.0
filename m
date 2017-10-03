From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/8] bpf: multi program support for cgroup+bpf
Date: Mon, 2 Oct 2017 22:00:15 -0700
Message-ID: <f10e3c83-b73d-6f04-7c66-b01fab1f5a1a@fb.com>
References: <20171002234857.3707580-1-ast@fb.com>
 <20171002234857.3707580-2-ast@fb.com>
 <71bda584-d828-7472-7655-85a454dbe297@cumulusnetworks.com>
 <f5d34464-42a9-b51b-edc4-06c44b3c4845@fb.com>
 <1211d4c0-b812-af08-cbd4-72eb9259ee78@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Ahern <dsa@cumulusnetworks.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58290 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750735AbdJCFAg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 01:00:36 -0400
In-Reply-To: <1211d4c0-b812-af08-cbd4-72eb9259ee78@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/17 9:26 PM, David Ahern wrote:
> On 10/2/17 9:21 PM, Alexei Starovoitov wrote:
>>
>> i'm not sure what you're trying to say.
>> The first loop quoted above is inside cgroup_bpf_put()
>> which is called when cgroup is destroyed. At this point
>> we're detaching and prog_put all attached programs.
>> While there is only one static_branch_inc() in __cgroup_bpf_attach()
>> that is called every time the prog is attached to a cgroup.
>> So what's the concern?
>
> just asking if cgroup_bpf_enabled_key is 0 when all programs are removed
> -- ie., that the inc's and dec's are equal. Reviewing this patch it was
> not clear that they are.

after some debugging turned out there is a typo in attach code
that leaks prog in the case of override.
Strangely kmemleak didn't catch it.
Will respin.
