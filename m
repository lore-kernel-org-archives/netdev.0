From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [RFC PATCH net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Fri, 10 Feb 2017 18:34:04 -0800
Message-ID: <589E781C.3040909@fb.com>
References: <1486666763-2698065-1-git-send-email-ast@fb.com>
 <CALCETrVjLP+p1mk92h=Xy6EfQdC-dbYwzwHf_sCNzKNb8jeY-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58131 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752503AbdBKCeh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 21:34:37 -0500
In-Reply-To: <CALCETrVjLP+p1mk92h=Xy6EfQdC-dbYwzwHf_sCNzKNb8jeY-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/10/17 1:38 PM, Andy Lutomirski wrote:
> On Thu, Feb 9, 2017 at 10:59 AM, Alexei Starovoitov <ast@fb.com> wrote:
>> If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
>> to the given cgroup the descendent cgroup will be able to override
>> effective bpf program that was inherited from this cgroup.
>> By default it's not passed, therefore override is disallowed.
>>
>> Examples:
>> 1.
>> prog X attached to /A with default
>> prog Y fails to attach to /A/B and /A/B/C
>> Everything under /A runs prog X
>>
>> 2.
>> prog X attached to /A with ALLOW_OVERRIDE
>> prog Y attached to /A/B with default. Everything under /A/B runs prog Y
>
> I think that, for ease of future extension, Y should also need
> ALLOW_OVERRIDE.  Otherwise, when non-overridable hooks can stack,
> there could be confusion as to whether Y should override something or
> should stack.

I see. Fair enough. It's indeed easier for future extensions.

>> 2.
>> we can add another flag to reverse this call order too.
>> Instead of calling the progs from child to parent, do parent to child.
>
> I think the order should depend on the hook.  Hooks for
> process-initiated actions (egress, socket creation) should run
> innermost first and hooks for outside actions (ingress) should be
> outermost first.

There are use cases where both ingress and egress
would want both ordering. Like the monitoring would want to
see the bytes that app wants to send and it would want
to see the bytes that it's actually sending. So if something
in the middle wants to drop due to whatever conditions,
the monitoring needs to be the first and the last in the prog chain.
That's one of the use cases for 'attach_priority'.
Some high priority can be reserved for debugging and so on.

>> Andy,
>> does it all make sense?
>
> Yes with the caveat above.

great!

>> Do you still insist on submitting this patch officially?
>
> I'm not sure what you mean.

it's an RFC. In netdev we never apply rfc patches.

>> or you're ok keeping it overridable for now.
>
> I really think the default should change for 4.10.  People are going

fine. will respin with requested change.
