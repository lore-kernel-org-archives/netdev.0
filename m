From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: 2.6.19 status
Date: Fri, 29 Sep 2006 10:10:34 +0300
Message-ID: <200609291010.35025.ismail@pardus.org.tr>
References: <20060928.184135.41635707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:56022 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S1161460AbWI2HKT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:10:19 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060928.184135.41635707.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,
29 Eyl 2006 Cum 04:41 tarihinde =C5=9Funlar=C4=B1 yazm=C4=B1=C5=9Ft=C4=B1=
n=C4=B1z:
> I've just pushed my current net-2.6 tree to Linus.  The bulk of the
> changes in there are endianness annotations for sparse by Al Viro,
> along with the patches I've been ACK'ing here on the list and
> elsewhere.
>
> If you want a non-bugfix change to get into 2.6.19 you must have it t=
o
> me by the end of the weekend.
>
> As of next Monday, anything I receive has to be a bugfix for 2.6.19
> consideration.
>
> Thanks for everyone's hard work and let's make sure there are no
> networking regressions at all in 2.6.19, in fact let's strive to
> make it have no regressions plus bugs fixed that were in 2.6.18 :-)

Looks like following fix from Herbert still didn't made it to Linus whi=
ch=20
fixes hard lockups with some tc usage.


[NET_SCHED]: HTB: fix incorrect use of RB_EMPTY_NODE

=46ix incorrect use of RB_EMPTY_NODE in htb_safe_rb_erase, which makes =
it
skip nodes within the rbtree instead of nodes not in the tree, resultin=
g
in crashes later on.

The root cause for this seems to be the very counter-intuitive behaviou=
r
of the RB_EMPTY_NODE macro, which returns _false_ when the node is empt=
y.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 9a0cd6d60280d88c38791844c87548d45cf6f2c2
tree fdf4f4a46fb088d957322006828af557b8ce594a
parent 7e4720201ad44ace85a443f41d668a62a737e7d0
author Patrick McHardy <kaber@trash.net> Wed, 27 Sep 2006 13:27:24 +020=
0
committer Patrick McHardy <kaber@trash.net> Wed, 27 Sep 2006 13:27:24 +=
0200

 net/sched/sch_htb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index bb3ddd4..6c058e3 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -391,7 +391,7 @@ static inline void htb_add_class_to_row(
 /* If this triggers, it is a bug in this code, but it need not be fata=
l */
 static void htb_safe_rb_erase(struct rb_node *rb, struct rb_root *root=
)
 {
-	if (RB_EMPTY_NODE(rb)) {
+	if (!RB_EMPTY_NODE(rb)) {
 		WARN_ON(1);
 	} else {
 		rb_erase(rb, root);


--=20
They that can give up essential liberty to obtain a little temporary sa=
fety=20
deserve neither liberty nor safety.
-- Benjamin Franklin
