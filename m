From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCH V4 02/13] netback: add module unload function.
Date: Fri, 3 Feb 2012 08:02:16 +0000
Message-ID: <1328256136.13189.34.camel@dagon.hellion.org.uk>
References: <1328201363-13915-1-git-send-email-wei.liu2@citrix.com>
	 <1328201363-13915-3-git-send-email-wei.liu2@citrix.com>
	 <1328202524.11534.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328203710.5553.94.camel@leeds.uk.xensource.com>
	 <1328204936.13262.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1328212761.28964.77.camel@dagon.hellion.org.uk>
	 <1328214866.2480.18.camel@edumazet-laptop>
	 <1328215821.13189.24.camel@dagon.hellion.org.uk>
	 <CAP=VYLq3CZBjC2ecOdGqAejN5Atu9kd1HovhQwc-eVk-q8ArJA@mail.gmail.com>
	 <1328251092.13189.29.camel@dagon.hellion.org.uk>
	 <1328253910.2480.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	"Wei Liu (Intern)" <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:38461 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab2BCICS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 03:02:18 -0500
In-Reply-To: <1328253910.2480.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-02-03 at 07:25 +0000, Eric Dumazet wrote:
> Le vendredi 03 f=E9vrier 2012 =E0 06:38 +0000, Ian Campbell a =E9crit=
 :
> > On Thu, 2012-02-02 at 22:52 +0000, Paul Gortmaker wrote:
> > > On Thu, Feb 2, 2012 at 3:50 PM, Ian Campbell <Ian.Campbell@citrix=
=2Ecom> wrote:
> > > > On Thu, 2012-02-02 at 20:34 +0000, Eric Dumazet wrote:
> > >=20
> > > [...]
> > >=20
> > > >
> > > > I don't think it is at all unreasonable to ask for bug fixes bu=
t in this
> > > > case Wei's series is removing the code in question (which would=
 also
> > > > undoubtedly fix the bug).
> > > >
> > > > As it happens the fix turns out to be simple but if it were com=
plex I
> > > > would perhaps have disagreed more strongly about spending effor=
t fixing
> > > > code that is removed 2 patches later, although obviously that w=
ould have
> > > > depended on the specifics of the fix in that case.
> > >=20
> > > Lots of people are relying on git bisect.  If you introduce build=
 failures
> > > or known bugs into any point in history, you take away from the v=
alue
> > > in git bisect.  Sure, it happens by accident, but it shouldn't ev=
er be
> > > done knowingly.
> >=20
> > Sure. In this case the bug has been there since 2.6.39, it isn't
> > introduced by this series.
> >=20
>=20
> We are stuck right now with a bug introduced in 2.6.39, (IP redirects=
),
> and because fix was done in 3.1, we are unable to provide a fix fo
> stable 3.0 kernel.
>=20
> Something that takes 15 minutes to fix now, can take several days of
> work later.

Sure.

Here is the patch. I've compile tested it but not run it yet since I'm
supposed to be packing for a trip, I'll be back on Wednesday. It seems
straight forward enough though.

8<--------------------------------

=46rom 6f3d3068f6e049c2d810f9fc667d57667bea77dc Mon Sep 17 00:00:00 200=
1
=46rom: Ian Campbell <ian.campbell@citrix.com>
Date: Fri, 3 Feb 2012 07:47:23 +0000
Subject: [PATCH] xen: netback: do not bind netback threads to specific =
CPUs

netback_init does not take proper account of which CPUs is online. Howe=
ver we
don't require a thread per CPU, just a pool of worker threads, of which=
 the
number of CPUs at start of day is as good a number as any.

Therefore do not bind netback threads to particular CPUs.

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Wei Lui <wei.lui2@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netbac=
k/netback.c
index 59effac..31ad3ee 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1670,8 +1670,6 @@ static int __init netback_init(void)
 			goto failed_init;
 		}
=20
-		kthread_bind(netbk->task, group);
-
 		INIT_LIST_HEAD(&netbk->net_schedule_list);
=20
 		spin_lock_init(&netbk->net_schedule_list_lock);
--=20
1.7.2.5
