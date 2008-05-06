From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [PATCH 01/18] flag parameters: helper function
Date: Mon, 5 May 2008 19:09:32 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0805051856550.20837@alien.or.mcafeemobile.com>
References: <200805050342.m453gkY4029814@devserv.devel.redhat.com>
 <20080505185103.b9299541.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ulrich Drepper <drepper@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, mtk.manpages@gmail.com,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([64.71.152.41]:38268 "EHLO
	x35.xmailserver.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757344AbYEFCJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 22:09:34 -0400
Received: from alien.or.mcafeemobile.com
	by x35.xmailserver.org with [XMail 1.25 ESMTP Server]
	id <S28AEC2> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Mon, 5 May 2008 22:09:33 -0400
In-Reply-To: <20080505185103.b9299541.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 May 2008, Andrew Morton wrote:

> > +int flags_remap(const struct flags_rmap *m, int n,
> > +		int f, int *rf)
> > +{
> > +	int i;
> > +	for (i = 0, *rf = 0; f && i < n; i++, m++)
> > +		if (f & m->f) {
> > +			*rf |= m->of;
> > +			f &= ~m->f;
> > +		}
> > +	return f;
> > +}
> 
> hm, that looks expensive.  The compiler will need to generate a deref of m
> and rf multiple times around the loop.  Copying them into locals does
> improve that a lot.

That's not a fast path. The extra cycles in the ldr/str get lost in the 
overall syscall cost. But I guess Uli (or myself afterward) can change it 
if you fill picky about it ;)



> I'm only on [1/18] so I don't know how often this code gets executed.  If
> it's "on each open" then ouch, perhaps it might even be worth investigating a
> table-based implementation.
> 
> Also: sorry, but ugh-at-the-naming.  We don't *gain* anything from having
> idenitifers called f, of, m, n and rf.  And we lose quite a lot in
> readability and understandability.  It would be much nicer to invest a
> little bit more typing-time here, IMO.

Why? Don't you like nibble-sized variable names? :)
Uli took my email-code as is, so either he changes it, or I'll post 
patches over it later.




- Davide


