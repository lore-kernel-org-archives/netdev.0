From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Strange Application bug, race in MSG_PEEK complaints (was:
 Bug#513695: fetchmail: race in MSG_PEEK)
Date: Thu, 7 May 2009 21:48:16 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905072139001.15149@wrl-59.cs.helsinki.fi>
References: <200902262310.12791.elendil@planet.nl> <20090506230240.GA10373@merlin.emma.line.org>
 <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
 <200905071916.57903.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-39249334-1241722096=:15149"
Cc: Matthias Andree <matthias.andree@gmx.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56877 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbZEGSsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 14:48:16 -0400
In-Reply-To: <200905071916.57903.elendil@planet.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-39249334-1241722096=:15149
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 7 May 2009, Frans Pop wrote:

> On Thursday 07 May 2009, Ilpo Järvinen wrote:
> > On Thu, 7 May 2009, Matthias Andree wrote:
> > > I've applied the following patch to net/ipv4/tcp.c for the kernel
> > > running on my server (2.6.29-rc8):
> > > @@ -1499,8 +1499,9 @@ do_prequeue:
> > >    		}
> > >    		if ((flags & MSG_PEEK) && peek_seq != tp->copied_seq) {
> > >    			if (net_ratelimit())
> > > -				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK.\n",
> > > -				       current->comm, task_pid_nr(current));
> > > +				printk(KERN_DEBUG "TCP(%s:%d): Application bug, race in MSG_PEEK: %x, %x.\n",
> > > +				       current->comm, task_pid_nr(current)),
> > > +				       peek_seq, tp->copied_seq;
> >
> > I cannot resist myself from noting that this certainly wasn't the patch
> > one got those printks below... It might happily compile though :-).
> 
> Can you please elaborate why you think that? It may be horribly broken
> (I've never claimed to be a C coder, and probably never will), but it
> also really is the patch that generates the printks...

...This was mainly meant to be a joke... :-)

The parenthesis won't match how a printk with string and 4 args should 
be called, so with this version you have in the mail peek_seq and 
tp->copied_seq are not put into stack or you were just super lucky.

> > >    			peek_seq = tp->copied_seq;
> > >    		}
> > >    		continue;
> > >
> > > So, the values you see at the end of the warning are peek_seq and
> > > tp->copied_seq. This gives messages like:
> > > kernel: TCP(fetchmail:9311): Application bug, race in MSG_PEEK: 156233, 16a.
> > > kernel: TCP(fetchmail:9311): Application bug, race in MSG_PEEK: 71259ac8, 5b4.
> > > kernel: TCP(fetchmail:31216): Application bug, race in MSG_PEEK: 833fe5, c0.
> 
> [...]
> 
> > What would you think about the following, untested patch... I suppose
> > it is enough to capture the racy situations except with that crazy urg
> > hole, grr (I suppose that will need just another variable to do the
> > offset of one).
> 
> I'll give your patch a try and report back.

Thanks. If it works I can add that urg hole madness handling too there.

-- 
 i.
---696208474-39249334-1241722096=:15149--
