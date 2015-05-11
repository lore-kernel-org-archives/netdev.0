From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net] rtnl: don't send rtnl msg for unregistered iface
Date: Mon, 11 May 2015 18:15:37 -0400
Message-ID: <20150511221536.GB9559@gospo.home.greyhouse.net>
References: <1431354346-4476-1-git-send-email-nicolas.dichtel@6wind.com>
 <20150511153741.GB2222@nanopsycho.mtl.com>
 <5550D2F1.5030100@6wind.com>
 <5550D584.9010703@6wind.com>
 <20150511175355.GA3130@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net,
	netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:34086 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687AbbEKWPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:15:40 -0400
Received: by qgfi89 with SMTP id i89so75691114qgf.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:15:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150511175355.GA3130@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 07:53:55PM +0200, Jiri Pirko wrote:
> Mon, May 11, 2015 at 06:15:00PM CEST, nicolas.dichtel@6wind.com wrote=
:
> >Le 11/05/2015 18:04, Nicolas Dichtel a =E9crit :
> >>Le 11/05/2015 17:37, Jiri Pirko a =E9crit :
> >>[snip]
> >>>
> >>>I don't think this is the correct way to fix this.
> >>>
> >>>How ifindex can be 0 here? Ifindex is set in register_netdevice an=
d
> >>>looking at bond_create, I don't see any call to __bond_opt_set bef=
ore
> >>>that. But since it apparently is, the ordering should be changed s=
o
> >>>register_netdevice is called first.
> >I also don't see why we would prevent to register a bonding interfac=
e directly
> >with the right mode.
> >
> >>bond_newlink =3D> bond_changelink =3D> __bond_opt_set
> >>and then back to bond_newlink =3D> register_netdevice
>=20
> I see it now. Why not to do register first, changelink later?
> Or, change __bond_opt_set to call call_netdevice_notifiers only in ca=
se
> dev->reg_state =3D=3D NETREG_REGISTERED? Looking at the other places =
this

This is probably an excellent approach.

> check happens, looks like a little helper like "netdev_check_register=
ed"
> might be convenient.
