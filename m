From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [PATCH 2.6]: IPv4: strcpy -> strlcpy
Date: Sun, 30 Nov 2003 11:26:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311301126.24035.ioe-lkml@rameria.de>
References: <20031127142125.GG8276@jdj5.mit.edu> <1069970946.2138.13.camel@teapot.felipe-alfaro.com> <1070012538.10048.13.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Timo Kamph <timo@kamph.org>,
        Linux Kernel Mailinglist <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1070012538.10048.13.camel@hades.cambridge.redhat.com>
Content-Description: clearsigned data
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Friday 28 November 2003 10:42, David Woodhouse wrote:
> On Thu, 2003-11-27 at 23:09 +0100, Felipe Alfaro Solana wrote:
> > On Thu, 2003-11-27 at 21:48, Timo Kamph wrote:
> > > > +	strlcpy(label->label, name, sizeof(label->name));
> > >
> > >                                                                       
> > > ^^^^^^ I guess this shoud be label->label, or am I wrong?
> >
> > Oh my god! Two consecutive mistakes with the same patch! I should have
> > some sleep... Here's the one with the typo corrected.
>
> Perhaps we should consider
>
> #define strsizecpy(x, y) strlcpy((x), (y), sizeof(x))

Then we should do:

#define strsizecpy(x, y) strlcpy(x, y, sizeof(x)/sizeof(x[0]))

to rule out passing the wrong variables or dereferencing to much.

Unfortunatly there is no simple way in C to differentiate between array and
pointer.

There is a way with typeof, but that is hackish.


Regards

Ingo Oeser

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/ycXOU56oYWuOrkARAiJ8AJ9wkl1ijJVn5M+lGhUwSwWRxzxxHwCg2nAU
t+9HdAasQDZo/GQFuj9s5ZU=
=py/4
-----END PGP SIGNATURE-----
