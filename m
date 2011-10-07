From: Yinglin Sun <yinglin.s@gmail.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Fri, 7 Oct 2011 09:59:06 -0700
Message-ID: <CAN17JHVC-qVst1vw5eOC1Wg8ekBejped5WErVo5wCAWTBF9JSw@mail.gmail.com>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
	<20111006110047.GA22462@hmsreliant.think-freely.org>
	<27199.1317927933@death>
	<CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
	<CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
	<7122.1317949193@death>
	<CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
	<20111007061326.GL23845@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:53060 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531Ab1JGQ7I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 12:59:08 -0400
Received: by bkbzt4 with SMTP id zt4so5067226bkb.19
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 09:59:06 -0700 (PDT)
In-Reply-To: <20111007061326.GL23845@angus.ind.WPI.EDU>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 6, 2011 at 11:13 PM, Chuck Anderson <cra@wpi.edu> wrote:
>
> On Thu, Oct 06, 2011 at 06:24:36PM -0700, Yinglin Sun wrote:
> > On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> wro=
te:
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0Why are you setting up the port channe=
l after configuring the
> > > bond?
> > >
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0As a possible workaround, if you have =
control over the setup
> > > process (perhaps it's some sort of manual process), adding one sl=
ave to
> > > the bond, leaving the other soon-to-be slaves down, then setting =
up the
> > > switch, and finally adding the remaining slaves should work aroun=
d the
> > > issue, since if the bond has only one slave it won't see any loop=
ed
> > > packets.
> > >
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0Or you could bring the bond up as acti=
ve-backup, then change the
> > > mode to balance-xor once the switch is configured.
> > >
> > > =C2=A0 =C2=A0 =C2=A0 =C2=A0Ultimately, though, the problem stems =
from the settings mismatch
> > > between the switch and the bonding system; balance-xor is meant t=
o
> > > interoperate with etherchannel, and when the switch is not config=
ured
> > > properly, correct behavior is difficult to guarantee.
> > >
> >
> > Jay,
> >
> > Thanks a lot for the suggestion.
> >
> > It's mainly about usability. We would like to provide customers wit=
h
> > consistent IPv6 configuration procedures as IPv4. =C2=A0Such workar=
ounds
> > could be confusing and generate customer calls.
>
> You've created/encouraged your customers to create a broken network
> configuration by connecting two bonded links to a non-bonded,
> non-etherchannel switch port pair. =C2=A0This type of misconfiguratio=
n,
> when applied to inter-switch trunks, can cause major network issues,
> like looping and broadcast storms, taking down the entire network
> unless something like Spanning Tree is enabled to protect against suc=
h
> accidental loops. =C2=A0It should be avoided at all costs. =C2=A0Luck=
ily, if the
> Linux host in this case is not being used as a switch/bridge, the
> impact of this might not be so bad--perhaps limited to the IPv6 DAD
> issue you report.
>
> If you want better usability and plug-n-play bonding, then require
> LACP/802.3ad to be used. =C2=A0Please don't encourage your customers =
to
> connect misconfigured devices to the network, thanks.

You are right. LACP is the good choice. It should be able to solve
this issue, since all LACP bonding slaves are down before port channel
is set up on switch. Thanks.

I'm not sure this is kind of broken network configuration. If
customers happen to add some IPv6 addresses on bonding interface
before setting up port channel on switch, they have to reconfigure all
of them again. This is not the good user experience. From my point of
view, a nice product should be able to tolerate this issue.

Thanks.

Yinglin
