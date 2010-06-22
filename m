From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bugme-new] [Bug 16268] New: kernel oops when rmmod the
 tcp_diag modules
Date: Wed, 23 Jun 2010 00:02:42 +0200
Message-ID: <1277244162.2591.198.camel@edumazet-laptop>
References: <bug-16268-10286@https.bugzilla.kernel.org/>
	 <20100622141232.4b8f1d4a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lyw@cn.fujitsu.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64880 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030Ab0FVWCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 18:02:46 -0400
Received: by wyi11 with SMTP id 11so275405wyi.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 15:02:45 -0700 (PDT)
In-Reply-To: <20100622141232.4b8f1d4a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 juin 2010 =C3=A0 14:12 -0700, Andrew Morton a =C3=A9crit :
> (switched to email.  Please respond via emailed reply-to-all, not via=
 the
> bugzilla web interface).
>=20
> On Tue, 22 Jun 2010 00:43:37 GMT
> bugzilla-daemon@bugzilla.kernel.org wrote:
>=20
> > https://bugzilla.kernel.org/show_bug.cgi?id=3D16268
> >=20
> >            Summary: kernel oops when rmmod the tcp_diag modules
> >            Product: Networking
> >            Version: 2.5
> >     Kernel Version: 2.6.35-rc3
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: lyw@cn.fujitsu.com
> >         Regression: No
> >=20
> >=20
> > I found a crash problem use following scripts and steps
> >=20
> > #cat run_ss.sh
> >  while [ 1 ]
> >  do
> >      ss -a
> >  done
> >=20
> > #cat rmmod.sh
> >  while [ 1 ]
> >  do=20
> >      rmmod -f tcp_diag >/dev/null 2>&1
> >      rmmod -f inet_diag >/dev/null 2>&1
> >  done
> >=20
> > step1:
> >   # sh run_sh.sh
> > step2:
> >   # sh rmmod.sh
>=20
> I assume the rmmod script runs in pararallel with run_ss.sh.
>=20
> What is "ss"?  Something which triggers a load of kernel modules,
> presumably.  Which ones?
>=20

ss is kind of "netstat" with advanced features.

It loads inet_diag & tcp_diag modules.

> > After step2, the kernel oopsed.
>=20
> yeah, that was a pretty nasty test ;)

Well, they are faster and more predictable ways to reboot a machine, if
you ask me :)

man rmmod

       -f --force
              This  option can be extremely dangerous: it has no effect=
 unless
              CONFIG_MODULE_FORCE_UNLOAD was set when the kernel was co=
mpiled.
              With  this  option, you can remove modules which are bein=
g used,
              or which are not designed to be removed, or have been mar=
ked  as
              unsafe (see lsmod(8)).


I guess Linux is supposed to respect admin choice to live in a dangerou=
s world.


