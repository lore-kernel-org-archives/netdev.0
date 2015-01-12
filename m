From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Mon, 12 Jan 2015 11:52:46 +0100
Message-ID: <20150112105246.GC1873@nanopsycho.orion>
References: <CAMEtUuzjdd55JrK2oJFRHFVAmogwM-tK8dKxidoRpG=SrFs4bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, jhs@mojatatu.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:48570 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbALKws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 05:52:48 -0500
Received: by mail-wg0-f45.google.com with SMTP id y19so2390496wgg.4
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 02:52:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAMEtUuzjdd55JrK2oJFRHFVAmogwM-tK8dKxidoRpG=SrFs4bA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Jan 08, 2015 at 08:04:31PM CET, ast@plumgrid.com wrote:
>On Wed, Jan 7, 2015 at 11:26 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>
>>>On the other hand, I would understand if it's at some point in
>>>time eBPF which would f.e. mangle the packet, but the API you
>>>propose is clearly classic BPF. ;)
>>
>> Exactly. I would like to extend cls_bpf and act_bpf to handle eBPF right
>> after. That is the point.
>
>I say that connecting it with classic BPF is not a prerequisite
>to use eBPF in there. Invocation place may be the same,
>but the way to pass the program will be different.
>For classic with just pass the whole program, whereas
>for eBPF we'll be likely passing fd.
>Theoretically we can pass eBPF as vanilla program
>as well that doesn't have map access, but verifier check
>will only be binary (accept or reject). Which is not user
>friendly. Even rejection of classic BPF is hard to decipher.
>Especially when only language for classic is assembler
>and poor users have no easy way to know what was
>wrong with the program. Therefore I like bpf syscall
>as a main and only interface to load the programs
>and pass prog_fd to places where they suppose to run.
>Having syscall as center place to load programs
>also helps with accounting, since root will be able
>to do something like 'lsmod' to see all loaded programs.
>Anyway, that's a conversion for later...
>
>As Daniel pointed out I think some better articulation
>on what classic bpf programs will do here is needed.
>It seems they will work as pre-filter on an action?
>Few examples would help to understand use cases...

Well, one can define bpf action to do final policy in tc pipeline if
skb should be dropped or not. I'm aware that this is in theory doable by
cls_bpf, but oftentimes one likes to use different cls.

And also, the plan is to extend this for ebpf in near future, as well
as cls_bpf. That will provide many more possibilities for user.

The intention here is to keep cls_bpf and act_bpf feature-consistent.

Thanks.

Jiri
