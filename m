From: Chuck Anderson <cra@WPI.EDU>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
	from others
Date: Fri, 7 Oct 2011 02:13:26 -0400
Message-ID: <20111007061326.GL23845@angus.ind.WPI.EDU>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com> <20111006110047.GA22462@hmsreliant.think-freely.org> <27199.1317927933@death> <CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com> <CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com> <7122.1317949193@death> <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL1.WPI.EDU ([130.215.36.91]:49395 "EHLO MAIL1.WPI.EDU"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214Ab1JGGN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 02:13:29 -0400
Received: from MAIL1.WPI.EDU (MAIL1.WPI.EDU [130.215.36.91])
	by MAIL1.WPI.EDU (8.14.5/8.14.5) with ESMTP id p976DS2U023753
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 02:13:28 -0400
Received: from SMTP.WPI.EDU (SMTP.WPI.EDU [130.215.36.186])
	by MAIL1.WPI.EDU (8.14.5/8.14.5) with ESMTP id p976DSVU023750
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 02:13:28 -0400
Received: from angus.ind.WPI.EDU (ANGUS.IND.WPI.EDU [130.215.130.21])
	by SMTP.WPI.EDU (8.14.4/8.14.4) with ESMTP id p976DRYp020325
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 02:13:27 -0400
	(envelope-from cra@WPI.EDU)
Received: from angus.ind.WPI.EDU (angus.ind.WPI.EDU [127.0.0.1])
	by angus.ind.WPI.EDU (8.14.2/8.14.2) with ESMTP id p976DRQU001444
	for <netdev@vger.kernel.org>; Fri, 7 Oct 2011 02:13:27 -0400
Received: (from cra@localhost)
	by angus.ind.WPI.EDU (8.14.2/8.14.2/Submit) id p976DQJ9001442
	for netdev@vger.kernel.org; Fri, 7 Oct 2011 02:13:26 -0400
Content-Disposition: inline
In-Reply-To: <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 06, 2011 at 06:24:36PM -0700, Yinglin Sun wrote:
> On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> wrote=
:
> > =A0 =A0 =A0 =A0Why are you setting up the port channel after config=
uring the
> > bond?
> >
> > =A0 =A0 =A0 =A0As a possible workaround, if you have control over t=
he setup
> > process (perhaps it's some sort of manual process), adding one slav=
e to
> > the bond, leaving the other soon-to-be slaves down, then setting up=
 the
> > switch, and finally adding the remaining slaves should work around =
the
> > issue, since if the bond has only one slave it won't see any looped
> > packets.
> >
> > =A0 =A0 =A0 =A0Or you could bring the bond up as active-backup, the=
n change the
> > mode to balance-xor once the switch is configured.
> >
> > =A0 =A0 =A0 =A0Ultimately, though, the problem stems from the setti=
ngs mismatch
> > between the switch and the bonding system; balance-xor is meant to
> > interoperate with etherchannel, and when the switch is not configur=
ed
> > properly, correct behavior is difficult to guarantee.
> >
>=20
> Jay,
>=20
> Thanks a lot for the suggestion.
>=20
> It's mainly about usability. We would like to provide customers with
> consistent IPv6 configuration procedures as IPv4.  Such workarounds
> could be confusing and generate customer calls.

You've created/encouraged your customers to create a broken network
configuration by connecting two bonded links to a non-bonded,
non-etherchannel switch port pair.  This type of misconfiguration,
when applied to inter-switch trunks, can cause major network issues,
like looping and broadcast storms, taking down the entire network
unless something like Spanning Tree is enabled to protect against such
accidental loops.  It should be avoided at all costs.  Luckily, if the
Linux host in this case is not being used as a switch/bridge, the
impact of this might not be so bad--perhaps limited to the IPv6 DAD
issue you report.

If you want better usability and plug-n-play bonding, then require
LACP/802.3ad to be used.  Please don't encourage your customers to
connect misconfigured devices to the network, thanks.
