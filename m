From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH v2 8/8] Document future removal of sysctl_tcp_* options
Date: Mon, 26 Oct 2009 11:08:55 -0400
Message-ID: <20091026110855.98a19f7a.billfink@mindspring.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com>
	<1256115421-12714-9-git-send-email-gilad@codefidence.com>
	<4ADED6FA.2030502@gmail.com>
	<4ADEE119.7020803@codefidence.com>
	<4ADF616B.1090405@gmail.com>
	<20091022003245.5cd4885c.billfink@mindspring.com>
	<4ADFE635.4020109@gmail.com>
	<4AE415DD.5050406@codefidence.com>
	<20091025202114.152b94b8.billfink@mindspring.com>
	<4AE52DBD.3030805@gmail.com>
	<4AE5585E.5010108@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	William Allen Simpson <william.allen.simpson@gmail.com>,
	netdev@vger.kernel.org,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:43005 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752557AbZJZPIy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2009 11:08:54 -0400
In-Reply-To: <4AE5585E.5010108@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 Oct 2009, Gilad Ben-Yossef wrote:

> Eric Dumazet wrote:
>=20
> > Bill Fink a =E9crit :
> >  =20
> >> On Sun, 25 Oct 2009, Gilad Ben-Yossef wrote:
> >>
> >>    =20
> >>> Eric Dumazet wrote:
> >>>
> >>>
> >>> I still think having a global kill switch and per route options b=
etter=20
> >>> (basically use the exiting patch but not retire the global kill=20
> >>> switch|), but if you must Hgow about we leave the global sysctl a=
s they=20
> >>> are and just have a two bit route option:
> >>>
> >>> 0 Use global default
> >>> 1 Off
> >>> 2 On
> >>>
> >>> It's kind of funny, because this is what the original patch from=20
> >>> Comsleep does and I thought it needlessly complicates things.
> >>>
> >>> So, what do you say - which will it be?
> >>>      =20
> >> I personally feel the 2-bit settings are overkill.  What i think
> >> makes the most sense is for the global options to act as they alwa=
ys
> >> have in the absence of any route specific settings, and for any
> >> route specific settings to override the related global settings.
> >> This is both simple and maintains backward compatibility.
> >>    =20
> >
> > Backward compatibility is important, very important, if not the mos=
t
> > important thing. Then usability comes.
> >  =20
> I tend to agree.
> > I know some busy servers where adding/changing a single route makes=
 them
> > go crazy (because of ip route flush cache)
> >
> > So if a route is overriding a global conf, and the admin wants to m=
ake an
> > emergency change during peak hours, he should do it by a global set=
ting,
> > or he wont use at all this new stuff, and stay conservative.
> >
> > Alternative would be to not trigger the flush of cache when changin=
g
> > features flags.
> >
> >  =20
> OK. It really sounds like we should go with my first suggestion: glob=
al=20
> sysctl based kill switches, just as we have now and in addition, the=20
> ability to kill TCP options per route. The TCP option will be used if=
=20
> and only if both kill switches (global and per route) are not set.

This wording is confusing.  The global kill switch not being set
really means that the sysctl is set.  And this assumes the per-route
default is not set.  Correct?

> What we achieve is:
>=20
> 1. Global kill switches work exactly as they do now, whether you use =
the=20
> new per route options or not, so backwards compatible.
>=20
> 2. In addition, if the global kill switch is not in effect, you can a=
lso=20
> kill the options on a per route basis.
>=20
> I'm going to send third version of the patch to this effect, minus th=
e=20
> new remote DoS possibility that Ilpo pointed out and leaving the glob=
al=20
> sysctl kill switches be.
>=20
> If you like it, please ACK ;-)

IIUC this doesn't seem right to me.  I believe the global setting
should be a default and the route specific an override.  Your scheme
would mean that if I set a global option to disable timestamps, then
I couldn't enable timestamps on specific routes using the per route
setting.

And it also doesn't seem to address Eric's scenario.  If I understand
his concern correctly, what seems to be needed is a third global
reset value (not calling it a setting since the actual global setting
wouldn't be changed), which would reset any per-route override settings
to the global default setting.

						-Bill
