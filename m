From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Tue, 22 Dec 2009 15:41:43 -0500
Message-ID: <4B312F07.6090609@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <20091218215107.GA14946@elte.hu> <4B2F9582.5000002@gmail.com> <4B2F978D.7010602@redhat.com> <4B2F9C85.7070202@gmail.com> <4B2FA42F.3070408@codemonkey.ws> <4B2FA655.6030205@gmail.com> <4B2FAE7B.9030005@codemonkey.ws> <4B2FB3F1.5080808@gmail.com> <4B300EF8.8010602@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigFF5A92A3F19CFAF8937F88FA"
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f211.google.com ([209.85.217.211]:59499 "EHLO
	mail-gx0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbZLVUlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 15:41:49 -0500
In-Reply-To: <4B300EF8.8010602@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigFF5A92A3F19CFAF8937F88FA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/21/09 7:12 PM, Anthony Liguori wrote:
> On 12/21/2009 11:44 AM, Gregory Haskins wrote:
>> Well, surely something like SR-IOV is moving in that direction, no?
>>   =20
>=20
> Not really, but that's a different discussion.

Ok, but my general point still stands.  At some level, some crafty
hardware engineer may invent something that obsoletes the
need for, say, PV 802.x drivers because it can hit 40GE line rate at the
same performance level of bare metal with some kind of pass-through
trick.  But I still do not see that as an excuse for sloppy software in
the meantime, as there will always be older platforms, older IO cards,
or different IO types that are not benefactors of said hw based
optimizations.

>=20
>>> But let's focus on concrete data.  For a given workload,
>>> how many exits do you see due to EOI?
>>>     =20
>> Its of course highly workload dependent, and I've published these
>> details in the past, I believe.  Off the top of my head, I recall that=

>> virtio-pci tends to throw about 65k exits per second, vs about 32k/s f=
or
>> venet on a 10GE box, but I don't recall what ratio of those exits are
>> EOI.
>=20
> Was this userspace virtio-pci or was this vhost-net?

Both, actually, though userspace is obviously even worse.

>  If it was the
> former, then were you using MSI-X?

MSI-X

>  If you weren't, there would be an
> additional (rather heavy) exit per-interrupt to clear the ISR which
> would certainly account for a large portion of the additional exits.
>

Yep, if you don't use MSI it is significantly worse as expected.


>>    To be perfectly honest, I don't care.  I do not discriminate
>> against the exit type...I want to eliminate as many as possible,
>> regardless of the type.  That's how you go fast and yet use less CPU.
>>   =20
>=20
> It's important to understand why one mechanism is better than another. =


Agreed, but note _I_ already understand why.  I've certainly spent
countless hours/emails trying to get others to understand as well, but
it seems most are too busy to actually listen.


> All I'm looking for is a set of bullet points that say, vbus does this,=

> vhost-net does that, therefore vbus is better.  We would then either
> say, oh, that's a good idea, let's change vhost-net to do that, or we
> would say, hrm, well, we can't change vhost-net to do that because of
> some fundamental flaw, let's drop it and adopt vbus.
>=20
> It's really that simple :-)

This is all been covered ad-nauseam, directly with youself in many
cases.  Google is your friend.

Here are some tips while you research:  Do not fall into the trap of
vhost-net vs vbus, or venet vs virtio-net, or you miss the point
entirely.  Recall that venet was originally crafted to demonstrate the
virtues of my three performance objectives (kill exits, reduce exit
overhead, and run concurrently). Then there is all the stuff we are
laying on top, like qos, real-time, advanced fabrics, and easy adoption
for various environments (so it doesn't need to be redefined each time).

Therefore if you only look at the limited feature set of virtio-net, you
will miss the majority of the points of the framework.  virtio tried to
capture some of these ideas, but it missed the mark on several levels
and was only partially defined.  Incidentally, you can stil run virtio
over vbus if desired, but so far no one has tried to use my transport.

>=20
>=20
>>>   They should be relatively rare
>>> because obtaining good receive batching is pretty easy.
>>>     =20
>> Batching is poor mans throughput (its easy when you dont care about
>> latency), so we generally avoid as much as possible.
>>   =20
>=20
> Fair enough.
>=20
>>> Considering
>>> these are lightweight exits (on the order of 1-2us),
>>>     =20
>> APIC EOIs on x86 are MMIO based, so they are generally much heavier th=
an
>> that.  I measure at least 4-5us just for the MMIO exit on my Woodcrest=
,
>> never mind executing the locking/apic-emulation code.
>>   =20
>=20
> You won't like to hear me say this, but Woodcrests are pretty old and
> clunky as far as VT goes :-)

Fair enough.

>=20
> On a modern Nehalem, I would be surprised if an MMIO exit handled in th=
e
> kernel was muck more than 2us.  The hardware is getting very, very
> fast.  The trends here are very important to consider when we're lookin=
g
> at architectures that we potentially are going to support for a long ti=
me.

The exit you do not take will always be infinitely faster.

>=20
>>> you need an awfully
>>> large amount of interrupts before you get really significant performa=
nce
>>> impact.  You would think NAPI would kick in at this point anyway.
>>>
>>>     =20
>> Whether NAPI can kick in or not is workload dependent, and it also doe=
s
>> not address coincident events.  But on that topic, you can think of
>> AlacrityVM's interrupt controller as "NAPI for interrupts", because it=

>> operates on the same principle.  For what its worth, it also operates =
on
>> a "NAPI for hypercalls" concept too.
>>   =20
>=20
> The concept of always batching hypercalls has certainly been explored
> within the context of Xen.

I am not talking about batching, which again is a poor mans throughput
trick at the expense of latency.  This literally is a "NAPI" like
signaled/polled hybrid, just going in the south direction.

>  But then when you look at something like
> KVM's hypercall support, it turns out that with sufficient cleverness i=
n
> the host, we don't even bother with the MMU hypercalls anymore.
>=20
> Doing fancy things in the guest is difficult to support from a long ter=
m
> perspective.  It'll more or less never work for Windows and even the la=
g
> with Linux makes it difficult for users to see the benefit of these
> changes.  You get a lot more flexibility trying to solve things in the
> host even if it's convoluted (like TPR patching).
>=20
>>> Do you have data demonstrating the advantage of EOI mitigation?
>>>     =20
>> I have non-scientifically gathered numbers in my notebook that put it =
on
>> average of about 55%-60% reduction in EOIs for inbound netperf runs, f=
or
>> instance.  I don't have time to gather more in the near term, but its
>> typically in that range for a chatty enough workload, and it goes up a=
s
>> you add devices.  I would certainly formally generate those numbers wh=
en
>> I make another merge request in the future, but I don't have them now.=

>>   =20
>=20
> I don't think it's possible to make progress with vbus without detailed=

> performance data comparing both vbus and virtio (vhost-net).  On the
> virtio/vhost-net side, I think we'd be glad to help gather/analyze that=

> data.  We have to understand why one's better than the other and then w=
e
> have to evaluate whether we can bring those benefits into the later.  I=
f
> we can't, we merge vbus.  If we can, we fix virtio.

You will need apples to apples to gain any meaningful data, and that
means running both on the same setup on the same base kernel, etc.  My
trees and instructions on how to run them referenced are on the
alacrityvm site.  I can probably send you a quilt series for any recent
kernel you may wish to try if the git tree is not sufficient.

Note that if you enable zero-copy (which is on by default), you may want
to increase the guests wmem buffers since the transmit buffer reclaim
path is longer and you can artificially stall the guest side stack.
Generally 1MB-2MB should suffice.  Otherwise just disable zero-copy with
"echo 0 > /sys/vbus/devices/$dev/zcthresh" on the host.

After you try basic tests, try lots of request-response and multi-homed
configurations, and watch your exit and interrupt rates as you do so, in
addition to the obvious metrics.

Good luck, and of course ping me with any troubles getting it to run.

Kind Regards,
-Greg


--------------enigFF5A92A3F19CFAF8937F88FA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAksxLwcACgkQP5K2CMvXmqGq7wCcCeDUsWcn778bqmyD6IwBEkRc
ZjoAnj6hsy+f/nVMtzTbUA2CWjwJ+ih8
=3l3w
-----END PGP SIGNATURE-----

--------------enigFF5A92A3F19CFAF8937F88FA--
