From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workaround
Date: Mon, 25 Aug 2008 18:45:40 +0200
Message-ID: <200808251845.41164.thomas.jarosch@intra2net.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_1GusI+sJ3SlMh79"
Cc: netfilter-devel@vger.kernel.org
To: Netdev <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_1GusI+sJ3SlMh79
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46orward mail. Upgrading to KDE 4.1.0/kdepim4 from KDE 3.5.9
enabled HTML emails by default and I didn't notice it before.

=2D---------  Forwarded Message  ----------

Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility workarou=
nd
Date: Monday, 25. August 2008
=46rom: Thomas Jarosch <thomas.jarosch@intra2net.com>
To: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>

On Friday, 22. August 2008 23:18:44 Ilpo J=E4rvinen wrote:
> In the meantime, can you check the attached patches. Besides the kernel
> patch, you need to build your own patched iproute2 as well to configure
> the features (ip tool among them is enough in case the build of some other
> part of the toolset fails like it did for me). I somewhat tested them, and
> the result seemed to be what I'd expect (I just forced RTOs with some
> netem heavy dropping and quickly glanced over the resulting packet
> patterns near RTO).

Your patches work fine.

I've noticed two small things:
1. Maybe it's a good idea to add a note above the tcp_use_frto() change
to explain that the value is negated. Took me a while to figure out
why there is no "!" in there :-)
2. Maybe rename the "features" option in iproute2 to "disable_features".
Then it would be more intuitive what it does.


btw: If you apply something to the iproute2 git tree,
I got a compiler error while testing the patch:

In file included from lnstat.c:40:
lnstat.h:28: error: field 'last_read' has incomplete type
lnstat.h:29: error: field 'interval' has incomplete type

Attached small patch fixes the issue.

Cheers,
Thomas


--Boundary-00=_1GusI+sJ3SlMh79
Content-Type: text/x-patch;
  charset="iso-8859-15";
  name="iproute2-fix-include-for-timeval.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="iproute2-fix-include-for-timeval.patch"

Fix this compile error:

In file included from lnstat.c:40:
lnstat.h:28: error: field 'last_read' has incomplete type
lnstat.h:29: error: field 'interval' has incomplete type

Signed-off-by: Thomas Jarosch <thomas.jarosch@intra2net.com>

diff -u -r iproute2-2.6.25/misc/lnstat.h iproute2.timeval/misc/lnstat.h
--- iproute2-2.6.25/misc/lnstat.h	Thu Apr 17 19:12:54 2008
+++ iproute2.timeval/misc/lnstat.h	Mon Aug 25 17:48:33 2008
@@ -2,6 +2,7 @@
 #define _LNSTAT_H
 
 #include <limits.h>
+#include <sys/time.h>
 
 #define LNSTAT_VERSION "0.02 041002"
 

--Boundary-00=_1GusI+sJ3SlMh79--
