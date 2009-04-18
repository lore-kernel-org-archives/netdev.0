From: leiming <tom.leiming@gmail.com>
Subject: Re: 2.6.30-rc2-git2: Reported regressions from 2.6.29
Date: Sat, 18 Apr 2009 10:32:26 +0800
Message-ID: <20090418103226.54250420@linux-lm>
References: <EJaiQ4Wfaz.A.3YG.4v85JB@chimera>
	<d82e647a0904161837w6b6fb652la0da05f9061e95dc@mail.gmail.com>
	<200904172336.12414.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Natalie Protasevich <protasnb@gmail.com>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	video4linux-list@redhat.com, laurent.pinchart@skynet.be,
	mchehab@infradead.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:59076 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690AbZDRCce convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 22:32:34 -0400
In-Reply-To: <200904172336.12414.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=D3=DA Fri, 17 Apr 2009 23:36:11 +0200
"Rafael J. Wysocki" <rjw@sisk.pl> =D0=B4=B5=C0:

> On Friday 17 April 2009, Ming Lei wrote:
> > 2009/4/17 Rafael J. Wysocki <rjw@sisk.pl>:
> > >
> > > Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D13=
125
> > > Subject         : active uvcvideo breaks over suspend
> > > Submitter       : Alan Jenkins <alan-jenkins@tuffmail.co.uk>
> > > Date            : 2009-04-15 10:12 (2 days old)
> > > References      :
> > > http://marc.info/?l=3Dlinux-kernel&m=3D123979009508840&w=3D4
> > >
> >=20
> > It is a bug in resume path of uvcvideo driver, and I have sent a
> > patch to laurent.pinchart@skynet.be,
> > mchehab@infradead.org  and video4linux-list@redhat.com to fix it,
> > but still no echo from them.
> >=20
> > The patch title is V4L/DVB:usbvideo:fix uvc resume failed.
> >=20
> > Rafael J.
> >         If you would like to apply it ,I can resend to you.  Thanks=
!
>=20
> Please resend.
>=20
> Rafael

=46rom 5715e310a939f3f7cd3e88eae8f25fedbb28def4 Mon Sep 17 00:00:00 200=
1
=46rom: Ming Lei <tom.leiming@gmail.com>
Date: Wed, 15 Apr 2009 22:32:51 +0800
Subject: [PATCH] V4L/DVB:usbvideo:fix uvc resume failed

Now urb buffers is not freed before suspend, so uvc_alloc_urb_buffers
should return packet counts allocated originally during uvc resume
, instead of zero.

This patch is against v2.6.30-rc2.

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 drivers/media/video/uvc/uvc_video.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/media/video/uvc/uvc_video.c b/drivers/media/video/=
uvc/uvc_video.c
index a95e173..c050b22 100644
--- a/drivers/media/video/uvc/uvc_video.c
+++ b/drivers/media/video/uvc/uvc_video.c
@@ -742,7 +742,7 @@ static int uvc_alloc_urb_buffers(struct uvc_video_d=
evice *video,
=20
 	/* Buffers are already allocated, bail out. */
 	if (video->urb_size)
-		return 0;
+		return DIV_ROUND_UP(video->urb_size, psize);
=20
 	/* Compute the number of packets. Bulk endpoints might transfer UVC
 	 * payloads accross multiple URBs.
--=20
1.6.0.GIT



--=20
Lei Ming
