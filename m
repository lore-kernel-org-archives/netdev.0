From: David Miller <davem@davemloft.net>
Subject: Re: hmmm...
Date: Tue, 25 Apr 2017 23:38:20 -0400 (EDT)
Message-ID: <20170425.233820.1357836307906136732.davem@davemloft.net>
References: <20170425.215232.727894789143301373.davem@davemloft.net>
        <af3781d2-f8af-1c6e-b3a0-163d8c1de75a@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48684 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1430753AbdDZDiY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 23:38:24 -0400
In-Reply-To: <af3781d2-f8af-1c6e-b3a0-163d8c1de75a@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 25 Apr 2017 19:56:06 -0700

> On 4/25/17 6:52 PM, David Miller wrote:
>>
>> Alexei, I found something strange on my computer :-)
>>
>> [davem@localhost binutils]$ ./objdump -d x.o
> 
> No way! :) I thought it will take weeks!
> Ship it. Ship it. Ship it.
> Cannot wait to pull.
> This is awesome. Thanks a ton!

Relax, it is in a very raw state still. :)

> What is the mnemonic for 32-bit alu ?

It is of the form "xxx32".  Here is opcodes table below.

I think there are no formal mnenomics defined anywhere yet right?
So just tell me what adjustments you want to make.

#include "sysdep.h"
#include <stdio.h>
#include "opcode/bpf.h"

#define BPF_OPC_ALU64	0x07
#define BPF_OPC_DW	0x18
#define BPF_OPC_XADD	0xc0
#define BPF_OPC_MOV	0xb0
#define BPF_OPC_ARSH	0xc0
#define BPF_OPC_END	0xd0
#define BPF_OPC_TO_LE	0x00
#define BPF_OPC_TO_BE	0x08
#define BPF_OPC_JNE	0x50
#define BPF_OPC_JSGT	0x60
#define BPF_OPC_JSGE	0x70
#define BPF_OPC_CALL	0x80
#define BPF_OPC_EXIT	0x90

#define BPF_OPC_LD	0x00
#define BPF_OPC_LDX	0x01
#define BPF_OPC_ST	0x02
#define BPF_OPC_STX	0x03
#define BPF_OPC_ALU	0x04
#define BPF_OPC_JMP	0x05
#define BPF_OPC_RET	0x06
#define BPF_OPC_MISC	0x07

#define BPF_OPC_W	0x00
#define BPF_OPC_H	0x08
#define BPF_OPC_B	0x10

#define BPF_OPC_IMM	0x00
#define BPF_OPC_ABS	0x20
#define BPF_OPC_IND	0x40
#define BPF_OPC_MEM	0x60
#define BPF_OPC_LEL	0x80
#define BPF_OPC_MSH	0xa0

#define BPF_OPC_ADD	0x00
#define BPF_OPC_SUB	0x10
#define BPF_OPC_MUL	0x20
#define BPF_OPC_DIV	0x30
#define BPF_OPC_OR	0x40
#define BPF_OPC_AND	0x50
#define BPF_OPC_LSH	0x60
#define BPF_OPC_RSH	0x70
#define BPF_OPC_NEG	0x80
#define BPF_OPC_MOD	0x90
#define BPF_OPC_XOR	0xa0

#define BPF_OPC_JA	0x00
#define BPF_OPC_JEQ	0x10
#define BPF_OPC_JGT	0x20
#define BPF_OPC_JGE	0x30
#define BPF_OPC_JSET	0x40

#define BPF_OPC_K	0x00
#define BPF_OPC_X	0x08

