From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Fri, 7 Oct 2011 13:29:02 -0400
Message-ID: <20111007172902.GD11408@hmsreliant.think-freely.org>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
 <20111006110047.GA22462@hmsreliant.think-freely.org>
 <27199.1317927933@death>
 <CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
 <CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
 <7122.1317949193@death>
 <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
 <20111007061326.GL23845@angus.ind.WPI.EDU>
 <CAN17JHVC-qVst1vw5eOC1Wg8ekBejped5WErVo5wCAWTBF9JSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Yinglin Sun <yinglin.s@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50526 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab1JGR3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:29:10 -0400
Content-Disposition: inline
In-Reply-To: <CAN17JHVC-qVst1vw5eOC1Wg8ekBejped5WErVo5wCAWTBF9JSw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 09:59:06AM -0700, Yinglin Sun wrote:
> On Thu, Oct 6, 2011 at 11:13 PM, Chuck Anderson <cra@wpi.edu> wrote:
> >
> > On Thu, Oct 06, 2011 at 06:24:36PM -0700, Yinglin Sun wrote:
> > > On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> w=
rote:
> > > > =A0 =A0 =A0 =A0Why are you setting up the port channel after co=
nfiguring the
> > > > bond?
> > > >
> > > > =A0 =A0 =A0 =A0As a possible workaround, if you have control ov=
er the setup
> > > > process (perhaps it's some sort of manual process), adding one =
slave to
> > > > the bond, leaving the other soon-to-be slaves down, then settin=
g up the
> > > > switch, and finally adding the remaining slaves should work aro=
und the
> > > > issue, since if the bond has only one slave it won't see any lo=
oped
> > > > packets.
> > > >
> > > > =A0 =A0 =A0 =A0Or you could bring the bond up as active-backup,=
 then change the
> > > > mode to balance-xor once the switch is configured.
> > > >
> > > > =A0 =A0 =A0 =A0Ultimately, though, the problem stems from the s=
ettings mismatch
> > > > between the switch and the bonding system; balance-xor is meant=
 to
> > > > interoperate with etherchannel, and when the switch is not conf=
igured
> > > > properly, correct behavior is difficult to guarantee.
> > > >
> > >
> > > Jay,
> > >
> > > Thanks a lot for the suggestion.
> > >
> > > It's mainly about usability. We would like to provide customers w=
ith
> > > consistent IPv6 configuration procedures as IPv4. =A0Such workaro=
unds
> > > could be confusing and generate customer calls.
> >
> > You've created/encouraged your customers to create a broken network
> > configuration by connecting two bonded links to a non-bonded,
> > non-etherchannel switch port pair. =A0This type of misconfiguration=
,
> > when applied to inter-switch trunks, can cause major network issues=
,
> > like looping and broadcast storms, taking down the entire network
> > unless something like Spanning Tree is enabled to protect against s=
uch
> > accidental loops. =A0It should be avoided at all costs. =A0Luckily,=
 if the
> > Linux host in this case is not being used as a switch/bridge, the
> > impact of this might not be so bad--perhaps limited to the IPv6 DAD
> > issue you report.
> >
> > If you want better usability and plug-n-play bonding, then require
> > LACP/802.3ad to be used. =A0Please don't encourage your customers t=
o
> > connect misconfigured devices to the network, thanks.
>=20
> You are right. LACP is the good choice. It should be able to solve
> this issue, since all LACP bonding slaves are down before port channe=
l
> is set up on switch. Thanks.
>=20
> I'm not sure this is kind of broken network configuration. If
> customers happen to add some IPv6 addresses on bonding interface
> before setting up port channel on switch, they have to reconfigure al=
l
Bringing up an interface prior to having it, and the peer interfaces co=
nfigured
to use an agreed upon mode, is rather by definition broken :)
