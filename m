From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Fri, 5 May 2017 11:24:19 -0700
Message-ID: <bf3b6bde-d159-c6a3-a532-83cccb1833d9@fb.com>
References: <20170430.120750.651845251226226775.davem@davemloft.net>
 <33505cff-f730-ebac-c2d7-38f1793062b7@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
        <xdp-newbies@vger.kernel.org>, Yonghong Song <yhs@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35085 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751163AbdEESYs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 14:24:48 -0400
In-Reply-To: <33505cff-f730-ebac-c2d7-38f1793062b7@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/1/17 8:49 PM, Alexei Starovoitov wrote:
> On 4/30/17 9:07 AM, David Miller wrote:
>> This is mainly a synchronization point, I still need to look
>> more deeply into Alexei's -g issue.
>>
>> New in this version from v3:
>>  - Remove tailcall from opcode table
>>  - Rearrange relocations so that numbers match with LLVM ones
>>  - Emit relocs properly so that dwarf2 debug info tests pass
>>  - Handle negative load/store offsets properly, add tests
>>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>
> dwarf on little endian works now :)

Yonghong fixed llvm bug with big-endian dwarf [1]
and binutils worked out of the box :)

$ ./bin/clang -O2 -target bpfeb -c -g test.c
$ /w/binutils-gdb/bld/binutils/objdump -S test.o

test.o:     file format elf64-bpfbe

Disassembly of section .text:
0000000000000000 <bpf_prog1>:
int bpf_prog1(void *ign)
{
   volatile unsigned long t = 0x8983984739ull;
    0:	18 10 00 00 83 98 47 39 	ldimm64	r1, 590618314553
    8:	00 00 00 00 00 00 00 89
   10:	7b a1 ff f8 00 00 00 00 	stdw	[r10+-8], r1
   return *(unsigned long *)((0xffffffff8fff0002ull) + t);
   18:	79 1a ff f8 00 00 00 00 	lddw	r1, [r10+-8]

[1]
https://reviews.llvm.org/rL302265
