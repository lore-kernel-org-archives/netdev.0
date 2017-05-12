From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] selftests/bpf: get rid of -D__x86_64__
Date: Thu, 11 May 2017 22:07:04 -0700
Message-ID: <0aab1aec-814c-e496-4254-ca33a81f8c7f@fb.com>
References: <5d1d290b-7ff7-7f9d-15a0-599596e0778c@fb.com>
 <20170511.150246.650724054596949813.davem@davemloft.net>
 <9afe8b73-806c-1511-dd26-f09e67b85107@fb.com>
 <20170511.212940.1950696136811799858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45800 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755605AbdELFH1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 01:07:27 -0400
In-Reply-To: <20170511.212940.1950696136811799858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/17 6:29 PM, David Miller wrote:
> This whole thing go me thinking however.  What do you expect to happen
> on 32-bit architectures implementing an eBPF JIT?

I doubt any 32-bit cpu architectures will do JIT in the near future.
Doing 64-bit operations everywhere is too painful in assembler.
HW offloading is a different story. Like nfp has 32-bit registers
and everything 64-bit in bpf is not the ideal for them.
For such cases the idea is to teach verifier to recognize that
registers don't use upper 32-bits and mark them, so JITs can be
more efficient.

> That's going to
> create some serious conflicts and consternation wrt.  tracing which is
> going to want to use headers which are for sizeof(void *)==4 whereas
> for eBPF natively it's 8.

that is indeed a problem. The bpf tracing approach that includes
kernel headers mostly doesn't work on 32-bit archs, though
few iovisor/bcc scripts should be functional. Those that don't
walk pointers and relying on tracepoints instead.
