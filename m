From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] bpf: split eBPF out of NET
Date: Mon, 27 Oct 2014 17:18:36 -0700
Message-ID: <CAMEtUux7q93hD7xr+DUDk3btYR+A7NXEMcu6YVWAHSNuLUhNJA@mail.gmail.com>
References: <1414114868-28228-1-git-send-email-ast@plumgrid.com>
	<20141027.191043.246099210901442100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Josh Triplett <josh@joshtriplett.org>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37125 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753174AbaJ1ASi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 20:18:38 -0400
Received: by mail-wi0-f178.google.com with SMTP id q5so96908wiv.11
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 17:18:36 -0700 (PDT)
In-Reply-To: <20141027.191043.246099210901442100.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2014 at 4:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Thu, 23 Oct 2014 18:41:08 -0700
>
>> introduce two configs:
>> - hidden CONFIG_BPF to select eBPF interpreter that classic socket filters
>>   depend on
>> - visible CONFIG_BPF_SYSCALL (default off) that tracing and sockets can use
>>
>> that solves several problems:
>> - tracing and others that wish to use eBPF don't need to depend on NET.
>>   They can use BPF_SYSCALL to allow loading from userspace or select BPF
>>   to use it directly from kernel in NET-less configs.
>> - in 3.18 programs cannot be attached to events yet, so don't force it on
>> - when the rest of eBPF infra is there in 3.19+, it's still useful to
>>   switch it off to minimize kernel size
>>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>> ---
>>
>> bloat-o-meter on x64 shows:
>> add/remove: 0/60 grow/shrink: 0/2 up/down: 0/-15601 (-15601)
>>
>> tested with many different config combinations. Hopefully didn't miss anything.
>
> Applied with two changes:
>
> 1) boolean --> bool
> 2) Moved bloat-o-meter and testing information into commit message.
>
> Thanks.

Thank you for taking care of it!
