From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast
 groups
Date: Wed, 04 Feb 2015 16:43:28 +0100
Message-ID: <1423064608.4741.6.camel@sipsolutions.net>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	 <1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
	 <87egq5uc07.fsf@nemi.mork.no> <87d25pit90.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55035 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932877AbbBDPnc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 10:43:32 -0500
In-Reply-To: <87d25pit90.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-02-04 at 16:36 +0100, Bj=C3=B8rn Mork wrote:

> >> -	int i, err =3D 0;
> >> +	int i, err =3D -ENOENT;
> >> =20
> >>  	down_read(&cb_lock);
> >>  	for (i =3D 0; i < GENL_FAM_TAB_SIZE; i++) {
> >
> > This change cause serious problems for acpid, as reported on
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D92121
>=20
> Ah, I see this bug is already fixed by commit 8b7c36d810c6 ("netlink:
> fix wrong subscription bitmask to group mapping in").  Your change wa=
s
> obviously correct, and found the long standing off by one bug.  Thank=
s.
>=20
> Sorry about the noise.  I should have checked the current "net" first=
=2E

Interesting. I was completely willing to entertain the notion that some
userspace might be broken and be attempting to subscribe to a (static
through the hacks we had to put in or "I think I know it already")
group.

Have you checked acpid with the bitmap fix?

johannes
