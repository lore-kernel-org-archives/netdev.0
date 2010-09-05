From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] usbnet: allow rx_process() to ignore packets
Date: Sun, 5 Sep 2010 14:35:15 -0700 (PDT)
Message-ID: <436709.64173.qm@web180305.mail.gq1.yahoo.com>
References: <201009051816.12823.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: Ondrej Zary <linux@rainbow-software.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n5.bullet.mail.gq1.yahoo.com ([67.195.9.85]:34315 "HELO
	n5.bullet.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752668Ab0IEVfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 17:35:16 -0400
In-Reply-To: <201009051816.12823.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > > From: Ondrej Zary <linux@rainbow-software.org>
> > > Subject: [PATCH] usbnet: allow rx_process() to
> ignore packets
> >
> > It already can ... I'm already not
> > liking this patch...

You didn't explain why "ignore".  As a rule, if
the network peer is sending garbage, that needs
to be accounted as an error, not igored.  You seem
to be complaining about accounting garbage as such.

 rx_process() knows only two cases:
> either rx_fixup() 
> returns 0 or a non-zero value. If I return 0,
>  the error counter is  incremented.

So don't return zero, when you're not trying to
indicate an error. ... easy.


> If I return non-zero value, packet is
> processed ("passed up the 
> stack" - usbnet_skb_return() called)
> if the skb has non-zero length,

Exactly -- that's how the minidriver says that
it stripped framing off the packet, so other
code should pass the packet up the stack.


Have you tried emptying the SKB (len zero) to
indicate you've consumed all of its contents?
(Or in your case, "ignored").  That would seem to
be more like what you want to do ...  ISTR that the
network stack cleanly handles empty SKBs; if not,
maybe it should.

There's no way
> to not pass the 
> packet up the stack without incrementing the error
> counter.

   If rx_fixup leaves a single packet in SKB, that
gets passed up the stack. and not treated as any
kind of error.



> 
> > You've not convinced me this is even necessary.
> >


