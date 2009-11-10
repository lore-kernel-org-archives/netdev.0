From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 11:49:37 -0500
Message-ID: <4AF999A1.80509@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <alpine.DEB.2.00.0911100659470.7059@melkinpaasi.cs.helsinki.fi> <4AF96D71.8000905@gmail.com> <alpine.DEB.2.00.0911101605050.20637@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Joe Perches <joe@perches.com>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:49970 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756909AbZKJQti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 11:49:38 -0500
Received: by bwz27 with SMTP id 27so215986bwz.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 08:49:43 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.0911101605050.20637@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> After some time I returned to it. My apologies for my previous harsh=20
> response. My point was to say that you must separate such changes bec=
ause=20
> they add to noise which makes it rather annoying to review. At least =
my=20
> brains are rather limited still in keeping track of different things.
>=20
Apology accepted.

I'd think we agree, and that's why I wouldn't go around fixing all the
misspelled comments -- just those in the code I'm actually revising.


>> This *is* actually in CodingStyle (line 679), and I'm trying to conf=
orm:
>=20
> Sure, fell free to but not in some random places like you now do in t=
his=20
> patch. If you are not touching a line because of a real change and wa=
nt do=20
> a syntax cleanup, please do it in another patch. Especially when your=
=20
> actual change is as complicated as this is.
>=20
Not a single one is in a random place.


>>> ...Also some comment changes which certainly are not mandatory nor =
even
>>> related.
>>>
>> 1) The first is a hole left by the removal of the data fields some t=
ime
>> ago, but they left the old (now incorrect) comment:
>>
>> -/*	SACKs data	*/
>> +	u8	cookie_plus:6,	/* bytes in authenticator/cookie option	*/
>> +		cookie_out_never:1,
>> +		cookie_in_always:1;
>>  	u8	num_sacks;	/* Number of SACK blocks		*/
>>...
> I'm sorry but this response tells me that you don't seem to know even=
=20
> yourself what you were submitting. Does this ring a bell:
>=20
> -       if (th->doff =3D=3D sizeof(struct tcphdr) >> 2) {
> +       /* In the spirit of fast parsing, compare doff directly to sh=
ifted
> +        * constant values.  Because equality is used, short doff can=
 be
> +        * ignored here, and checked later.
> +        */
> +       if (th->doff =3D=3D (sizeof(*th) >> 2)) {
>=20
Ah, it's become apparent that you didn't click through to any of the
references, internet-drafts, or mailing list discussion, so you don't
know what this patch series is implementing.

One of the great difficulties in tracking down all several hundred uses
of doff -- and functions that use doff -- is the serious deficiency of
comments (compared to other code bases).

Oh yeah -- Miller says I'm anal.  This is TCP.  Strict scrutiny is much
better than the alternative.


> Besides, I don't understand even what you're trying to say. ...I thin=
k we=20
> already checked the length in tcp_v[46]_rcv against underflow. Why yo=
u add=20
> such a non-sense comment here (plus the sizeof change I covered=20
> elsewhere)? This is just a noise to annoy reviewer, nothing else.
>=20
You merely think?  You don't know?  (I didn't find one on the code walk
through that got me to this point in the code, but perhaps I missed
something.)  If that's the case, there should at least be a comment tha=
t
underflow was already checked, and *where* it was checked!

The lack of pertinent comments and error checking annoys the next coder
that comes down the pike.


>> 2) The second is a spelling error that I noticed in passing.  It's w=
ithin
>> the same diff -u area (close to other insertions both before and aft=
er), so
>> fixing it was trivial:
>>
>> - * to increse this, although since:
>> + * to increase this, although since:
>>
>> Are we not supposed to fix spelling errors in comments?
>=20
> How many extra lines a reviewer has to read because of that? Why not =
do it=20
> in a separate patch. git add -i / git stash would help you there. ...=
To be=20
> honest, I'd rather have typos in comments which like this are not=20
> trouble for the reader than clutter feature patches with all this ran=
dom=20
> junk.
>=20
I'll have to look up the usage of git add -i / git stash, but in any ca=
se,
I'm not likely to go around fixing comments later.

Each patch requires a great deal of time.  I'd rather combine such thin=
gs,
or not do them at all.


> ...I really wish that next time when you submit you get rid of all th=
ese=20
> showstoppers and annoyances (ie., at least honestly try to do your be=
st)
> that we could finally concentrate to the actual change and reviewing
> that :-). My recommendation is that before hitting the send button yo=
u=20
> review (read through) your own patches, and if you find something to=20
> correct instead of submitting, postpone that until the problem is sol=
ved.=20
> Like DaveM once noted somebody, you'll not be timed :-). ...I usually=
 do=20
> that (read my own patches) and end up rather often to not submit (and=
 find=20
> even real bugs that way quite often).
>=20
Maybe you've been dealing too much with some folks that submitted a pat=
ch
that was accepted (over my expressed reservations), and then had to sen=
d
out 2 emergency patches to handle crashing bugs last week....

Before I send any patch, it's been compared against my last patch sent,
*and* tested for compilation individually, *and* _usually_ tested prett=
y
thoroughly -- although not this time, because the net-next-2.6 modules
don't compile, as I warned at the head of this patch series.

Because the compile blew up, I actually spent my Sunday evening
re-reviewing the patches again!  I wanted to ensure it wasn't something
that I'd done, so I recompiled everything again incrementally.

It took me more than a day to make the syntax changes requested, and
another 6 hours to prepare and send these 5 patches.

I cannot promise there will never be any bugs, this patch series will b=
e
much too complicated for that, but the very idea that I'd send without
reviewing....  At this point, I'm rather personally insulted.

And now I'm done with email for the day.  I'll do the split that Eric
suggested, and send it out whenever the damn modules compile again.

In the meantime, I'd appreciate that you "finally concentrate"....
