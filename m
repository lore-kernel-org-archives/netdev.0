From: David Miller <davem@davemloft.net>
Subject: hmmm...
Date: Tue, 25 Apr 2017 21:52:32 -0400 (EDT)
Message-ID: <20170425.215232.727894789143301373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1434528AbdDZBwg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 21:52:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Alexei, I found something strange on my computer :-)

[davem@localhost binutils]$ ./objdump -d x.o

x.o:     file format elf64-bpf


Disassembly of section test1:

0000000000000000 <process>:
   0:	b7 00 00 00 00 00 00 02 	mov	r0, 2
   8:	61 21 00 50 00 00 00 00 	ldxw	r2, [r1+80]
  10:	61 11 00 4c 00 00 00 00 	ldxw	r1, [r1+76]
  18:	bf 41 00 00 00 00 00 00 	mov	r4, r1
  20:	07 40 00 00 00 00 00 0e 	add	r4, 14
  28:	2d 42 00 25 00 00 00 00 	jgt	r4, r2, 148 <LBB0_11>
  30:	71 51 00 0d 00 00 00 00 	ldxb	r5, [r1+13]
  38:	71 31 00 0c 00 00 00 00 	ldxb	r3, [r1+12]
  40:	67 30 00 00 00 00 00 08 	lsh	r3, 8
  48:	4f 35 00 00 00 00 00 00 	or	r3, r5
  50:	15 30 00 09 00 00 dd 86 	jeq	r3, 56710, 90 <process+0x90>
  58:	55 30 00 1d 00 00 00 08 	jne	r3, 8, 138 <LBB0_6+0x70>
  60:	bf 31 00 00 00 00 00 00 	mov	r3, r1
  68:	07 30 00 00 00 00 00 22 	add	r3, 34
  70:	2d 32 00 1c 00 00 00 00 	jgt	r3, r2, 148 <LBB0_11>
  78:	b7 30 00 00 00 00 00 03 	mov	r3, 3
  80:	71 54 00 00 00 00 00 00 	ldxb	r5, [r4+0]
  88:	67 50 00 00 00 00 00 02 	lsh	r5, 2
  90:	57 50 00 00 00 00 00 3c 	and	r5, 60
  98:	05 00 00 05 00 00 00 00 	ja	b8 <LBB0_5+0x18>

00000000000000a0 <LBB0_5>:
  a0:	b7 50 00 00 00 00 00 28 	mov	r5, 40
  a8:	b7 30 00 00 00 00 00 00 	mov	r3, 0
  b0:	bf 41 00 00 00 00 00 00 	mov	r4, r1
  b8:	07 40 00 00 00 00 00 36 	add	r4, 54
  c0:	2d 42 00 12 00 00 00 00 	jgt	r4, r2, 148 <LBB0_11>

00000000000000c8 <LBB0_6>:
  c8:	bf 41 00 00 00 00 00 00 	mov	r4, r1
  d0:	0f 45 00 00 00 00 00 00 	add	r4, r5
  d8:	07 40 00 00 00 00 00 0e 	add	r4, 14
  e0:	15 40 00 0c 00 00 00 00 	jeq	r4, 0, 138 <LBB0_6+0x70>
  e8:	bf 54 00 00 00 00 00 00 	mov	r5, r4
  f0:	07 50 00 00 00 00 00 14 	add	r5, 20
  f8:	2d 52 00 0b 00 00 00 00 	jgt	r5, r2, 148 <LBB0_11>
 100:	0f 13 00 00 00 00 00 00 	add	r1, r3
 108:	71 11 00 14 00 00 00 00 	ldxb	r1, [r1+20]
 110:	57 10 00 00 00 00 00 ff 	and	r1, 255
 118:	55 10 00 07 00 00 00 06 	jne	r1, 6, 148 <LBB0_11>
 120:	07 40 00 00 00 00 00 12 	add	r4, 18
 128:	2d 42 00 05 00 00 00 00 	jgt	r4, r2, 148 <LBB0_11>
 130:	b7 00 00 00 00 00 00 00 	mov	r0, 0
 138:	69 14 00 00 00 00 00 00 	ldxh	r1, [r4+0]
 140:	15 10 00 02 00 00 00 7b 	jeq	r1, 123, 148 <LBB0_11>

0000000000000148 <LBB0_11>:
 148:	18 00 00 00 ff ff ff ff 	ldimm64	r0, 4294967295
 150:	00 00 00 00 00 00 00 00 

0000000000000158 <LBB0_12>:
 158:	95 00 00 00 00 00 00 00 	exit	
[davem@localhost binutils]$ 
