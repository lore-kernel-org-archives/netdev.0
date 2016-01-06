From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Wed, 06 Jan 2016 06:25:07 -0800
Message-ID: <1452090307.8255.173.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com>
	 <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1CCBE431@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36676 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751926AbcAFOZK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 09:25:10 -0500
Received: by mail-pf0-f174.google.com with SMTP id 65so194669353pff.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 06:25:09 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CCBE431@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-01-06 at 10:16 +0000, David Laight wrote:
> From: Eric Dumazet
> > Sent: 05 January 2016 22:19
> > To: Tom Herbert
> > You might add a comment telling the '4' comes from length of 'adcq
> > 6*8(%rdi),%rax' instruction, and that the 'nop' is to compensate that
> > 'adcq    0*8(%rdi),%rax' is using 3 bytes instead.
> > 
> > We also could use .byte 0x48, 0x13, 0x47, 0x00 to force a 4 bytes
> > instruction and remove the nop.
> > 
> > 
> > +       lea     20f(, %rcx, 4), %r11
> > +       clc
> > +       jmp     *%r11
> > +
> > +.align 8
> > +       adcq    6*8(%rdi),%rax
> > +       adcq    5*8(%rdi),%rax
> > +       adcq    4*8(%rdi),%rax
> > +       adcq    3*8(%rdi),%rax
> > +       adcq    2*8(%rdi),%rax
> > +       adcq    1*8(%rdi),%rax
> > +       adcq    0*8(%rdi),%rax // could force a 4 byte instruction (.byte 0x48, 0x13, 0x47, 0x00)
> > +       nop
> > +20:    /* #quads % 8 jump table base */
> 
> Or move label at the top (after the .align) and adjust the maths.
> You could add a second label after the first adcq and use the
> difference between them for the '4'.

Not really.

We could not use the trick it the length was 5.

Only 1, 2, 4 and 8 are supported.
