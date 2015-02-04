From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 2/3] genetlink: disallow subscribing to unknown mcast groups
Date: Wed, 04 Feb 2015 16:55:42 +0100
Message-ID: <874mr1isch.fsf@nemi.mork.no>
References: <1421404634-8973-1-git-send-email-johannes@sipsolutions.net>
	<1421404634-8973-2-git-send-email-johannes@sipsolutions.net>
	<87egq5uc07.fsf@nemi.mork.no> <87d25pit90.fsf@nemi.mork.no>
	<1423064608.4741.6.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>,
	Sedat Dilek <sedat.dilek@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53214 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932451AbbBDP4B convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 10:56:01 -0500
In-Reply-To: <1423064608.4741.6.camel@sipsolutions.net> (Johannes Berg's
	message of "Wed, 04 Feb 2015 16:43:28 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg <johannes@sipsolutions.net> writes:

> On Wed, 2015-02-04 at 16:36 +0100, Bj=C3=B8rn Mork wrote:
>
>> >> -	int i, err =3D 0;
>> >> +	int i, err =3D -ENOENT;
>> >> =20
>> >>  	down_read(&cb_lock);
>> >>  	for (i =3D 0; i < GENL_FAM_TAB_SIZE; i++) {
>> >
>> > This change cause serious problems for acpid, as reported on
>> > https://bugzilla.kernel.org/show_bug.cgi?id=3D92121
>>=20
>> Ah, I see this bug is already fixed by commit 8b7c36d810c6 ("netlink=
:
>> fix wrong subscription bitmask to group mapping in").  Your change w=
as
>> obviously correct, and found the long standing off by one bug.  Than=
ks.
>>=20
>> Sorry about the noise.  I should have checked the current "net" firs=
t.
>
> Interesting. I was completely willing to entertain the notion that so=
me
> userspace might be broken and be attempting to subscribe to a (static
> through the hacks we had to put in or "I think I know it already")
> group.

Me to.  So I went through the whole loop, checking that acpid did
everything by the book, adding a debug message to genl_bind() only to
see that it was called with '1' instead of the expected '2'.  Then
looking at af_netlink.c and its history. Etc.

> Have you checked acpid with the bitmap fix?

No, not yet. But I went down far enough into this that I actually wrote
the exact same patch as Pablo. Had to scratch my head when I couldn't
cherry-pick it into net because it was already there :-)

So I am pretty sure Pablo's patch fixes the problem.

This was never noticed before because there are only two users,
netfilter and generic netlink,  and both were willing to accept the
off-by-one values without much fuzz.


Bj=C3=B8rn
