From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 11 May 2009 17:57:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905111656450.10088@wrl-59.cs.helsinki.fi>
References: <200902262310.12791.elendil@planet.nl> <200905111450.06749.elendil@planet.nl>
 <Pine.LNX.4.64.0905111556300.10088@wrl-59.cs.helsinki.fi>
 <200905111554.50118.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-619232803-1242051619=:10088"
Cc: Matthias Andree <matthias.andree@gmx.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Frans Pop <elendil@planet.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38544 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753209AbZEKO5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 10:57:14 -0400
In-Reply-To: <200905111554.50118.elendil@planet.nl>
Content-ID: <Pine.LNX.4.64.0905111725200.10088@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-619232803-1242051619=:10088
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0905111725201.10088@wrl-59.cs.helsinki.fi>

On Mon, 11 May 2009, Frans Pop wrote:

> On Monday 11 May 2009, Ilpo Järvinen wrote:
> > On Mon, 11 May 2009, Frans Pop wrote:
> > > On Monday 11 May 2009, Ilpo Järvinen wrote:
> > > > I took my time to fix the urg_hole madness too. The patch below.
> > >
> > > Hmm. I wonder if it wouldn't be better to keep the two issues
> > > separate. The initial patch is a clear regression fix (4 people have
> > > reported it against fetchmail for Debian). The URG part is IMO a
> > > separate issue which I at least have never seen in practice.
> > > And my Tested-by doesn't cover the additional change either.
> >
> > Disagreed. It's true that your testing very likely doesn't cover such a
> > corner case. The URG thing is legacy which shouldn't exist anymore but
> > it might still be that some people are crazy enough to use URG not
> > inline (and at the same time are doing MSG_PEEK too). However, that URG
> > part is not a _separate_ issue, you might not just have a test case but
> > it happens due to the very same reason and was broken by the very same
> > commit.
> 
> OK. I understood that there's always been a corner case with URG that 
> could cause incorrect messages [1] and I thought the additional change 
> was to fix that, but if this is related to the same regression then of 
> course it's fine by me.
> 
> [1] http://linux.derkeiler.com/Mailing-Lists/Kernel/2003-09/6009.html

Ah, so there's some urg race for real... ...I didn't know about that
which is no wonder since I've very little interest on knowing all
corner cases of urg madness really :-).

I guess it is not exactly the same though I have problem in understanding 
what Dave is exactly meaning there but it could well be that there isn't 
a sane case where the urg hole thing matters for real. Well, Dave probably 
knows whether the v2 is necessary or not, I've no clue who is the one 
advancing the copied_seq (if it's not the gem in tcp_check_urg doing the 
conditional copied_seq++, but that condition is beyond my current level of 
concentration really).

> > This issue has nothing to do with fetchmail or so alone (regardless of
> > how many bugs have been filed against it), it's generic TCP (in kernel)
> > issue, whether it's triggered is just about right test pattern which
> > here happens with fetchmail but it is by no means limited to it.
> 
> I never claimed that. In fact, I was the one who also saw the issue with 
> other applications (wget, IMAP)...
> 
> > I don't care too much if distro people have some local policies
> > regarding fixes and that here shouldn't be a bother to them anyway
> > since there's the more limited fix available in the archives too if
> > they specifically want that.
> 
> Where did that come from? Not from anything I said...

Hmm... Referring to some distro bug reports to strengthen the separate 
problems argument caused the impression, I'm sorry about that :-).


-- 
 i.
---696208474-619232803-1242051619=:10088--
