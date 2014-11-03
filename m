From: Roberto Medina <robertoxmed@gmail.com>
Subject: Re: [PATCH] net: eth: realtek: atp: checkpatch errors and warnings
 corrected
Date: Mon, 03 Nov 2014 20:09:19 +0100
Message-ID: <5457D2DF.5000508@gmail.com>
References: <1415039073-20164-1-git-send-email-robertoxmed@gmail.com> <1415040686.17743.31.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415040686.17743.31.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/03/2014 07:51 PM, Joe Perches wrote:
>
> Some ancient drivers could be regarded as neolithic
> curiosities that never need updating.  This may be one.
>
> But if you really want to change it, could you please
> make sure that objdiff shows no changes?
>

I see some changes with objdiff, maybe this is caused by the include 
file that I changed to linux/io.h instead of asm/io.h

--- 
/home/vov/Git/linux-next/.tmp_objdiff/a641d0e/drivers/net/ethernet/realtek/atp.dis 
2014-11-03 19:59:18.723954900 +0100
+++ 
/home/vov/Git/linux-next/.tmp_objdiff/5f19b70/drivers/net/ethernet/realtek/atp.dis 
2014-11-03 20:00:34.133954217 +0100
@@ -1753,9 +1753,8 @@
  	...
  :	e3 0a                	jrcxz  4c4 <__gcov_.atp_probe1+0x14>
  :	00 00                	add    %al,(%rax)
-:	e2 e2                	loop   4a0 <__gcov_.atp_init+0x20>
-:	9c                   	pushfq
-:	9a                   	(bad)
+:	4b b4 98             	rex.WXB mov $0x98,%r12b
+:	ac                   	lods   %ds:(%rsi),%al
  :	67 2f                	addr32 (bad)
  :	e4 e3                	in     $0xe3,%al
  :	00 00                	add    %al,(%rax)
@@ -1767,30 +1766,37 @@
  	...
  :	e4 0a                	in     $0xa,%al
  :	00 00                	add    %al,(%rax)
-:	a5                   	movsl  %ds:(%rsi),%es:(%rdi)
-:	21 4f ca             	and    %ecx,-0x36(%rdi)
-:	a0 82 0e 4f 00 00 00 	movabs 0x7000000004f0e82,%al
-:	00 07
+:	d6                   	(bad)
+:	ad                   	lods   %ds:(%rsi),%eax
+:	51                   	push   %rcx
+:	70 a0                	jo     491 <__gcov_.atp_init+0x11>
+:	82                   	(bad)
+:	0e                   	(bad)
+:	4f 00 00             	rex.WRXB add %r8b,(%r8)
+:	00 00                	add    %al,(%rax)
+:	07                   	(bad)
  	...

  0000000000000510 <__gcov_.eeprom_op>:
  	...
  :	e5 0a                	in     $0xa,%eax
  :	00 00                	add    %al,(%rax)
-:	cd c3                	int    $0xc3
-:	0f c4 5c 4b fc 84    	pinsrw $0x84,-0x4(%rbx,%rcx,2),%mm3
-:	00 00                	add    %al,(%rax)
+:	54                   	push   %rsp
+:	0e                   	(bad)
+:	dd ca                	(bad)
+:	5c                   	pop    %rsp
+:	4b fc                	rex.WXB cld
+:	84 00                	test   %al,(%rax)
  :	00 00                	add    %al,(%rax)
-:	07                   	(bad)
+:	00 07                	add    %al,(%rdi)
  	...

  0000000000000540 <__gcov_.net_open>:
  	...
  :	e6 0a                	out    %al,$0xa
  :	00 00                	add    %al,(%rax)
-:	52                   	push   %rdx
-:	e7 5d                	out    %eax,$0x5d
-:	8f                   	(bad)
+:	0f bf 0e             	movswl (%rsi),%ecx
+:	4f                   	rex.WRXB
  :	66 af                	scas   %es:(%rdi),%ax
  :	e2 a2                	loop   4f6 <__gcov_.get_node_ID+0x16>
  :	00 00                	add    %al,(%rax)
@@ -1802,15 +1808,16 @@
  	...
  :	e7 0a                	out    %eax,$0xa
  :	00 00                	add    %al,(%rax)
