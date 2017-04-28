From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v2 binutils] Add BPF support to binutils...
Date: Fri, 28 Apr 2017 11:57:36 -0400
Message-ID: <f7td1bwtthr.fsf@redhat.com>
References: <20170427.170934.891283291562287326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35420 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2997268AbdD1P5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 11:57:40 -0400
Received: by mail-qk0-f196.google.com with SMTP id a19so9507254qkg.2
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 08:57:40 -0700 (PDT)
In-Reply-To: <20170427.170934.891283291562287326.davem@davemloft.net> (David
        Miller's message of "Thu, 27 Apr 2017 17:09:34 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller <davem@davemloft.net> writes:

> Here is what I have after today's work.  I think I sorted out the
> endianness issues.
>
> gas can be controlled explicitly using "-EB" and "-EL" options.  The
> default is whatever endianness the host has.  The elf names for the
> two variants are "elf64-bpfbe" and "elf64-bpfle".
>
> I fleshed out all the rest of the assembler parsing for instructions
> and added many entries to the gas testsuite.
>
> They are all explicitly in little endian, although I should add big
> endian versions too of course.
>
> If someone is looking for a way to help, could you please verify the
> testsuite output to make sure the opcode and fields are correctly
> set in the testsuite.  Just look in:
>
> 	gas/testsuite/gas/bpf/
>
> and there are two files for every test.  One is the "foo.s" file which
> gets built using gas into an object file "foo.o".  Then there is a
> dump file named "foo.d" which specifies optionally how to run gas and
> with what options, and then what to dump with (usually "objdump -dr")
> then there is text which the testsuite compares with the dump of
> the resulting "foo.o" file.
>
> The testsuite is driven by bpf.exp which has pretty straightforward
> syntax.
>
> Anyways, enjoy.  I'll keep cracking on this tomorrow.

I'll get an arm board up and running to do some testing there.  As a
teaser:

  Test run by aconole on Fri Apr 28 11:52:18 2017
  Target is bpf-linux-elf
  Host   is x86_64-pc-linux-gnu

  		=== gas tests ===

  ...
  Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/bfin/error.exp ...
  Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/bpf/bpf.exp ...
  Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/cfi/cfi.exp ...
  ...

And also:

  11:56:08 aconole {master} ~/git/binutils-gdb$ ./binutils/objdump -dr move.o

  move.o:     file format elf64-bpfle


  Disassembly of section .text:

  0000000000000000 <.text>:
     0:	bf 12 00 00 00 00 00 00 	mov	r1, r2
     8:	b7 10 00 00 ef 00 00 00 	mov	r1, 239
    10:	bc 12 00 00 00 00 00 00 	mov32	r1, r2
    18:	b4 10 00 00 ef 00 00 00 	mov32	r1, 239
    20:	bf 36 00 00 00 00 00 00 	mov	r3, r6
    28:	bf 63 00 00 00 00 00 00 	mov	r6, r3
    30:	bf 89 00 00 00 00 00 00 	mov	r8, r9
    38:	bf a1 00 00 00 00 00 00 	mov	r10, r1
    40:	bf 73 00 00 00 00 00 00 	mov	r7, r3
    48:	b7 50 00 00 02 00 00 00 	mov	r5, 2

This is on an intel i7 (so not terribly exotic)

-Aaron
