From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Sun, 30 Apr 2017 11:28:50 -0400 (EDT)
Message-ID: <20170430.112850.863051989089519000.davem@davemloft.net>
References: <20170429.222450.1300920007783667009.davem@davemloft.net>
        <20170429.223759.1262491011130998405.davem@davemloft.net>
        <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753525AbdD3P2v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 11:28:51 -0400
In-Reply-To: <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Sat, 29 Apr 2017 23:44:59 -0700

> On 4/29/17 7:37 PM, David Miller wrote:
>> From: David Miller <davem@davemloft.net>
>> Date: Sat, 29 Apr 2017 22:24:50 -0400 (EDT)
>>
>>> Some of your bugs should be fixed by this patch below, I'll add
>>> test cases soon:
>>
>> Ok, here are all the local changes in my tree.  I made the relocs
>> match LLVM and I fixed some dwarf debugging stuff.
>>
>> With this we are also down to one test case failure under binutils/
>> and it's something weird with merging 64-bit notes which I should be
>> able to fix soon.
>>
>> I can fix these bugs fast, keep reporting.
>>
>> BTW, should I just remove tailcall from the opcode table altogether?
> 
> yeah. tailcall is not a special opcode from user space point of view.
> Only after normal call with func_id=bpf_tail_call passes verifier
> then verifier will change insn->code into CALL|X
> It's done only to have two 'case' statement in the interpreter,
> so that normal calls and tailcalls don't interfere.
> From user space pov CALL|X opcode is reserved and we can use it
> for something in the future. Just need to change interpeter and JITs.
> 
>>  	    case 'O':
>> -	      (*info->fprintf_func) (stream, "%d", off);
>> +	      (*info->fprintf_func) (stream, "%d", (int) off);
> 
> tried this diff. It looks better
>   10:	7b 1a f8 ff 00 00 00 00 	stdw	[r1+-8], r10
>   18:	79 a1 f8 ff 00 00 00 00 	lddw	r10, [r1+-8]
> I wonder if '+' can be removed as well.

All disassemblers in binutils print it this way, sparc, x86, etc.

> '-g' still doesn't seem to work:
> /w/binutils-gdb/bld/binutils/objdump: invalid relocation type 10
> /w/binutils-gdb/bld/binutils/objdump: BFD (GNU Binutils)
> 2.28.51.20170429 assertion fail ../../bfd/elf64-bpf.c:139
>    0:	18 01 00 00 39 47 98 83 	ldimm64	r0, 590618314553

Hmm, I defined a relocation type 10 in the patch, make sure BFD got
rebuilt properly...

I'll double check here too.