-:	a9 17 a9 64 dc       	test   $0xdc64a917,%eax
-:	20 8c 1d 00 00 00 00 	and    %cl,0x0(%rbp,%rbx,1)
+:	21 8a b7 70 dc 20    	and    %ecx,0x20dc70b7(%rdx)
+:	8c 1d 00 00 00 00    	mov    %ds,0x0(%rip)        # 588 
<__gcov_.hardware_init+0x18>
  :	0f 00 00             	sldt   (%rax)
  	...

  00000000000005a0 <__gcov_.trigger_send>:
  	...
-:	e8 0a 00 00 b9       	callq  ffffffffb90005b7 
<net_open+0xffffffffb8ffeeb8>
-:	d3 0c 12             	rorl   %cl,(%rdx,%rdx,1)
+:	e8 0a 00 00 38       	callq  380005b7 <net_open+0x37ffeeb8>
+:	2e                   	cs
+:	e7 bb                	out    %eax,$0xbb
  :	b9 43 f3 81 00       	mov    $0x81f343,%ecx
  :	00 00                	add    %al,(%rax)
  :	00 04 00             	add    %al,(%rax,%rax,1)
@@ -1818,10 +1825,10 @@

  00000000000005d0 <__gcov_.write_packet>:
  	...
-:	e9 0a 00 00 63       	jmpq   630005e7 <net_open+0x62ffeee8>
-:	e5 05                	in     $0x5,%eax
-:	96                   	xchg   %eax,%esi
-:	27                   	(bad)
+:	e9 0a 00 00 05       	jmpq   50005e7 <net_open+0x4ffeee8>
+:	54                   	push   %rsp
+:	5f                   	pop    %rdi
+:	23 27                	and    (%rdi),%esp
  :	0d e5 2c 00 00       	or     $0x2ce5,%eax
  :	00 00                	add    %al,(%rax)
  :	15 00 00 00 00       	adc    $0x0,%eax
@@ -1831,7 +1838,7 @@
  	...
  :	ea                   	(bad)
  :	0a 00                	or     (%rax),%al
-:	00 2d d0 35 4c 7a    	add    %ch,0x7a4c35d0(%rip)        # 7a4c3be1 
<net_open+0x7a4c24e2>
+:	00 8e bf 72 94 7a    	add    %cl,0x7a9472bf(%rsi)
  :	c4 61 e7 00          	(bad)
  :	00 00                	add    %al,(%rax)
  :	00 06                	add    %al,(%rsi)
@@ -1841,9 +1848,11 @@
  	...
  :	eb 0a                	jmp    644 <__gcov_.atp_send_packet+0x14>
  :	00 00                	add    %al,(%rax)
-:	78 ac                	js     5ea <__gcov_.write_packet+0x1a>
-:	9b                   	fwait
-:	4f 63 b6 a7 f3 00 00 	rex.WRXB movslq 0xf3a7(%r14),%r14
+:	4e ed                	rex.WRX in (%dx),%eax
+:	5b                   	pop    %rbx
+:	dd 63 b6             	frstor -0x4a(%rbx)
+:	a7                   	cmpsl  %es:(%rdi),%ds:(%rsi)
+:	f3 00 00             	repz add %al,(%rax)
  :	00 00                	add    %al,(%rax)
  :	0c 00                	or     $0x0,%al
  	...
@@ -1852,9 +1861,10 @@
  	...
  :	ec                   	in     (%dx),%al
  :	0a 00                	or     (%rax),%al
-:	00 66 37             	add    %ah,0x37(%rsi)
-:	2f                   	(bad)
-:	d0 3e                	sarb   (%rsi)
+:	00 f9                	add    %bh,%cl
+:	64 4d                	fs rex.WRB
+:	44                   	rex.R
+:	3e                   	ds
  :	16                   	(bad)
  :	72 d7                	jb     64b <__gcov_.atp_send_packet+0x1b>
  :	00 00                	add    %al,(%rax)
@@ -1866,8 +1876,9 @@
  	...
  :	ed                   	in     (%dx),%eax
  :	0a 00                	or     (%rax),%al
-:	00 50 2e             	add    %dl,0x2e(%rax)
-:	24 2a                	and    $0x2a,%al
+:	00 5a 73             	add    %bl,0x73(%rdx)
+:	56                   	push   %rsi
+:	cf                   	iret
  :	b0 28                	mov    $0x28,%al
  :	9e                   	sahf
  :	0c 00                	or     $0x0,%al
@@ -1879,9 +1890,9 @@
  	...
  :	ee                   	out    %al,(%dx)
  :	0a 00                	or     (%rax),%al
