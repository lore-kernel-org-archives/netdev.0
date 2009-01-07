From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 1/3] wimax: fix '#ifdef CONFIG_BUG' layout to avoid warning
Date: Wed, 7 Jan 2009 09:20:17 -0800
Message-ID: <200901070920.18032.inaky@linux.intel.com>
References: <cover.1231314782.git.inaky@linux.intel.com> <8baeb9679011f4f01a5f9709c725c4d829cb28bd.1231314782.git.inaky@linux.intel.com> <Pine.LNX.4.64.0901071200080.27307@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, wimax@linuxwimax.org,
	greg@kroah.com
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:18480 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753208AbZAGRUe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 12:20:34 -0500
In-Reply-To: <Pine.LNX.4.64.0901071200080.27307@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 07 January 2009, Ilpo J=E4rvinen wrote:
> On Tue, 6 Jan 2009, Inaky Perez-Gonzalez wrote:
> > Reported by Randy Dunlap:
> > > Also, this warning needs to be fixed:
> > >
> > > linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C90
> > > forbids mixed declarations and code
> >
> > Move the return on #defined(CONFIG_BUG) below the variable
> > declarations so it doesn't violate ISO C90.
> >
> > On wimax_id_table_release() we want to do a debug check if CONFIG_B=
UG
> > is enabled. However, we also want the debug code to be always compi=
led
> > to ensure there is no bitrot.
>
> I hope this kind of solution won't add some warnings? Besides, this s=
eems
> rather strange reasoning as CONFIG_BUG is mostly enabled anyway?

Well, it is legal code -- short of 'if (1) return'. It doesn't warn (an=
d=20
it should not).

> > -#ifndef CONFIG_BUG
> > -	return;
> > -#endif
> >  	struct wimax_dev *wimax_dev;
> >
> > +#ifdef CONFIG_BUG
>
> Did you perhaps mean ifndef here??? :-)

Sigh ... you are right ... good thing I triple checked.

Sending updated patch series.

Thanks,

--=20
Inaky
