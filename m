From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: avoid using uninitialized variable
Date: Tue, 14 Jun 2011 00:02:30 -0400
Message-ID: <20110614000230.4166a1ae@s6510.ftrdhcpuser.net>
References: <xr93vcw9s9zc.fsf@gthelen.mtv.corp.google.com>
	<20110613181212.571f8e76@s6510.ftrdhcpuser.net>
	<BANLkTi=jw5=9LcwxnXW6xNkF4RbFhHaB55Au=oDhn1yYWf53dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Greg Thelen <gthelen@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49970 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089Ab1FNEC1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2011 00:02:27 -0400
In-Reply-To: <BANLkTi=jw5=9LcwxnXW6xNkF4RbFhHaB55Au=oDhn1yYWf53dA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 13 Jun 2011 17:34:00 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Mon, Jun 13, 2011 at 3:12 PM, Stephen Hemminger
> <shemminger@vyatta.com> wrote:
> > On Mon, 13 Jun 2011 14:21:59 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> >
> >> I am not sure if 0 or ~0 would be a better choice in the gm_phy_re=
ad()
> >> error case. =A0I used 0. =A0A more complete solution might be to p=
lumb up
> >> error handling to the callers of gm_phy_read().
> >>
> >> =3D=3D
> >> From 37486219a3d93881f3b2619a4b2bb21be62db7d4 Mon Sep 17 00:00:00 =
2001
> >> From: Greg Thelen <gthelen@google.com>
> >> Date: Mon, 13 Jun 2011 14:09:07 -0700
> >> Subject: [PATCH] sky2: avoid using uninitialized variable
> >>
> >> Prior to this change gm_phy_read() could return an uninitialized
> >> variable if __gm_phy_read() failed.
> >>
> >> This change returns zero in the failure case.
> >>
> >> Signed-off-by: Greg Thelen <gthelen@google.com>
> >
> > Shouldn't the callers be changed to check rather than just returnin=
g
> > 0 and masking the problem.
>=20
> I agree that the right long term solution is to plumb the error
> handling up through the callers.  This would involve deleting the
> error-free gm_phy_read() routine and replacing all calls to it with
> calls to error-capable __gm_phy_read().  This would require convertin=
g
> several routines from returning void to returning int allowing errors
> to propagate upwards.  Notable affected routines include:
> sky2_phy_power_up(), sky2_wol_init(), sky2_phy_power_down(),
> sky2_hw_down(), sky2_mac_init(), sky2_hw_up(), sky2_phy_intr(),
> sky2_led().  sky2_restart() would likely have to re-queue the work
> item in the case of failure.  Presumably sky2_poll() would return 0 i=
f
> error is seen.  On a related note, it also seems that gm_phy_write()
> callers should be checking its return value to also handle the same
> class of I/O errors.  Testing these changes would involve injecting
> error values or access to certain kinds of broken hardware.

In my experience if phy reads once successfully, it is going
to read every time. If there is a problem it only happens on
the first access (powered off, bad timing, etc).


=20
> For the short term I figured that not consuming random data was a ste=
p
> in right direction.  But I understand if you prefer to hold out for
> the complete solution.  Unfortunately, I do not currently have time t=
o
> contribute to the complete solution.

