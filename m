From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-next-2.6 2009-12-24
Date: Thu, 24 Dec 2009 23:47:59 -0500
Message-ID: <20091225044759.GA11186@tuxdriver.com>
References: <20091224204722.GA678@tuxdriver.com>
 <20091224.135314.193725771.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58902 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbZLYEw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 23:52:29 -0500
Content-Disposition: inline
In-Reply-To: <20091224.135314.193725771.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 24, 2009 at 01:53:14PM -0800, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Thu, 24 Dec 2009 15:47:22 -0500
>=20
> > Dave,
> >=20
> > Here is the usual first batch of pent-up wireless patches after the
> > merge window.  It is the usual collection of various driver updates
> > along with a dozen or so mac80211/infrastructure changes.  There is
> > still more, but lots/most of what remains is dependent not only on =
this
> > batch but also on the fixes that only recently made it into net-nex=
t-2.6
> > (and which are not yet in wireless-next-2.6).  So, something to loo=
k
> > forward to... :-)
> >=20
> > Please let me know if there are problems!
>=20
> Let me know when it builds :-)
>=20
> awk: /home/davem/src/GIT/net-next-2.6/net/wireless/genregdb.awk: line=
 29: regular expression compile failed (missing operand)
> * Ignore *
> awk: /home/davem/src/GIT/net-next-2.6/net/wireless/genregdb.awk: line=
 33: regular expression compile failed (missing operand)
> * Ignore *
> make[2]: *** [net/wireless/regdb.c] Error 2
> make[2]: *** Waiting for unfinished jobs....

Hmm...well, I'm at a loss.  It certainly works here. :-)

Perhaps you could send me your config?  And maybe the output of
"awk -W version"?  I suppose it is possible that I'm relying on some
specific awk feature that isn't commonly available...?

Actually, I think it has to do with the C-style comments on the
cited lines.  Try the patch below?  If it works for you, perhaps you
could just apply it on top of the request pull?

John

---

=46rom 0d5105fb0d1cb949ebb54eb50c4affd33328b866 Mon Sep 17 00:00:00 200=
1
=46rom: John W. Linville <linville@tuxdriver.com>
Date: Thu, 24 Dec 2009 23:44:51 -0500
Subject: [PATCH] wireless: fix comments in genregdb.awk

Apparently some awk versions choke on C-style comments -- who knew? :-)

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/wireless/genregdb.awk |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/wireless/genregdb.awk b/net/wireless/genregdb.awk
index 8316cf0..3cc9e69 100644
--- a/net/wireless/genregdb.awk
+++ b/net/wireless/genregdb.awk
@@ -26,11 +26,11 @@ BEGIN {
 }
=20
 /^[ \t]*#/ {
-	/* Ignore */
+	# Ignore
 }
=20
 !active && /^[ \t]*$/ {
-	/* Ignore */
+	# Ignore
 }
=20
 !active && /country/ {
--=20
1.6.5.2

--=20
John W. Linville =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Someday the world will =
need a hero, and you
linville@tuxdriver.com =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0might be all =
we have. =A0Be ready.
