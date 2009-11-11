From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Wed, 11 Nov 2009 03:32:04 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911110235270.2864@melkinpaasi.cs.helsinki.fi>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <4AF978D3.7030207@gmail.com> <4AF98AAE.6000307@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696230645-1646888225-1257900096=:2864"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41079 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755455AbZKKBb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 20:31:59 -0500
In-Reply-To: <4AF98AAE.6000307@gmail.com>
Content-ID: <alpine.DEB.2.00.0911110306210.2864@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1646888225-1257900096=:2864
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0911110246521.2864@melkinpaasi.cs.helsinki.fi>

On Tue, 10 Nov 2009, William Allen Simpson wrote:

> Eric Dumazet wrote:
> > William Allen Simpson a écrit :
> > > This is a significantly revised implementation of an earlier (year-old)
> > > patch that no longer applies cleanly, with permission of the original
> > > author (Adam Langley).  That patch was previously reviewed:
> > > 
> > >    http://thread.gmane.org/gmane.linux.network/102586
> 
> > I really tried hard to understand what was going on, and failed, because I
> > dont
> > have much time these days...
> > 
> Thanks very much for your time.
> 
> As I just wrote in a previous message, this is the easy part.  It's going
> to get much more complicated -- as you know, since I sent you the papers
> with 30+ references....
> 
> 
> > Lack of documentation maybe ? Some DATA flow could help...
> > 
> Where should that be?  In the commit messages?
> 
> 
> > Please please, cook up elementatry patches to perform one action at a time,
> > even if they are not fully functionnal ?
> > 
> Well, that's what I did with the (now) parts 1b, 1c, and 1d, but somebody
> complained that the callers didn't exist yet.

I guess there's misunderstanding here. Yes, if you bring in new helpers 
that solely are used with your feature, then it that feature patch (and 
I found DaveM commenting specifically this point I think), or right 
beforehand with a clear note that it will be used in the subsequent patch. 
But if there are uses in the existing code without any of your changes, 
add the helpers and convert existing callers in a single go without doing 
some other things (preferrably convert all callers, not just those you 
intend to touch -- there is nothing extraordinary in this, other people do 
the same kind of cleaning up work while they go, so please don't find that 
this is something we try to force specifically for you :-)). ...Therefore 
each change becomes rather self-sufficient to understand and review. There 
was serious problems in your series in this as I constantly had to jump 
between 3 patches to see what you said (changed) in the other. But also, 
please don't make this an over-statement, I'd still occassionally have to 
do that "patch hopping" even if nicely split (so this is not something to 
be turned into all in a single patch statement :-)).

On positive side, there certainly has been clear progress already, as 
patches 1 and 2 were quite nice already (except for some weird local 
initializer order change which I could sort of "tolerate" but I didn't 
find any particular reason why those had to be switched around.

And, one thing to not be afraid is making many short patches (nor long 
one either). So if a self-contained change is a small one do it such and 
no more. ...It is often so that you will be doing many relatively small 
changes first to support the actual large one, and those small changes 
might actually not end up being that small in lines if there are e.g. 
multiple callsites converted but nevertheless they often are rather 
simple, so that a quick browsing will already be enough to reveal that it 
is ok (like in the MSS define change you made).

> > One patch to be able to send SYN + COOKIE (if we are the client)
> > 
> > One patch to be able to receive this SYN + COOKIE and answer a SYNACK +
> > cookies (we are the server)
> > 
> I'll split them.  Remember, I started with a code base previously
> submitted, and everything was in one *single* large patch.  I thought
> that's what you (Linux folks in general) wanted.

Only if the large patch is only for a single logical change. A 
syntax cleanup, literal cleanup, cleanup to use helpers and a feature 
patch are not logically same changes, and thus should be separated.
It's like you have already being doing for a part of the changes. Many 
times the cleanup things are even such that they would be beneficial even 
without any feature addition (but nobody has just done them so far).

-- 
 i.
---696230645-1646888225-1257900096=:2864--
