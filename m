From: Philippe Biondi <biondi@cartel-securite.fr>
Subject: Re: [Fwd: [ANNOUNCE] Layer-7 Filter for Linux QoS]
Date: Wed, 21 May 2003 15:20:15 +0200 (CEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0305211447270.12543-100000@deneb.intranet.cartel-securite.net>
References: <20030521075617.N43477@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin Josefsson <gandalf@wlug.westbo.se>,
	Ethan Sommer <sommere@ethanet.com>,
	"David S. Miller" <davem@redhat.com>, <linux-net@vger.kernel.org>,
	<netdev@oss.sgi.com>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030521075617.N43477@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

Hi all,

> On Tue, 20 May 2003, Martin Josefsson wrote:
>
> > Maybe make it take a length parameter and if it's zero treat null's=
 like
> > all other algorithms do and it's non-zero use the length instead.
> > Then you can hide it in a wrapper function for the "normal" case th=
at
> > just calls the actual search-function but with 0 as length.
> >
>
> Actually, the library that you pointed to seems to have callbacks
> associated with every match - so it could be used on string matches.
> The author is on the cc.

There is only one callback, but it will be called with a per-pattern
cb_data pointer (and a per-search cb_data pointer too).


> > Well we don't have a that big bread slicer (yet) but take a look at
> > libqsearch, it is a library for searching and has been ported to th=
e
> > linux kernel by the author. It has support for various algorithms t=
hat
>
> Didnt see anything kernel related in my quick scan.
> The library certainly appears sane.

Be sure you took the latest version :
cvs -d:pserver:anonymous@cvs.prelude-ids.org:/cvsroot/prelude co libqse=
arch

I confirm I ported it to kernel space. To be exact, I ported the API an=
d
made a script that generate wrappers for algorithms, that are compiled
as-is for kernel space.

More infos here:
http://www.cartel-securite.fr/pbiondi/libqsearch.html

Lot more info here (presentation I made at FOSDEM03) :
http://www.cartel-securite.fr/pbiondi/conf/libqsearch.pdf


> > have diffrent capabilities, unfortunately I don't think it has an
> > algorithm that has support for regexp yet (the framework is there, =
ie
> > the flag that says an algorithm supports regexp).
> > It's modular and I don't think it should be that hard to add an reg=
exp
> > algorithm.
>
> it does seems to imply regexp is available but wasnt anywhere i could
> find.

regexp support was planned but not done yet. (if someone know where I c=
an
download more free time !).

The implementation should not be that hard, once you have the compiler =
to
transform the string describing the regexp to an automaton.

Note that to respect the framework, you have to deal with multiple
patterns (should not be that hard). If you have pat1 and pat2, searchin=
g
for (pat1|pat2) is not sufficient because for each match, you have to
point which pattern matched.


> > It looks quite nice and it can search for multiple strings at the s=
ame
> > time and call diffrent callbacks depending on which string matched.
> >
>
> yep, can sed that packet easily with those callbacks ;-> s/val/val2/g

Nothing is done to change the content, but you have the position of the
match in the buffer. You can modify it yourself.




--=20
Philippe Biondi <biondi@ cartel-securite.fr> Cartel S=E9curit=E9
Security Consultant/R&D                      http://www.cartel-securite=
=2Efr
Phone: +33 1 44 06 97 94                     Fax: +33 1 44 06 97 99
PGP KeyID:3D9A43E2  FingerPrint:C40A772533730E39330DC0985EE8FF5F3D9A43E=
2




