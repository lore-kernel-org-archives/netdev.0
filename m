From: Michael Buesch <mb@bu3sch.de>
Subject: Re: pull request: wireless-2.6 2008-02-27
Date: Fri, 29 Feb 2008 13:16:59 +0100
Message-ID: <200802291316.59738.mb@bu3sch.de>
References: <20080228014125.GI3078@tuxdriver.com> <97a0a9ac0802281321h6f302865j38a55c6f761dc14b@mail.gmail.com> <20080228.133008.228590007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gordonfarquharson@gmail.com, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:57723 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760170AbYB2MR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 07:17:26 -0500
In-Reply-To: <20080228.133008.228590007.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 February 2008 22:30:08 David Miller wrote:
> From: "Gordon Farquharson" <gordonfarquharson@gmail.com>
> Date: Thu, 28 Feb 2008 14:21:21 -0700
> 
> > Hi David
> > 
> > On Thu, Feb 28, 2008 at 12:51 AM, David Miller <davem@davemloft.net> wrote:
> > > From: "John W. Linville" <linville@tuxdriver.com>
> > >  Date: Wed, 27 Feb 2008 20:41:25 -0500
> > >
> > >
> > >  > Gordon Farquharson (1):
> > >  >       Fix b43 driver build for arm
> > >
> > >  Please revert this change and resend your pull request.
> > >
> > >  If file2alias doesn't work properly in a cross build environment, we
> > >  don't fix it by crapping up mod_devalias.h with these silly align
> > >  attribute annotations.
> > 
> > This was extensively discussed on LKML [1, 2] and the patch has been
> > merged into Andrew Morton's -mm tree. It is understood that this is
> > not the Right Way to fix to problem, hence the big fat comment in the
> > code. It would be great if you could reconsider your decision.
> 
> If you put that thing in there now, on ARM the structure size changes
> as does the alignment of that final member.
> 
> Then we're stuck with it and you can't remove that hack from
> mod_devalias.h.  It can't be removed even after the cross build issues
> of file2alias are resolved properly without re-breaking ARM.
> 
> Feel free to push that via Andrew or someone else, but that turd isn't
> going in by my tree because to me it's clearly the wrong thing to do.

I didn't even think of this being an actual ABI issue when _removing_
it again. So you get another NACK from me for this patch. :)

I'm wondering if we can't simply pass a commandline parameter to file2alias
that tells it whether we are crosscompiling. It should simply omit the sanity check
in that case. Is there any easy and reliable way to find out whether we
are crosscompiling from a makefile (I don't know the makefile core that much)?

Andrew, can you please drop it? We need to fix this differently. No matter how.

-- 
Greetings Michael.
