From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Crash in ip_conntrack on shutdown
Date: Wed, 1 Nov 2006 18:48:56 -0800
Message-ID: <20061101184856.429dbde1@localhost.localdomain>
References: <45494243.20001@dslnorthwest.net>
	<20061101.174931.66061218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@dslnorthwest.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27315 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751256AbWKBCt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 21:49:28 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061101.174931.66061218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Nov 2006 17:49:31 -0800 (PST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@dslnorthwest.net>
> Date: Wed, 01 Nov 2006 16:56:35 -0800
> 
> > My desktop machine (Fedora Core 6) crashed on during shutdown when 
> > running latest
> > 2.6.19-rc4 kernel. Machine is UP Amd64.
> > 
> > It looks like a null dereference in ip_conntrack. See screenshot.
> >   
> > http://picasaweb.google.com/stephen.hemminger/LinuxCrashes/photo#4992593950061821970
> 
> Can some x86_64 expert decode this?  I'm trying to figure out what
> object is being NULL defer'd, and after taking a quick look at
> this dump I can't figure it out.
> 
> I suspect there may also be a OOPS right before this one, I also
> wonder if this was actually a BUG_ON() trigger.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Instruction decode of ip_conntrack:destroy_conntrack+0xfc = 0x21ce

    2177:       75 0a                   jne    2183 <destroy_conntrack+0xb1>
    2179:       0f 0b                   ud2a
    217b:       68 00 00 00 00          pushq  $0x0
    2180:       c2 56 01                retq   $0x156
    2183:       48 8b 41 08             mov    0x8(%rcx),%rax
    2187:       48 89 42 08             mov    %rax,0x8(%rdx)
    218b:       48 89 10                mov    %rdx,(%rax)
    218e:       48 c7 41 08 00 02 20    movq   $0x200200,0x8(%rcx)
    2195:       00
    2196:       48 c7 83 f8 00 00 00    movq   $0x100100,0xf8(%rbx)
    219d:       00 01 10 00
    21a1:       ff 05 00 00 00 00       incl   0(%rip)        # 21a7 <destroy_conntrack+0xd5>
    21a7:       bf 01 00 00 00          mov    $0x1,%edi
    21ac:       e8 00 00 00 00          callq  21b1 <destroy_conntrack+0xdf>
    21b1:       e8 00 00 00 00          callq  21b6 <destroy_conntrack+0xe4>
    21b6:       48 8b 53 58             mov    0x58(%rbx),%rdx
    21ba:       48 85 d2                test   %rdx,%rdx
    21bd:       74 0f                   je     21ce <destroy_conntrack+0xfc>
    21bf:       ff 0a                   decl   (%rdx)
    21c1:       0f 94 c0                sete   %al
    21c4:       84 c0                   test   %al,%al
    21c6:       74 06                   je     21ce <destroy_conntrack+0xfc>
    21c8:       48 89 d7                mov    %rdx,%rdi
    21cb:       ff 52 08                callq  *0x8(%rdx)
    21ce:       48 89 df                mov    %rbx,%rdi  <--- last visible spot in back trace
    21d1:       5b                      pop    %rbx
    21d2:       e9 00 00 00 00          jmpq   21d7 <invert_tuplepr>