const struct bpf_opcode bpf_opcodes[] = {
  { "mov32",   BPF_OPC_ALU   | BPF_OPC_MOV  | BPF_OPC_X,     "1,2" },
  { "mov",     BPF_OPC_ALU64 | BPF_OPC_MOV  | BPF_OPC_X,     "1,2" },
  { "add32",   BPF_OPC_ALU   | BPF_OPC_ADD  | BPF_OPC_X,     "1,2" },
  { "add",     BPF_OPC_ALU64 | BPF_OPC_ADD  | BPF_OPC_X,     "1,2" },
  { "sub32",   BPF_OPC_ALU   | BPF_OPC_SUB  | BPF_OPC_X,     "1,2" },
  { "sub",     BPF_OPC_ALU64 | BPF_OPC_SUB  | BPF_OPC_X,     "1,2" },
  { "and32",   BPF_OPC_ALU   | BPF_OPC_AND  | BPF_OPC_X,     "1,2" },
  { "and",     BPF_OPC_ALU64 | BPF_OPC_AND  | BPF_OPC_X,     "1,2" },
  { "or32",    BPF_OPC_ALU   | BPF_OPC_OR   | BPF_OPC_X,     "1,2" },
  { "or",      BPF_OPC_ALU64 | BPF_OPC_OR   | BPF_OPC_X,     "1,2" },
  { "xor32",   BPF_OPC_ALU   | BPF_OPC_XOR  | BPF_OPC_X,     "1,2" },
  { "xor",     BPF_OPC_ALU64 | BPF_OPC_XOR  | BPF_OPC_X,     "1,2" },
  { "mul32",   BPF_OPC_ALU   | BPF_OPC_MUL  | BPF_OPC_X,     "1,2" },
  { "mul",     BPF_OPC_ALU64 | BPF_OPC_MUL  | BPF_OPC_X,     "1,2" },
  { "div32",   BPF_OPC_ALU   | BPF_OPC_DIV  | BPF_OPC_X,     "1,2" },
  { "div",     BPF_OPC_ALU64 | BPF_OPC_DIV  | BPF_OPC_X,     "1,2" },
  { "mod32",   BPF_OPC_ALU   | BPF_OPC_MOD  | BPF_OPC_X,     "1,2" },
  { "mod",     BPF_OPC_ALU64 | BPF_OPC_MOD  | BPF_OPC_X,     "1,2" },
  { "lsh32",   BPF_OPC_ALU   | BPF_OPC_LSH  | BPF_OPC_X,     "1,2" },
  { "lsh",     BPF_OPC_ALU64 | BPF_OPC_LSH  | BPF_OPC_X,     "1,2" },
  { "rsh32",   BPF_OPC_ALU   | BPF_OPC_RSH  | BPF_OPC_X,     "1,2" },
  { "rsh",     BPF_OPC_ALU64 | BPF_OPC_RSH  | BPF_OPC_X,     "1,2" },
  { "arsh32",  BPF_OPC_ALU   | BPF_OPC_ARSH | BPF_OPC_X,     "1,2" },
  { "arsh",    BPF_OPC_ALU64 | BPF_OPC_ARSH | BPF_OPC_X,     "1,2" },
  { "neg32",   BPF_OPC_ALU   | BPF_OPC_NEG  | BPF_OPC_X,     "1" },
  { "neg",     BPF_OPC_ALU64 | BPF_OPC_NEG  | BPF_OPC_X,     "1" },
  { "endbe",   BPF_OPC_ALU   | BPF_OPC_END  | BPF_OPC_TO_BE, "1,i" },
  { "endle",   BPF_OPC_ALU   | BPF_OPC_END  | BPF_OPC_TO_LE, "1,i" },
  { "mov32",   BPF_OPC_ALU   | BPF_OPC_MOV  | BPF_OPC_K,     "1,i" },
  { "mov",     BPF_OPC_ALU64 | BPF_OPC_MOV  | BPF_OPC_K,     "1,i" },
  { "add32",   BPF_OPC_ALU   | BPF_OPC_ADD  | BPF_OPC_K,     "1,i" },
  { "add",     BPF_OPC_ALU64 | BPF_OPC_ADD  | BPF_OPC_K,     "1,i" },
  { "sub32",   BPF_OPC_ALU   | BPF_OPC_SUB  | BPF_OPC_K,     "1,i" },
  { "sub",     BPF_OPC_ALU64 | BPF_OPC_SUB  | BPF_OPC_K,     "1,i" },
  { "and32",   BPF_OPC_ALU   | BPF_OPC_AND  | BPF_OPC_K,     "1,i" },
  { "and",     BPF_OPC_ALU64 | BPF_OPC_AND  | BPF_OPC_K,     "1,i" },
  { "or32",    BPF_OPC_ALU   | BPF_OPC_XOR  | BPF_OPC_K,     "1,i" },
  { "or",      BPF_OPC_ALU64 | BPF_OPC_XOR  | BPF_OPC_K,     "1,i" },
  { "xor32",   BPF_OPC_ALU   | BPF_OPC_OR   | BPF_OPC_K,     "1,i" },
  { "xor",     BPF_OPC_ALU64 | BPF_OPC_OR   | BPF_OPC_K,     "1,i" },
  { "mul32",   BPF_OPC_ALU   | BPF_OPC_MUL  | BPF_OPC_K,     "1,i" },
  { "mul",     BPF_OPC_ALU64 | BPF_OPC_MUL  | BPF_OPC_K,     "1,i" },
  { "div32",   BPF_OPC_ALU   | BPF_OPC_DIV  | BPF_OPC_K,     "1,i" },
  { "div",     BPF_OPC_ALU64 | BPF_OPC_DIV  | BPF_OPC_K,     "1,i" },
  { "mod32",   BPF_OPC_ALU   | BPF_OPC_MOD  | BPF_OPC_K,     "1,i" },
  { "mod",     BPF_OPC_ALU64 | BPF_OPC_MOD  | BPF_OPC_K,     "1,i" },
  { "lsh32",   BPF_OPC_ALU   | BPF_OPC_LSH  | BPF_OPC_K,     "1,i" },
  { "lsh",     BPF_OPC_ALU64 | BPF_OPC_LSH  | BPF_OPC_K,     "1,i" },
  { "rsh32",   BPF_OPC_ALU   | BPF_OPC_RSH  | BPF_OPC_K,     "1,i" },
  { "rsh",     BPF_OPC_ALU64 | BPF_OPC_RSH  | BPF_OPC_K,     "1,i" },
  { "arsh32",  BPF_OPC_ALU   | BPF_OPC_ARSH | BPF_OPC_K,     "1,i" },
  { "arsh",    BPF_OPC_ALU64 | BPF_OPC_ARSH | BPF_OPC_K,     "1,i" },
  { "ja",      BPF_OPC_JMP   | BPF_OPC_JA,                   "L" },
  { "jeq",     BPF_OPC_JMP   | BPF_OPC_JEQ  | BPF_OPC_X,     "1,2,L" },
  { "jgt",     BPF_OPC_JMP   | BPF_OPC_JGT  | BPF_OPC_X,     "1,2,L" },
  { "jge",     BPF_OPC_JMP   | BPF_OPC_JGE  | BPF_OPC_X,     "1,2,L" },
  { "jne",     BPF_OPC_JMP   | BPF_OPC_JNE  | BPF_OPC_X,     "1,2,L" },
  { "jsgt",    BPF_OPC_JMP   | BPF_OPC_JSGT | BPF_OPC_X,     "1,2,L" },
  { "jsge",    BPF_OPC_JMP   | BPF_OPC_JSGE | BPF_OPC_X,     "1,2,L" },
  { "jset",    BPF_OPC_JMP   | BPF_OPC_JSET | BPF_OPC_X,     "1,2,L" },
  { "jeq",     BPF_OPC_JMP   | BPF_OPC_JEQ  | BPF_OPC_K,     "1,i,L" },
  { "jgt",     BPF_OPC_JMP   | BPF_OPC_JGT  | BPF_OPC_K,     "1,i,L" },
  { "jge",     BPF_OPC_JMP   | BPF_OPC_JGE  | BPF_OPC_K,     "1,i,L" },
  { "jne",     BPF_OPC_JMP   | BPF_OPC_JNE  | BPF_OPC_K,     "1,i,L" },
  { "jsgt",    BPF_OPC_JMP   | BPF_OPC_JSGT | BPF_OPC_K,     "1,i,L" },
  { "jsge",    BPF_OPC_JMP   | BPF_OPC_JSGE | BPF_OPC_K,     "1,i,L" },
  { "jset",    BPF_OPC_JMP   | BPF_OPC_JSET | BPF_OPC_K,     "1,i,L" },
  { "call",    BPF_OPC_JMP   | BPF_OPC_CALL,                 "C" },
  { "tailcall",BPF_OPC_JMP   | BPF_OPC_CALL | BPF_OPC_X,     "C" },
  { "exit",    BPF_OPC_JMP   | BPF_OPC_EXIT,                 "" },
  { "ldimm64", BPF_OPC_LD    | BPF_OPC_IMM  | BPF_OPC_DW,    "1,D" },
  { "ldxw",    BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_W,     "1,[2+O]" },
  { "ldxh",    BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_H,     "1,[2+O]" },
  { "ldxb",    BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_B,     "1,[2+O]" },
  { "ldxdw",   BPF_OPC_LDX   | BPF_OPC_MEM  | BPF_OPC_DW,    "1,[2+O]" },
  { "stw",     BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_W,     "[1+O],i" },
  { "sth",     BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_H,     "[1+O],i" },
  { "stb",     BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_B,     "[1+O],i" },
  { "stdw",    BPF_OPC_ST    | BPF_OPC_MEM  | BPF_OPC_DW,    "[1+O],i" },
  { "stw",     BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_W,     "[1+O],2" },
  { "sth",     BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_H,     "[1+O],2" },
  { "stb",     BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_B,     "[1+O],2" },
  { "stdw",    BPF_OPC_STX   | BPF_OPC_MEM  | BPF_OPC_DW,    "[1+O],2" },
  { "xaddw",   BPF_OPC_STX   | BPF_OPC_XADD | BPF_OPC_W,     "[1+O],2" },
  { "xadddw",  BPF_OPC_STX   | BPF_OPC_XADD | BPF_OPC_DW,    "[1+O],2" },
};
const int bpf_num_opcodes = ((sizeof bpf_opcodes)/(sizeof bpf_opcodes[0]));
