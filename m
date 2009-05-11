From: Frans Pop <elendil@planet.nl>
Subject: Re: [PATCH v2] tcp: fix MSG_PEEK race check
Date: Mon, 11 May 2009 15:54:48 +0200
Message-ID: <200905111554.50118.elendil@planet.nl>
References: <200902262310.12791.elendil@planet.nl> <200905111450.06749.elendil@planet.nl> <Pine.LNX.4.64.0905111556300.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Andree <matthias.andree@gmx.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpm-eml104.kpnxchange.com ([195.121.3.8]:55462 "EHLO
	CPSMTPM-EML104.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752384AbZEKNyu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 09:54:50 -0400
In-Reply-To: <Pine.LNX.4.64.0905111556300.10088@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 May 2009, Ilpo J=C3=A4rvinen wrote:
> On Mon, 11 May 2009, Frans Pop wrote:
> > On Monday 11 May 2009, Ilpo J=C3=A4rvinen wrote:
> > > I took my time to fix the urg_hole madness too. The patch below.
> >
> > Hmm. I wonder if it wouldn't be better to keep the two issues
> > separate. The initial patch is a clear regression fix (4 people hav=
e
> > reported it against fetchmail for Debian). The URG part is IMO a
> > separate issue which I at least have never seen in practice.
> > And my Tested-by doesn't cover the additional change either.
>
> Disagreed. It's true that your testing very likely doesn't cover such=
 a
> corner case. The URG thing is legacy which shouldn't exist anymore bu=
t
> it might still be that some people are crazy enough to use URG not
> inline (and at the same time are doing MSG_PEEK too). However, that U=
RG
> part is not a _separate_ issue, you might not just have a test case b=
ut
> it happens due to the very same reason and was broken by the very sam=
e
> commit.

OK. I understood that there's always been a corner case with URG that=20
could cause incorrect messages [1] and I thought the additional change=20
was to fix that, but if this is related to the same regression then of=20
course it's fine by me.

[1] http://linux.derkeiler.com/Mailing-Lists/Kernel/2003-09/6009.html

> This issue has nothing to do with fetchmail or so alone (regardless o=
f
> how many bugs have been filed against it), it's generic TCP (in kerne=
l)
> issue, whether it's triggered is just about right test pattern which
> here happens with fetchmail but it is by no means limited to it.

I never claimed that. In fact, I was the one who also saw the issue wit=
h=20
other applications (wget, IMAP)...

> I don't care too much if distro people have some local policies
> regarding fixes and that here shouldn't be a bother to them anyway
> since there's the more limited fix available in the archives too if
> they specifically want that.

Where did that come from? Not from anything I said...

> If you don't have URG holes, the v2 change yields to: -0 which equals
> to no-op. No testing is going to undo that :-). ...And that can be se=
en
> already from the patch context.

I'll still give the new patch a try on my next build :-)
The rest I happily leave up to you and David.

Thanks for clarifying.

Cheers,
=46JP
