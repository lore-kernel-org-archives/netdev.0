From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [patch net-next] tc: add BPF based action
Date: Thu, 8 Jan 2015 11:04:31 -0800
Message-ID: <CAMEtUuzjdd55JrK2oJFRHFVAmogwM-tK8dKxidoRpG=SrFs4bA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, jhs@mojatatu.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f177.google.com ([209.85.216.177]:47119 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752041AbbAHTEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 14:04:53 -0500
Received: by mail-qc0-f177.google.com with SMTP id x3so3852324qcv.8
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 11:04:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 7, 2015 at 11:26 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>On the other hand, I would understand if it's at some point in
>>time eBPF which would f.e. mangle the packet, but the API you
>>propose is clearly classic BPF. ;)
>
> Exactly. I would like to extend cls_bpf and act_bpf to handle eBPF right
> after. That is the point.

I say that connecting it with classic BPF is not a prerequisite
to use eBPF in there. Invocation place may be the same,
but the way to pass the program will be different.
For classic with just pass the whole program, whereas
for eBPF we'll be likely passing fd.
Theoretically we can pass eBPF as vanilla program
as well that doesn't have map access, but verifier check
will only be binary (accept or reject). Which is not user
friendly. Even rejection of classic BPF is hard to decipher.
Especially when only language for classic is assembler
and poor users have no easy way to know what was
wrong with the program. Therefore I like bpf syscall
as a main and only interface to load the programs
and pass prog_fd to places where they suppose to run.
Having syscall as center place to load programs
also helps with accounting, since root will be able
to do something like 'lsmod' to see all loaded programs.
Anyway, that's a conversion for later...

As Daniel pointed out I think some better articulation
on what classic bpf programs will do here is needed.
It seems they will work as pre-filter on an action?
Few examples would help to understand use cases...
