From: Rob Herring <robherring2@gmail.com>
Subject: Re: panics in tcp_ack
Date: Sun, 02 Jun 2013 22:18:36 -0500
Message-ID: <51AC0B0C.7070306@gmail.com>
References: <51ABE067.2050507@gmail.com>  <1370219787.24311.113.camel@edumazet-glaptop> <51ABFE10.1030206@gmail.com> <1370228594.24311.114.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:60527 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846Ab3FCDSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 23:18:39 -0400
Received: by mail-yh0-f42.google.com with SMTP id t59so216125yho.1
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 20:18:38 -0700 (PDT)
In-Reply-To: <1370228594.24311.114.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2013 10:03 PM, Eric Dumazet wrote:
> On Sun, 2013-06-02 at 21:23 -0500, Rob Herring wrote:
> 
>> Meanwhile, here's another panic. This one is because struct tcphdr *th
>> is NULL which means skb->head is NULL. The skb is not NULL.
>>
>> <4>[84967.163498] pc : [<c040798c>]    lr : [<c040eda8>]    psr: 600e0013
>> <4>[84967.163498] sp : ed335cc8  ip : 00000001  fp : 00000400
>> <4>[84967.174970] r10: ed346e34  r9 : 00000001  r8 : c06d71b8
>> <4>[84967.180188] r7 : 00000000  r6 : 00000000  r5 : ecd85840  r4 : ecd85840
>> <4>[84967.186709] r3 : 00000020  r2 : 0000003a  r1 : a4051080  r0 : ed346e00
>> <4>[84967.193234] Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
>> Segment user
>> <4>[84967.200365] Control: 10c5387d  Table: 2d08804a  DAC: 00000015
>> <0>[84967.206109] Process python (pid: 883, stack limit = 0xed3342f0)
>> <0>[84967.212021] Stack: (0xed335cc8 to 0xed336000)
>> <0>[84967.216373] 5cc0:                   000005a8 00000000 ed346e00
>> c040ac08 c06a5a00 ecd85840
>> <0>[84967.224549] 5ce0: ed346e00 ed346e00 00000000 c06d71b8 ed346e34
>> c040eda8 ed346ea0 00000000
>> <0>[84967.232720] 5d00: 00000000 00000000 e9805380 0000000a 0000001c
>> ecd85840 00000000 ed346e00
>> <0>[84967.240897] 5d20: 00000000 c03b1d78 e9805380 ed346e00 0000fe88
>> 3a61054b 00000400 00df2c34
>> <0>[84967.249075] 5d40: 00000040 c03fd2b8 0000a400 edf8c840 ed335eb0
>> ed335ed8 c23212f0 c23212e0
>> <0>[84967.257249] 5d60: 00df2c34 c17720e0 0000000e 00000400 00000400
>> 000005a8 00000040 ed346ea0
>> <0>[84967.265419] 5d80: 00000000 00000000 ed334000 00000001 00010e30
>> 00000630 00000000 00000000
>> <0>[84967.273591] 5da0: 0000000e 0000fe88 00000000 c06d6040 c2aeb380
>> ed346e00 ed335e30 eca26000
>> <0>[84967.281763] 5dc0: ed335ed8 00000400 00df2834 00000000 00000003
>> c041ea58 c795c2e8 ed4ecb50
>> <0>[84967.289935] 5de0: 00000000 ed335df0 eca26000 c03aef74 51ab6eeb
>> 263fddc0 00000000 00000400
>> <0>[84967.298105] 5e00: eca26000 00000000 00000000 ed335ed8 01d0d6eb
>> c00cb4d8 00000056 00000000
>> <0>[84967.306294] 5e20: 91827364 ed335e24 00001000 00000001 ed9b4050
>> 00000000 00000000 00000001
>> <0>[84967.314472] 5e40: ffffffff 00000000 00000000 00000000 00000000
>> 00000000 ecc3de80 00000001
>> <0>[84967.322642] 5e60: 00000000 00000000 00001000 00000000 ed335df0
>> 00000000 00001000 c0012f28
>> <0>[84967.330812] 5e80: fee00100 0002c000 00000000 ed335f88 ed9b4000
>> fffffdee ed334000 00000001
>> <0>[84967.338983] 5ea0: b6ae35f8 c010aa38 0002c000 00000000 00000400
>> eca26000 c06a4508 00000000
>> <0>[84967.347152] 5ec0: 00000040 c03b07d4 fffffff7 00000000 00df2834
>> 00000400 00000000 00000000
>> <0>[84967.355321] 5ee0: ed335ed0 00000001 00000000 00000000 00000040
>> 00000000 00000000 c0223254
>> <0>[84967.363495] 5f00: 00001000 00000000 00001000 00000000 00000001
>> ed9b4008 600e0013 ffffffff
>> <0>[84967.371666] 5f20: c000dbc4 c06ff504 ffffffff 00000000 00014be7
>> 03614c11 ed335f90 00000000
>> <0>[84967.379858] 5f40: 0000000a ed335f68 c000dd28 ed334000 00000000
>> 00000003 0000000a 0000000a
>> <0>[84967.388032] 5f60: 00000000 0002c000 00014bf1 00002710 00000001
>> 271ae81b b6aecd90 00000000
>> <0>[84967.396203] 5f80: 00d25050 00000121 c000dd28 ed334000 00000000
>> c03b0828 00000000 00000000
>> <0>[84967.404376] 5fa0: be8f2890 c000db60 b6aecd90 00000000 00000006
>> 00df2834 00000400 00000000
>> <0>[84967.412547] 5fc0: b6aecd90 00000000 00d25050 00000121 00000400
>> 00df2834 b6ad4fd0 00000003
>> <0>[84967.420719] 5fe0: 00000000 be8f289c 000a5505 b6f7398c 600e0010
>> 00000006 00000000 00000000
>> <4>[84967.428912] [<c040798c>] (tcp_rcv_established+0x20/0x5e0) from
>> [<c040eda8>] (tcp_v4_do_rcv+0xf0/0x2cc)
>> <4>[84967.438252] [<c040eda8>] (tcp_v4_do_rcv+0xf0/0x2cc) from
>> [<c03b1d78>] (release_sock+0x84/0xfc)
>> <4>[84967.446900] [<c03b1d78>] (release_sock+0x84/0xfc) from
>> [<c03fd2b8>] (tcp_sendmsg+0x378/0xcdc)
>> <4>[84967.455439] [<c03fd2b8>] (tcp_sendmsg+0x378/0xcdc) from
>> [<c041ea58>] (inet_sendmsg+0x80/0xb8)
>> <4>[84967.463966] [<c041ea58>] (inet_sendmsg+0x80/0xb8) from
>> [<c03aef74>] (sock_sendmsg+0xcc/0xec)
>> <4>[84967.472404] [<c03aef74>] (sock_sendmsg+0xcc/0xec) from
>> [<c03b07d4>] (sys_sendto+0xc0/0xfc)
>> <4>[84967.480670] [<c03b07d4>] (sys_sendto+0xc0/0xfc) from [<c03b0828>]
>> (sys_send+0x18/0x20)
>> <4>[84967.488599] [<c03b0828>] (sys_send+0x18/0x20) from [<c000db60>]
>> (ret_fast_syscall+0x0/0x30)
>>
> 
> Hmm, skb->head being NULL, are you really really sure ???

Ah, missed that there are 2 versions of skb_transport_header. So on
32-bit it is skb->transport_header.

Here's the ARM disassembly:

c040796c <tcp_rcv_established>:
c040796c:       e92d45f0        push    {r4, r5, r6, r7, r8, sl, lr}
c0407970:       e1a06002        mov     r6, r2
c0407974:       e5d023e4        ldrb    r2, [r0, #996]  ; 0x3e4
c0407978:       e1a05001        mov     r5, r1
c040797c:       e5901344        ldr     r1, [r0, #836]  ; 0x344
c0407980:       e24dd014        sub     sp, sp, #20
c0407984:       e7c0201f        bfc     r2, #0, #1
c0407988:       e5c023e4        strb    r2, [r0, #996]  ; 0x3e4
panic>c040798c:       e596200c        ldr     r2, [r6, #12]

r6 is NULL. r6 came from r2 which is the 3rd function argument.

The 3rd arg is tcp_hdr(skb) which is skb->transport_header.

Rob
