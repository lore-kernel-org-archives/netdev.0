From: Andrew Lutomirski <luto@mit.edu>
Subject: Re: AAARGH bisection is hard (Re: [2.6.39 regression] X locks up hard
 right after logging in)
Date: Fri, 13 May 2011 14:55:03 -0400
Message-ID: <BANLkTi=dFhxWHHPiYi6P7Mn45J7dZXn=AQ@mail.gmail.com>
References: <BANLkTi=kb_m-CfrpnD8qQTVYLGaDdgy_tg@mail.gmail.com>
 <BANLkTikMeyRTOB9q4PEAYWnZRZfk3wg=kQ@mail.gmail.com> <BANLkTi=dL+KyQ3Bm58_Uj4LP9WSpbzAfJA@mail.gmail.com>
 <BANLkTi=NdVUUZ=_bACzyeMGS3JWs0EMbWA@mail.gmail.com> <BANLkTimE2GkkhcFZtNrYZASWp0LDhUx=GQ@mail.gmail.com>
 <BANLkTinyzBnksHk_rt8K2pmg90q5WyZX3w@mail.gmail.com> <BANLkTinVT=9+-HhwXcyLBwrnhX9F9Qz3ww@mail.gmail.com>
 <4DCD79A0.7000500@kdbg.org> <BANLkTi=smoaARKyzWxFjid-E7qehmyAX8w@mail.gmail.com>
 <7vliya77xl.fsf@alter.siamese.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Johannes Sixt <j6t@kdbg.org>,
	Christian Couder <christian.couder@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	git@vger.kernel.org, Shuang He <shuang.he@intel.com>
To: Junio C Hamano <gitster@pobox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7vliya77xl.fsf@alter.siamese.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 2:48 PM, Junio C Hamano <gitster@pobox.com> wro=
te:
> Linus Torvalds <torvalds@linux-foundation.org> writes:
>
>> When you say that v2.6.38 is good, that means that everything that c=
an
>> be reached from 2.6.38 is good.
>>
>> NOT AT ALL the same thing as "git bisect requires v2.6.38" would be.
>>
>> The "requires v2.6.38" would basically say that anything that doesn'=
t
>> contain v2.6.38 is "off-limits". It's fine to call them "good", but
>> that's not the same thing as "git bisect good v2.6.38".
>>
>> Why?
>>
>> Think about it. It's the "reachable from v2.6.38" vs "cannot reach
>> v2.6.38" difference. That's a HUGE difference.
>
> Could you please clarify "off-limits"?
>
> Do you mean "anything before v2.6.38 did not even have this feature, =
so
> the result of testing a version in that range does not give us any
> information"? =A0The feature didn't even exist, so a bug can never tr=
igger,
> and seeing "good" from such a version does not mean everything reacha=
ble
> from it is good? =A0Upon seeing "bad" result from a version before v2=
=2E6.38,
> what can we conclude? =A0The breakage cannot possibly come from the f=
eature
> that is being checked, so the procedure to check itself is busted?
>

In my case, if I'd given bisect a hint that commits that don't include
v2.6.38 are unlikely to work for reasons unrelated to the bug, then
there should still have been enough revisions left for bisect to tell
me "the bug was introduced by the merge of the drm tree but I can't
tell you more without testing off-limits revisions".  That would have
avoided testing three or four revisions that just failed to boot.

In my particular case I think it would also have avoided an
unnecessary set of tests to figure out why the networking merge broke
my system when the networking merge did not, in fact, break my system.
 This is coincidence -- all of the commits that didn't have the change
that fixed the bug the first time around also didn't contain v2.6.38,
so I never would have tested them.

This is maybe some further justification for a bisect mode that
follows the --first-parent path as long as possible -- it might take
one or two more kernel builds, but it avoids odd trips around the
history that can hit random crap like that.  (Of course, it could lead
to different random crap, but what can you do?)

--Andy

--Andy

>
>
