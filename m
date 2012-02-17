From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sysfs^H^H^H^H^Hsysctl warnings, reserved names
Date: Fri, 17 Feb 2012 14:05:34 +0100
Message-ID: <1329483934.2861.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <41230e67c273dde6b60cfc7110f496e2@visp.net.lb>
	 <1329475042.2861.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1329476631.2861.8.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <m1k43lhdeh.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38098 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464Ab2BQNFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2012 08:05:37 -0500
Received: by wics10 with SMTP id s10so1530110wic.19
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2012 05:05:36 -0800 (PST)
In-Reply-To: <m1k43lhdeh.fsf_-_@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 04:07 -0800, Eric W. Biederman =
a =C3=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
> > Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 11:37 +0100, Eric Dumazet a=
 =C3=A9crit :
> >> Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 12:14 +0200, Denys Fedorys=
hchenko a
> >> =C3=A9crit :
> >> > Hi
> >> >=20
> >> > Just did a test:
> >> >=20
> >> > ip link set dev eth1 name default
> >> >=20
> >> > And got a lot of (expected) sysfs warnings:
> >> > [1068625.677143] sysctl table check failed:=20
> >> > /net/ipv4/conf/default/promote_secondaries  Sysctl already exist=
s
> >> > [1068625.677151] Pid: 18106, comm: ip Not tainted 3.2.4-centaur =
#1
> >> > and etc
> >> >=20
> >> > Kernel 3.2.4, but i guess it doesn't matter much.
> >> > Maybe such names (as all and default) should be "reserved"?
> >> > Or it is ok like that?
> >> >=20
> >>=20
> >> You're right, we should forbid this to happen.
> >>=20
> >>=20
> >
> > Following is a quick hack, I CC Eric because its probaly better to
> > address this in sysfs.
>=20
> Well we are talking about sysctl not sysfs but same difference, I kee=
p
> an on eye on them.
>=20
> I expect renaming a network device to "all" or "default" would be a
> problem in any kernel supporting renaming of networking devices.
>=20
> At the basic level of handling it.  sysctl checks for this sometimes
> now and as soon as my sysctl tree is merged the checks will become
> unconditionally present.  In what sense were you thinking it would
> be better to address this in the sysctl?
>=20

Because problem is : it seems a rename() of "eth3" to "default" is
allowed by sysctl, yet "default" is already in directory.

It seems sysfs_rename_link() / sysfs_rename_dir() / sysfs_rename() migh=
t
have a problem ?

Sorry, I leave for vacations and can check all this before 5 days.
