From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for
 x86_64
Date: Mon, 29 Feb 2016 01:39:51 +0000 (GMT)
Message-ID: <alpine.LFD.2.20.1602290135170.28664@eddie.linux-mips.org>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>        <CAKgT0UdxdY5VF5OzC+W0Y31CcK0T3ffkcRMQrZqJ==L9SdtNuQ@mail.gmail.com> <CAKgT0UfDWXbXSX45XRZjTc6SXz+XqaYa1bHGzOUV_RXSPh=U=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	the arch/x86 maintainers <x86@kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:40918 "EHLO
	cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbcB2Bjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2016 20:39:53 -0500
Received: (from localhost user: 'macro', uid#1010) by eddie.linux-mips.org
        with ESMTP id S27013303AbcB2BjvDXO6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 02:39:51 +0100
In-Reply-To: <CAKgT0UfDWXbXSX45XRZjTc6SXz+XqaYa1bHGzOUV_RXSPh=U=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 28 Feb 2016, Alexander Duyck wrote:

> I actually found the root cause.  The problem is in add32_with_carry3.
> 
> > +static inline unsigned int add32_with_carry3(unsigned int a, unsigned int b,
> > +                                            unsigned int c)
> > +{
> > +       asm("addl %2,%0\n\t"
> > +           "adcl %3,%0\n\t"
> > +           "adcl $0,%0"
> > +           : "=r" (a)
> > +           : "" (a), "rm" (b), "rm" (c));
> > +
> > +       return a;
> > +}
> > +
> 
> You need to set the 'a' input variable attribute to "0" instead of ""
> and then things work for me correctly.

 Or alternatively you can reduce the number of operands by one, by using 
`"+r" (a)' as output, and then removing `a' as a separate input and 
renumbering references to `b' and `c' accordingly.  It would IMHO actually 
better match the in-place operation as well.

 FWIW,

  Maciej
