From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [PATCH 1/4] kconfig: introduce the "imply" keyword
Date: Thu, 20 Oct 2016 08:38:21 -0700
Message-ID: <20161020153821.rkb3wgor762kprq7@jtriplet-mobl2.jf.intel.com>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org>
 <1476920573-14384-2-git-send-email-nicolas.pitre@linaro.org>
 <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Pitre <nicolas.pitre@linaro.org>,
        John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Edward Cree <ecree@solarflare.com>
Return-path: <linux-kbuild-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <44f95579-6c35-7592-08e3-d8dbb13026b2@solarflare.com>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 20, 2016 at 03:52:04PM +0100, Edward Cree wrote:
> On 20/10/16 00:42, Nicolas Pitre wrote:
> > diff --git a/Documentation/kbuild/kconfig-language.txt b/Documentation/kbuild/kconfig-language.txt
> > index 069fcb3eef..c96127f648 100644
> > --- a/Documentation/kbuild/kconfig-language.txt
> > +++ b/Documentation/kbuild/kconfig-language.txt
> > @@ -113,6 +113,33 @@ applicable everywhere (see syntax).
> >       That will limit the usefulness but on the other hand avoid
> >       the illegal configurations all over.
> >
> > +- weak reverse dependencies: "imply" <symbol> ["if" <expr>]
> > +  This is similar to "select" as it enforces a lower limit on another
> > +  symbol except that the "implied" config symbol's value may still be
> > +  set to n from a direct dependency or with a visible prompt.
> > +  Given the following example:
> > +
> > +  config FOO
> > +     tristate
> > +     imply BAZ
> > +
> > +  config BAZ
> > +     tristate
> > +     depends on BAr
> > +
> > +  The following values are possible:
> > +
> > +     FOO             BAR             BAR's default   choice for BAZ
> Should the third column not be "BAZ's default"?
> > +     --------------- --------------- --------------- --------------
> > +     n               y               n               N/m/y
> > +     m               y               m               M/y/n
> > +     y               y               y               Y/n
> > +     y               n               *               N
> Also, I don't think having any FOO=y should preclude BAZ=m.  Suppose both
> FOO and FOO2 imply BAZ, FOO=y and FOO2=m.  Then if BAZ-features are only
> desired for driver FOO2, BAz=m makes sense.

That's exactly the problem that motivated "imply" in the first place:
while that's *possible*, it means the user needs to know that they're
breaking BAZ support for driver FOO.

In theory, someone could extend the UI to note the symbols with an
"imply" for a given symbol and provide additional help for the implied
symbol that explains the implications.  In that case, it might make
sense to allow the user to explicitly mark a symbol as 'm', with
appropriate explanations of the implications.  But in the absence of
that, the simple solution seems like preventing 'm' for a symbol implied
by a symbol marked as 'y'.
