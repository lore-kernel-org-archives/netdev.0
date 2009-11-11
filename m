From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Wed, 11 Nov 2009 03:48:19 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911110332460.2864@melkinpaasi.cs.helsinki.fi>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi> <4AF96D71.8000905@gmail.com> <alpine.DEB.2.00.0911101605050.20637@melkinpaasi.cs.helsinki.fi> <4AF999A1.80509@gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-1132304469-1257904100=:2864"
Cc: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48114 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756333AbZKKBsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 20:48:15 -0500
In-Reply-To: <4AF999A1.80509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1132304469-1257904100=:2864
Content-Type: TEXT/PLAIN; charset=iso-8859-15
Content-Transfer-Encoding: 8BIT

On Tue, 10 Nov 2009, William Allen Simpson wrote:

> Ilpo Järvinen wrote:
> 
> > > This *is* actually in CodingStyle (line 679), and I'm trying to conform:
> > 
> > Sure, fell free to but not in some random places like you now do in this
> > patch. If you are not touching a line because of a real change and want do a
> > syntax cleanup, please do it in another patch. Especially when your actual
> > change is as complicated as this is.
> > 
> Not a single one is in a random place.

I disagree.

> > > > ...Also some comment changes which certainly are not mandatory nor even
> > > > related.
> > > > 
> > > 1) The first is a hole left by the removal of the data fields some time
> > > ago, but they left the old (now incorrect) comment:
> > > 
> > > -/*	SACKs data	*/
> > > +	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
> > > +		cookie_out_never:1,
> > > +		cookie_in_always:1;
> > >  	u8	num_sacks;	/* Number of SACK blocks		*/
> > > ...
> > I'm sorry but this response tells me that you don't seem to know even
> > yourself what you were submitting. Does this ring a bell:
> > 
> > -       if (th->doff == sizeof(struct tcphdr) >> 2) {
> > +       /* In the spirit of fast parsing, compare doff directly to shifted
> > +        * constant values.  Because equality is used, short doff can be
> > +        * ignored here, and checked later.
> > +        */
> > +       if (th->doff == (sizeof(*th) >> 2)) {
> > 
> Ah, it's become apparent that you didn't click through to any of the
> references, internet-drafts, or mailing list discussion, so you don't
> know what this patch series is implementing.

Sure, I'll find that out from your patches instead, and it will be more 
definitive than what the specs say ;-).

> One of the great difficulties in tracking down all several hundred uses
> of doff -- and functions that use doff -- is the serious deficiency of
> comments (compared to other code bases).
> 
> Oh yeah -- Miller says I'm anal.  This is TCP.  Strict scrutiny is much
> better than the alternative.
> 
> 
> > Besides, I don't understand even what you're trying to say. ...I think we
> > already checked the length in tcp_v[46]_rcv against underflow. Why you add
> > such a non-sense comment here (plus the sizeof change I covered elsewhere)?
> > This is just a noise to annoy reviewer, nothing else.
> > 
> You merely think?  You don't know?

Let me say it out loud then. I know that among the very first things we 
check is this underflow check. I quoted is below.

> (I didn't find one on the code walk
> through that got me to this point in the code, but perhaps I missed
> something.)  If that's the case, there should at least be a comment that
> underflow was already checked, and *where* it was checked!

You added a comment which says neither but something else? :-D I wonder 
how trustworthy such comment then would be to that poor "next coder" that 
comes along ;-).

> The lack of pertinent comments and error checking annoys the next coder
> that comes down the pike.

This is something I can hardly understand... these are among the first 
things we check before we even begin processing a TCP segment:

        if (!pskb_may_pull(skb, sizeof(struct tcphdr)))
                goto discard_it;

        th = tcp_hdr(skb);

        if (th->doff < sizeof(struct tcphdr) / 4)
                goto bad_packet;
        if (!pskb_may_pull(skb, th->doff * 4))
                goto discard_it;

> > > 2) The second is a spelling error that I noticed in passing.  It's within
> > > the same diff -u area (close to other insertions both before and after),
> > > so
> > > fixing it was trivial:
> > > 
> > > - * to increse this, although since:
> > > + * to increase this, although since:
> > > 
> > > Are we not supposed to fix spelling errors in comments?
> > 
> > How many extra lines a reviewer has to read because of that? Why not do it
> > in a separate patch. git add -i / git stash would help you there. ...To be
> > honest, I'd rather have typos in comments which like this are not trouble
> > for the reader than clutter feature patches with all this random junk.
> > 
> I'll have to look up the usage of git add -i / git stash, but in any case,
> I'm not likely to go around fixing comments later.

With git add -i you can change them while you go but easily split them on 
before commit time to multiple patches. Rather easy unless except if you 
you're also modifying the line right next or before to the comment it.

-- 
 i.
---696230645-1132304469-1257904100=:2864--