-:	00 60 1b             	add    %ah,0x1b(%rax)
-:	f5                   	cmc
-:	b9 ca 01 fa fa       	mov    $0xfafa01ca,%ecx
+:	00 85 af 2d b0 ca    	add    %al,-0x354fd251(%rbp)
+:	01 fa                	add    %edi,%edx
+:	fa                   	cli
  :	00 00                	add    %al,(%rax)
  :	00 00                	add    %al,(%rax)
  :	17                   	(bad)
@@ -1891,7 +1902,8 @@
  	...
  :	ef                   	out    %eax,(%dx)
  :	0a 00                	or     (%rax),%al
-:	00 b3 fb 8e ed 58    	add    %dh,0x58ed8efb(%rbx)
+:	00 e8                	add    %ch,%al
+:	09 7c 81 58          	or     %edi,0x58(%rcx,%rax,4)
  :	32 13                	xor    (%rbx),%dl
  :	9d                   	popfq
  :	00 00                	add    %al,(%rax)
@@ -1902,7 +1914,8 @@
  0000000000000720 <__gcov_.net_close>:
  	...
  :	f0 0a 00             	lock or (%rax),%al
-:	00 ae b2 85 8a 2a    	add    %ch,0x2a8a85b2(%rsi)
+:	00 54 b3 8a          	add    %dl,-0x76(%rbx,%rsi,4)
+:	3b 2a                	cmp    (%rdx),%ebp
  :	24 53                	and    $0x53,%al
  :	13 00                	adc    (%rax),%eax
  :	00 00                	add    %al,(%rax)
@@ -1913,11 +1926,7 @@
  	...
  :	f1                   	icebp
  :	0a 00                	or     (%rax),%al
-:	00 20                	add    %ah,(%rax)
-:	f5                   	cmc
-:	d4                   	(bad)
-:	c7                   	(bad)
-:	96                   	xchg   %eax,%esi
+:	00 b5 7a 16 07 96    	add    %dh,-0x69f8e986(%rbp)
  :	df 25 67 00 00 00    	fbld   0x67(%rip)        # 7ce 
<__gcov_.atp_init_module+0x4e>
  :	00 04 00             	add    %al,(%rax,%rax,1)
  	...
@@ -1925,10 +1934,7 @@
  0000000000000780 <__gcov_.atp_init_module>:
  	...
  :	f2 0a 00             	repnz or (%rax),%al
-:	00 3f                	add    %bh,(%rdi)
-:	2e                   	cs
-:	04 c9                	add    $0xc9,%al
-:	9e                   	sahf
+:	00 a6 4d 6b ed 9e    	add    %ah,-0x611294b3(%rsi)
  :	66                   	data16
  :	b2 b6                	mov    $0xb6,%dl
  :	00 00                	add    %al,(%rax)
@@ -1940,7 +1946,8 @@
  :	30 34 00             	xor    %dh,(%rax,%rax,1)
  	...
  :	00 00                	add    %al,(%rax)
-:	00 6c 48 04          	add    %ch,0x4(%rax,%rcx,2)
+:	00 2c c8             	add    %ch,(%rax,%rcx,8)
+:	06                   	(bad)
  :	77 00                	ja     7d5 <__gcov_.atp_init_module+0x55>
  	...
  :	00 00                	add    %al,(%rax)
@@ -1950,9 +1957,8 @@
  0000000000000840 <__gcov_.atp_cleanup_module>:
  	...
  :	f3 0a 00             	repz or (%rax),%al
-:	00 20                	add    %ah,(%rax)
-:	d2 18                	rcrb   %cl,(%rax)
-:	bd 5e f3 45 61       	mov    $0x6145f35e,%ebp
+:	00 bb a8 99 b6 5e    	add    %bh,0x5eb699a8(%rbx)
+:	f3 45 61             	repz rex.RB (bad)
  :	00 00                	add    %al,(%rax)
  :	00 00                	add    %al,(%rax)
  :	04 00                	add    $0x0,%al
@@ -2076,13 +2082,13 @@
  0000000000000c50 <__gcov0.atp_cleanup_module>:
  	...

-0000000000000c70 <num_tx_since_rx.44203>:
+0000000000000c70 <num_tx_since_rx.44241>:
  	...

-0000000000000c78 <__key.44146>:
+0000000000000c78 <__key.44184>:
  	...

-0000000000000c80 <__key.44121>:
+0000000000000c80 <__key.44159>:
  	...

  0000000000000c88 <root_atp_dev>:
