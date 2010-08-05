From: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
Subject: Re: [PATCH RESEND block#for-2.6.36] block_dev: always serialize
 exclusive open attempts
Date: Thu, 5 Aug 2010 11:17:04 +0200
Message-ID: <20100805091704.GA1772@arch.tripp.de>
References: <2dWFdr9kTFM.A.P0D.spXVMB@chimera>
 <AANLkTimcH7+Bq1UEbaSU7SQpzArPgmSLegiqE13V8=CF@mail.gmail.com>
 <4C56F30D.3020304@kernel.org>
 <4C598E6B.7050405@gmail.com>
 <4C5A7E33.3060101@fusionio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tejun Heo <htejun-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Jens Axboe <jaxboe-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4C5A7E33.3060101-5c4llco8/ftWk0Htik3J/w@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 05, 2010 at 11:02:43AM +0200, Jens Axboe wrote:
> On 2010-08-04 17:59, Tejun Heo wrote:
> > bd_prepare_to_claim() incorrectly allowed multiple attempts for
> > exclusive open to progress in parallel if the attempting holders ar=
e
> > identical.  This triggered BUG_ON() as reported in the following bu=
g.
> >=20
> >   https://bugzilla.kernel.org/show_bug.cgi?id=3D16393
> >=20
> > __bd_abort_claiming() is used to finish claiming blocks and doesn't
> > work if multiple openers are inside a claiming block.  Allowing
> > multiple parallel open attempts to continue doesn't gain anything a=
s
> > those are serialized down in the call chain anyway.  Fix it by alwa=
ys
> > allowing only single open attempt in a claiming block.
> >=20
> > This problem can easily be reproduced by adding a delay after
> > bd_prepare_to_claim() and attempting to mount two partitions of a
> > disk.
> >=20
> > stable: only applicable to v2.6.35
> >=20
> > Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > Reported-by: Markus Trippelsdorf <markus-xp2qqqlHh3xzoYq+O6RWwA@public.gmane.org>
> > Cc: stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
>=20
> Thanks Tejun, applied.

It's already in mainline:
e75aa85892b2ee78c79edac720868cbef16e62eb

--=20
=BBA man who doesn't know he is in prison can never escape.=AB
William S. Burroughs
