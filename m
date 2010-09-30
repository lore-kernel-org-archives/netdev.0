From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [RFC 1/2] genetlink: introduce pre_doit/post_doit hooks
Date: Fri, 1 Oct 2010 08:51:38 +1000
Message-ID: <AANLkTimVMGHNkK=o650qzZfvUp3mWRAG_=60etVbEBxh@mail.gmail.com>
References: <20100930211013.472957770@sipsolutions.net> <20100930211131.021309930@sipsolutions.net>
 <AANLkTik9+zA4PPPx=q6CRM-sgOjjECJdtJTgkCG9pGAY@mail.gmail.com>
 <1285886690.5137.28.camel@jlt3.sipsolutions.net> <1285886821.5137.29.camel@jlt3.sipsolutions.net>
 <1285886955.5137.31.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	tgraf@suug.ch
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62010 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755839Ab0I3Wv7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 18:51:59 -0400
In-Reply-To: <1285886955.5137.31.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 1, 2010 at 08:49, Johannes Berg <johannes@sipsolutions.net>=
 wrote:
> On Fri, 2010-10-01 at 00:47 +0200, Johannes Berg wrote:
>> On Fri, 2010-10-01 at 00:44 +0200, Johannes Berg wrote:
>> > On Fri, 2010-10-01 at 08:41 +1000, Julian Calaby wrote:
>> >
>> > > > =A0d) include two private pointers in each info
>> > > > =A0 =A0struct passed between all these operations
>> > > > =A0 =A0including doit(). (It's two because I'll
>> > > > =A0 =A0need two in nl80211 -- can be extended.)
>> > >
>> > > Stupid question:
>> > >
>> > > Why not have a priv struct rather than an arbitrary array of two=
 pointers?
>> >
>> > It'd have to be dynamically allocated, and the "arbitrary" array o=
f two
>> > pointers can be on the stack.
>>
>> Maybe I should elaborate -- a priv struct basically means just a sin=
gle
>> pointer, and then I'd have to allocate something to hold two pointer=
s in
>> nl80211 and assign it to that single pointer.
>
> Come to think of it -- I could get away with a single pointer, since,=
 if
> both are assigned,
>
> user_ptr[0] =3D=3D wiphy_to_rdev(((netdev *)user_ptr[1])->ieee80211_p=
tr->wiphy)
>
> but that's a lot of pointy things, and some functions only have the r=
dev
> so it gets more complex. I think allowing two private pointers is a
> decent compromise.

Come to think of it -- if someone wanted to have a massive structure
with 10 pointers and a set of random data structures, then they could
easily create their priv struct and assign it to user_ptr[0], hence
rendering my argument null and void.

Thanks,

--=20

Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
=2EPlan: http://sites.google.com/site/juliancalaby/
