From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 23:11:03 -0400
Message-ID: <49D42CC7.40705@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D406F8.40606@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7DFB3F42E436507F15B6D0BF"
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D406F8.40606@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7DFB3F42E436507F15B6D0BF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Gregory Haskins wrote:
>> Anthony Liguori wrote:
>>   I think there is a slight disconnect here.  This is *exactly* what
>> I am
>> trying to do.=20
>
> If it were exactly what you were trying to do, you would have posted a
> virtio-net in-kernel backend implementation instead of a whole new
> paravirtual IO framework ;-)

semantics, semantics ;)

but ok, fair enough.

>
>>> That said, I don't think we're bound today by the fact that we're in
>>> userspace.
>>>    =20
>> You will *always* be bound by the fact that you are in userspace.
>
> Again, let's talk numbers.  A heavy-weight exit is 1us slower than a
> light weight exit.  Ideally, you're taking < 1 exit per packet because
> you're batching notifications.  If you're ping latency on bare metal
> compared to vbus is 39us to 65us, then all other things being equally,
> the cost imposed by doing what your doing in userspace would make the
> latency be 66us taking your latency from 166% of native to 169% of
> native.  That's not a huge difference and I'm sure you'll agree there
> are a lot of opportunities to improve that even further.

Ok, so lets see it happen.  Consider the gauntlet thrown :)  Your
challenge, should you chose to accept it, is to take todays 4000us and
hit a 65us latency target while maintaining 10GE line-rate (at least
1500 mtu line-rate).

I personally don't want to even stop at 65.  I want to hit that 36us! =20
In case you think that is crazy, my first prototype of venet was hitting
about 140us, and I shaved 10us here, 10us there, eventually getting down
to the 65us we have today.  The low hanging fruit is all but harvested
at this point, but I am not done searching for additional sources of
latency. I just needed to take a breather to get the code out there for
review. :)

>
> And you didn't mention whether your latency tests are based on ping or
> something more sophisticated

Well, the numbers posted were actually from netperf -t UDP_RR.  This
generates a pps from a continuous (but non-bursted) RTT measurement.  So
I invert the pps result of this test to get the average rtt time.  I
have also confirmed that ping jives with these results (e.g. virtio-net
results were about 4ms, and venet were about 0.065ms as reported by ping)=
=2E

> as ping will be a pathological case
Ah, but this is not really pathological IMO.  There are plenty of
workloads that exhibit request-reply patterns (e.g. RPC), and this is a
direct measurement of the systems ability to support these
efficiently.   And even unidirectional flows can be hampered by poor
latency (think PTP clock sync, etc).

Massive throughput with poor latency is like Andrew Tanenbaum's
station-wagon full of backup tapes ;)  I think I have proven we can
actually get both with a little creative use of resources.

> that doesn't allow any notification batching.
Well, if we can take anything away from all this: I think I have
demonstrated that you don't need notification batching to get good
throughput.  And batching on the head-end of the queue adds directly to
your latency overhead, so I don't think its a good technique in general
(though I realize that not everyone cares about latency, per se, so
maybe most are satisfied with the status-quo).

>
>> I agree that the "does anyone care" part of the equation will approach=

>> zero as the latency difference shrinks across some threshold (probably=

>> the single microsecond range), but I will believe that is even possibl=
e
>> when I see it ;)
>>  =20
>
> Note the other hat we have to where is not just virtualization
> developer but Linux developer.  If there are bad userspace interfaces
> for IO that impose artificial restrictions, then we need to identify
> those and fix them.

Fair enough, and I would love to take that on but alas my
development/debug bandwidth is rather finite these days ;)

-Greg



--------------enig7DFB3F42E436507F15B6D0BF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknULMcACgkQlOSOBdgZUxk5VQCfY7eOTafUq3nd2uasXibIsyAR
gv4AnR9Cz5i/cyTtww8tGwybZRzEFfIT
=yZ2R
-----END PGP SIGNATURE-----

--------------enig7DFB3F42E436507F15B6D0BF--
