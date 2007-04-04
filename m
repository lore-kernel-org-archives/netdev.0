From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: tg3 reset_task question
Date: Wed, 4 Apr 2007 15:10:07 -0700
Message-ID: <20070404151007.2648621f@localhost>
References: <d66d623f0704041334m5e0c68ebw777f621c779e1153@mail.gmail.com>
	<1175722621.7911.63.camel@dell>
	<4614105B.4080105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
To: Gagan Arneja <gaagaan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:57994 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbXDDWKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 18:10:11 -0400
In-Reply-To: <4614105B.4080105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 04 Apr 2007 13:53:47 -0700
Gagan Arneja <gaagaan@gmail.com> wrote:

> I like the counting semaphore idea.
> 
> --
> Gagan
> 
> Michael Chan wrote:
> > On Wed, 2007-04-04 at 13:34 -0700, Gagan Arneja wrote:
> >> Can't this BUG_ON be hit very easily:
> >>
> >> static void tg3_irq_quiesce(struct tg3 *tp)
> >> {
> >>         BUG_ON(tp->irq_sync);
> >> ...
> >> }
> >>
> >> tg3_reset_task could easily be racing with another thread, that calls
> >> tg3_full_lock(tp, 1); e.g tg3_change_mtu. Maybe I'm missing something
> >> obvious.
> >>
> > 
> > Yes, you're right.  Perhaps we should get the rtnl first before
> > tg3_full_lock(), or turn irq_sync into an atomic counter that allows
> > nesting.

When you start reinventing windows locks or the BKL, you know
you are going down the wrong path
