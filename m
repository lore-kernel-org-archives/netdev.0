From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH for-next V7 00/10] Move RoCE GID management to IB/Core
Date: Fri, 31 Jul 2015 13:41:39 -0400
Message-ID: <55BBB353.7020806@redhat.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
 <CAJ3xEMh9z=LG7dW0nBP8Zdrbf0SkZ_GCxjCoowWXuw2dueN+xg@mail.gmail.com>
 <55BB6F10.5030408@redhat.com> <20150731163201.GA6027@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="d77IvaDpsdjCoV7BHrQNMsfMirxMNFRwE"
Cc: Or Gerlitz <gerlitz.or-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Somnath Kotur <Somnath.Kotur-1wcpHE2jlwO1Z/+hSey0Gg@public.gmane.org>,
	Moni Shoua <monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150731163201.GA6027-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--d77IvaDpsdjCoV7BHrQNMsfMirxMNFRwE
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 07/31/2015 12:32 PM, Jason Gunthorpe wrote:
> On Fri, Jul 31, 2015 at 08:50:24AM -0400, Doug Ledford wrote:
>=20
>>> So... are we ready to go with V7 upstream?
>>
>> Yes.  I've already pulled it in.
>=20
> You are taking the netdev stuff without an ack from netdev??

I've pulled it in, yes.  Dave Miller/netdev needs to ack it still.  I
really doubt they will object to the 1st or 3rd patch, but they might
have comments on the second.  Since they weren't copied on the original
submission, I'll be pinging them separately.  Dave may prefer if they go
through his tree, and that's fine, but I still need them in my tree as
of now for testing purposes.

> I've been too busy too look at v7, but a quick check of the 'move the
> cache into core code stuff' looks wrong to
> me. ib_unregister_event_handler and flush_workqueue should not/can not =
be
> called from a kref free'r.

Please be more specific here.  What are you objecting to?  Are you
objecting to a flush_workqueue from a release() context?  Because I
don't see anything in the kref documentation or the kref implementation
that prevents or prohibits this.  Or are you referring to the fact that
they aren't unregistering their event handler until well after the
parent device is unregistered?  That's obviously wrong, but it's also
easy to fix (the obvious fix is that they should be calling
ib_cache_cleanup_one from the top of ib_unregister_device versus waiting
for a kref put).

Regardless though, the reason I'm taking this (and a number of other
things) into my tree is that waiting for things to be absolutely perfect
on a submission is an interminable waiting game.  We have about 3 weeks
or maybe a little more until the next merge window opens.  In that time,
doing v8 of this patchset, and v9 of that patchset, and v5 of another
patchset all gets to be a huge bog on everyone's time.  These various
patchsets have reached the point where they are close and incremental
patches would be better than resubmitting the entire patchset over and
over again.  Not to mention that some of these fixes are quick and easy
to do and I'd rather quit waiting 24+ hours for a respin turnaround when
I could just hop in and make the fix myself in 15 minutes and test it
immediately.

> Looking at your for-rebase branch.. please make sure you get all the
> attributions this cycle :|

Yet *another* reason why these v6, v7, v8 patchsets are a huge time
drain :-/.  For a 10 patch v7 patchset, I need to look through 70 patch
listings in patchworks and try to see which reviewers didn't get their
attribution carried forward, and on top of that I have to make a
judgment call about which reviewed-bys should or shouldn't get carried
forward based upon how much changed in the next patch and whether or not
a previous review is still relevant or has the patch changed enough that
it needs a new review?  Really, this is my only complaint about
patchworks.  Aside from attribution loss on resubmit, it works great.

Anyway, this thread brings up an important issue, scheduling for the 4.3
merge window.  I'll bring that up in a separate email later today.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
              GPG KeyID: 0E572FDD



--d77IvaDpsdjCoV7BHrQNMsfMirxMNFRwE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJVu7NTAAoJELgmozMOVy/dnPcP/0VIkBDihsdyTiYAuUS3V8h9
Xy+yvC/worqe4A/hrXaYyfgCrIwDOQnFHow2cBTKB/UOA9Wku1DRvHt53Y2ABiMn
owwCzSwuntucl3kb+IdZObo28Zo46Pry+zAqULjrWfdYG0jPiVrPtRPrnT5khOp1
i7nvyBjzWSxcaJNJL6aNp89d2q3Rw1AjkUyEWsiGoUCW9uI2yr16aEOarfbO4c1V
IMpK8rRewGSmbVkEoX/MatoZASbcv4Rr4So2sECYhq6i9oiLbzY4lBtzB3vQJ+g4
ld0uV2js+lR9vh6nJjr/WKuA1EAZLpYc/EV6u2pPq5ayUJgJunGshKTSnOto6Ucj
D6+txBgy1n3Wlq7+bxhlQhSvzsYvRS49xVJM3gG8+O4VCawjfqDFebV2ESxmowC5
0XZ5wgTtnjVQIz02jhLRbP3YJtheCArrghyP4rDF8kpNkuLtLnzdO5ImZz0M+lNM
5qi70w5YS7VTLF8mcnKYTsw3UUJoXVvULemkxWIGPqgFPczKT4KgkD0AABkaQmZk
b2tGJ98fctiD6ynv6XeprXVWyPLVPcdDPTgOO/UdWQEm+hySNYZbnq1ORHRROiyt
elEe0zlBtkrOuLFV7Sgguf9bDziS0awD45ltTNjQt+HKHyImj50ANDufBLEbKL7i
ZJ9KZx2quoz/hq70prQF
=3mRg
-----END PGP SIGNATURE-----

--d77IvaDpsdjCoV7BHrQNMsfMirxMNFRwE--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
