From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: panics in tcp_ack
Date: Sun, 02 Jun 2013 20:32:50 -0700
Message-ID: <1370230370.24311.121.camel@edumazet-glaptop>
References: <51ABE067.2050507@gmail.com>
	  <1370219787.24311.113.camel@edumazet-glaptop> <51ABFE10.1030206@gmail.com>
	 <1370228594.24311.114.camel@edumazet-glaptop> <51AC0B0C.7070306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rob Herring <robherring2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33042 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab3FCDcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jun 2013 23:32:52 -0400
Received: by mail-pd0-f169.google.com with SMTP id y11so5000099pdj.0
        for <netdev@vger.kernel.org>; Sun, 02 Jun 2013 20:32:52 -0700 (PDT)
In-Reply-To: <51AC0B0C.7070306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-06-02 at 22:18 -0500, Rob Herring wrote:

> Ah, missed that there are 2 versions of skb_transport_header. So on
> 32-bit it is skb->transport_header.
> 
> Here's the ARM disassembly:
> 
> c040796c <tcp_rcv_established>:
> c040796c:       e92d45f0        push    {r4, r5, r6, r7, r8, sl, lr}
> c0407970:       e1a06002        mov     r6, r2
> c0407974:       e5d023e4        ldrb    r2, [r0, #996]  ; 0x3e4
> c0407978:       e1a05001        mov     r5, r1
> c040797c:       e5901344        ldr     r1, [r0, #836]  ; 0x344
> c0407980:       e24dd014        sub     sp, sp, #20
> c0407984:       e7c0201f        bfc     r2, #0, #1
> c0407988:       e5c023e4        strb    r2, [r0, #996]  ; 0x3e4
> panic>c040798c:       e596200c        ldr     r2, [r6, #12]
> 
> r6 is NULL. r6 came from r2 which is the 3rd function argument.
> 
> The 3rd arg is tcp_hdr(skb) which is skb->transport_header.
> 
> Rob

Interesting. transport header should be set in IP stack before TCP.

What is the driver delivering this packet ?

Do you have commit fda55eca5a33f33ffcd4192c6b2d75179714a52c
("net: introduce skb_transport_header_was_set()")
