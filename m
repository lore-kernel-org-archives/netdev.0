From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 1/3] wimax: fix '#ifdef CONFIG_BUG' layout to avoid warning
Date: Wed, 7 Jan 2009 12:57:25 -0800
Message-ID: <200901071257.27225.inaky@linux.intel.com>
References: <cover.1231314782.git.inaky@linux.intel.com> <200901070920.18032.inaky@linux.intel.com> <Pine.LNX.4.64.0901072139001.27541@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, wimax@linuxwimax.org,
	greg@kroah.com
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45748 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756272AbZAGU6e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 15:58:34 -0500
In-Reply-To: <Pine.LNX.4.64.0901072139001.27541@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 07 January 2009, Ilpo J=C3=A4rvinen wrote:
> On Wed, 7 Jan 2009, Inaky Perez-Gonzalez wrote:
> > On Wednesday 07 January 2009, Ilpo J=C3=A4rvinen wrote:
> > > On Tue, 6 Jan 2009, Inaky Perez-Gonzalez wrote:
> > > > Reported by Randy Dunlap:
> > > > > Also, this warning needs to be fixed:
> > > > >
> > > > > linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C9=
0
> > > > > forbids mixed declarations and code
> > > >
> > > > Move the return on #defined(CONFIG_BUG) below the variable
> > > > declarations so it doesn't violate ISO C90.
> > > >
> > > > On wimax_id_table_release() we want to do a debug check if CONF=
IG_BUG
> > > > is enabled. However, we also want the debug code to be always
> > > > compiled to ensure there is no bitrot.
> > >
> > > I hope this kind of solution won't add some warnings? Besides, th=
is
> > > seems rather strange reasoning as CONFIG_BUG is mostly enabled an=
yway?
> >
> > Well, it is legal code -- short of 'if (1) return'. It doesn't warn=
 (and
> > it should not).
>
> Obviously, but I was concerned on the other lines than that
> particular one, e.g., gcc might think that wimax_dev is unused
> variable and emit a warning or along those lines...?

Ah, I see -- no, it won't. [disclaimer: not know much about compiler=20
optimization] In theory, as we were saying, it works just as in a case=20
where you have

int somevar;

if (1)
   return;

somevar =3D call_some_func();

with 1 being the result of a compile time evaluation. The compiler sees
that somevar is being used, but the code path is never executed, so eve=
rything
gets dumped.

If it ever did, it'd be a matter of changing that return to an if (1) r=
eturn.
It'd look uglier though.

--=20
Inaky
