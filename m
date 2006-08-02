From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Subject: Re: Linville's L2 rant... -- Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Wed, 2 Aug 2006 11:02:20 +0200
Message-ID: <200608021102.20604.Christophe.Devriese@eurid.eu>
References: <44CA34D0.1070507@candelatech.com> <20060801170329.GG29208@tuxdriver.com> <44CF8D8A.5080101@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from uu212-190-206-99.unknown.uunet.be ([212.190.206.99]:13995 "EHLO
	smtp.eurid.eu") by vger.kernel.org with ESMTP id S1750792AbWHBJCb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 05:02:31 -0400
Received: from localhost (smtp.eurid.eu [127.0.0.1])
	by smtp.eurid.eu (Postfix) with ESMTP id B219012529E
	for <netdev@vger.kernel.org>; Wed,  2 Aug 2006 11:02:30 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <44CF8D8A.5080101@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 01 August 2006 19:21, you wrote:
> John W. Linville wrote:
> >>>I'm just not sure that cleverness is worth the headache, especiall=
y
> >>>since the most clever things usually only work by accident...
> >>
> >>Or, work by solid, modular design and small tweaks!
> >
> > Point taken. =A0But stashing little hacks in the networking core fo=
r
> > specific virtual drivers isn't totally modular either. =A0And even =
if
> > it were, "modular design" probably belongs on the list of "things
> > that can be taken too far", like "everything in userland", "never
> > use ioctl", and "microkernels are superior". :-)
>
> To be honest, I'm not over-joyed to see bridging hooks included
> in the VLAN code..but if that is what it takes to get bridging
> and VLANs to play well and be flexible, I think it is a fair price.
>
> It certainly wouldn't hurt to have someone take a holistic view of th=
e
> various L2 device interactions. =A0Just documenting current functiona=
lity
> on, say, the netdev wiki would be a good first step.

Ultimate flexibility could be provided by making the netif_rx routine (=
and the=20
others, including vlan etc), a "virtual" routine.

That way a list of "filters" could be defined that allow any processing=
 to be=20
done on the packet before it is handed of to the linux kernel's higher=20
layers, including not delivering it on that interface, or delivering it=
 on=20
another interface.

This would allow very complex implementations including stuff like a=20
high-level l2 bridge, with vlan support, and a number of protocols like=
 rstp,=20
pvst+, ... with relatively simple code, that could be isolated from the=
 main=20
kernel.

Would anyone be interested in signing off on such a patch ? (which basi=
cally=20
creates netif_rx and vlan_acc_netif_rx lists in the net_device structur=
e, and=20
then modify bridging and bonding drivers to just use this)=20

Regards,

Christophe
