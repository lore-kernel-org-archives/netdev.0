From: Alexei Starovoitov <ast@fb.com>
Subject: Re: BPF relocations
Date: Thu, 11 May 2017 16:10:35 -0700
Message-ID: <b39b79d6-4fe2-f887-dc7e-03b62d6eb3e4@fb.com>
References: <20170511.153118.2082025756694634804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:34825 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756232AbdEKXLA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 19:11:00 -0400
In-Reply-To: <20170511.153118.2082025756694634804.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/11/17 12:31 PM, David Miller wrote:
>
> I haven't done more work on bintuils BPF support because we
> need to figure out exactly what to do with relocations.  So
> I've been trying to spend time thinking about this.
>
> As far as I can tell the 64-bit BPF relocation llvm uses
> is used in two situations:
>
> 1) 64-bit relocations against data
>
> 2) 64-bit relocations against ldimm64 instructions
>
> If this is true it's a very bad decision that has ramifications for us
> right now.
>
> One must always explicitly define relocations as being against data or
> instruction fields.  You cannot use the same relocation for both kinds
> of transformations, somehow trying to figure out what to do
> "contextually".  That doesn't work.

why it doesn't work?
as far as i can see x86 doesn't care where the relo applies.
afaik relocations are divided into absolute, pc relative and pic 
relative and it doesn't matter whether they're against .text,
.eh_frame or .debug_* sections.

We have just two so far: absolute 32-bit and absolute 64-bit relocation.
I don't see what we would use pc-relative relo for.

If I remember correctly, the x64 and other cpus use pc-relative for
'call foo' insns since this is how those instructions work.
We don't have such calls yet.
