From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH 3/3] mlsxfrm: Various fixes
Date: Wed, 8 Nov 2006 13:17:05 -0600
Message-ID: <000701c7036a$7b269010$cc0a010a@tcssec.com>
References: <1163007248.12241.58.camel@moss-spartans.epoch.ncsc.mil>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Paul Moore" <paul.moore@hp.com>, <netdev@vger.kernel.org>,
	<selinux@tycho.nsa.gov>, <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:63648 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161704AbWKHTRY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 14:17:24 -0500
To: "'Stephen Smalley'" <sds@tycho.nsa.gov>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>
In-Reply-To: <1163007248.12241.58.camel@moss-spartans.epoch.ncsc.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > >  Not sure
> > > though when
> > > that would apply here,
> >
> > It could apply to xfrms if they happen to be using the context
> > represented by any of the initial SIDs.
>
> Which would happen when?

If one were attempting to use a context pertaining to the unlabeled init
sid in the SPD and/or the SAD. But would I be correct in assuming that the
same sid (unlabeled init sid in all likelyhood) would end up being returned
when the context is turned into a sid, resulting in the SPD and the SAD
using
the same init sid, thus making a full-context compare unnecessary?

>
> > > and it would only apply if both SIDs
> > > were initial
> > > SIDs.
> >
> > OK. Will narrow the full context comparison to just this case.
>
> What's the harm from just using the SID comparison and
> allowing for the
> possibility that there might be a few duplicates in rare
> circumstances?
> Does it break any assumptions in the rest of the logic?

The best I can think of is if the SA's sid doesn't match the
socket's SID, IKE would come into play, if it's configured.

I also wanted to conversely ask what harm exists if we did
a full-context compare in the event the sids didn't match?

Are we just trying to generally avoid extra code?

