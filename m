From: David Malcolm <dmalcolm@redhat.com>
Subject: [PATCH] drivers/net/ethernet/dec/tulip/uli526x.c: fix misleading indentation in uli526x_timer
Date: Tue,  2 Jun 2015 15:31:17 -0400
Message-ID: <1433273477-52330-1-git-send-email-dmalcolm@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Malcolm <dmalcolm@redhat.com>
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35054 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751195AbbFBTRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2015 15:17:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code in drivers/net/ethernet/dec/tulip/uli526x.c
function "uli526x_timer":

  1086          } else
  1087                  if ((tmp_cr12 & 0x3) && db->link_failed) {
  [...snip...]
  1109                  }
  1110                  else if(!(tmp_cr12 & 0x3) && db->link_failed)
  1111                  {
  [...snip...]
  1117                  }
  1118                  db->init=3D0;

is misleadingly indented: the
  db->init=3D0
is indented as if part of the else clause at line 1086, but it is
independent of it (no braces before the "if" at line 1087).

This patch fixes the indentation to reflect the actual meaning of the c=
ode,
though is it actually meant to be part of the "else" clause?  (I'm a
compiler developer, not a kernel person).  It also adds spaces around
the assignment, to placate checkpatch.pl.

Seen via an experimental new gcc warning I'm working on for gcc 6,
-Wmisleading-indentation, using gcc r223098 adding
-Werror=3Dmisleading-indentation to KBUILD_CFLAGS in Makefile.
The experimental GCC emits this warning (as an error), rightly IMHO:

drivers/net/ethernet/dec/tulip/uli526x.c: In function =E2=80=98uli526x_=
timer=E2=80=99:
drivers/net/ethernet/dec/tulip/uli526x.c:1118:3: error: statement is
indented as if it were guarded by... [-Werror=3Dmisleading-indentation]
   db->init=3D0;
    ^
drivers/net/ethernet/dec/tulip/uli526x.c:1086:4: note: ...this =E2=80=98=
else=E2=80=99
clause, but it is not
  } else
     ^

Hope this is helpful
Dave

Signed-off-by: David Malcolm <dmalcolm@redhat.com>
---
 drivers/net/ethernet/dec/tulip/uli526x.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/eth=
ernet/dec/tulip/uli526x.c
index 2c30c0c..447d092 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -1115,7 +1115,7 @@ static void uli526x_timer(unsigned long data)
 				netif_carrier_off(dev);
 			}
 		}
-		db->init=3D0;
+	db->init =3D 0;
=20
 	/* Timer active again */
 	db->timer.expires =3D ULI526X_TIMER_WUT;
--=20
1.8.5.3
