From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Thu, 1 Jun 2017 11:27:56 -0700
Message-ID: <cae83d5f-85ea-4c16-5f6b-2b71f0768b05@fb.com>
References: <cover.1496256722.git.kafai@fb.com>
 <20170531192256.0e0d0ce1@cakuba.lan>
 <3f269312-efd4-86fc-e8e2-814af5898648@gmail.com>
 <6ab73989-6246-ba15-7178-7863a110165c@fb.com>
 <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>,
        <kernel-team@fb.com>
To: David Ahern <dsahern@gmail.com>, Jakub Kicinski <kubakici@wp.pl>,
        Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46964 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751130AbdFAS2X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 14:28:23 -0400
In-Reply-To: <18d3c571-7434-eaea-43dc-d237712309d1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/1/17 10:51 AM, David Ahern wrote:
> On 6/1/17 11:24 AM, Alexei Starovoitov wrote:
>>
>> what problem are we trying to solve?
>> If we don't agree on the problem, we won't be able to agree on the
>> solution.
>
> I want the ability to retrieve the BPF instructions pushed to the
> kernel. Not just for cgroups and VRF, but everywhere - cgroups, sockets,
> xdp, filters, etc. I have this stated many times, including to you at
> netconf in April. From that discussion and the discussion on the RFC
> patch I sent in February, I thought we had an agreement that saving the
> instructions was the first step.
>
> Quentin at 6wind has expressed a similar interest for cls_bpf and
> act_bpf code.
>
> I read Jakub's email as wanting the same but for XDP.
>
> The patches I referenced earlier save the original instructions and
> enable them to be read by userspace from an fd return by the bpf
> syscall. Combine that with the ID and we have a solution.

Please explain the problem instead of pushing for 'solution'.
In this case I do not see a problem that saving original instructions
will solve.

'I want to retrieve original instructions' is not a problem. It's a
push for 'solution'. Explaining 'why' you want to see original
instructions would describe the actual problem.
If you're trying to debug something you're interested in original
source code and in the instructions that kernel is running.
To correlate to source code we have prog_tag (that was computed
over original insns).
To see kernel instructions in the interpreter and JITed assembler
we have this set of patches.
Original instructions are not useful for debugging,
since they have map_fds which can be long gone when program
is running, therefore to solve introspection problem we need to
look into real kernel instructions.

My understanding that 6wind wants to see original instructions to
accelerate them somehow using out of tree technology.
I'm not interested to help that cause. I also suspect that
retrieving kernel instructions will not be much different from
that point of view, but at least returning kernel insns is
solving introspection problem for everyone.

Returning kernel insns also doesn't burn unnecessary memory,
whereas original insns will be there as dead weight.
Hence before we add them we need to be absolutely clear that
there is no cheaper alternative possible.
