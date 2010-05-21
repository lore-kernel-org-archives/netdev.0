From: James Bottomley <James.Bottomley@suse.de>
Subject: bug fix patch lost: git problem or just incorrect merge?
Date: Fri, 21 May 2010 10:41:55 -0500
Message-ID: <1274456515.9022.14.camel@mulgrave.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-scsi <linux-scsi@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch in question is this one (upstream for a while):

commit d7d05548a62c87ee55b0c81933669177f885aa8d
Author: Mike Christie <michaelc@cs.wisc.edu>
Date:   Wed Mar 31 14:41:35 2010 -0500

    [SCSI] iscsi_tcp: fix relogin/shutdown hang

It's a simple one line change in iscsi_tcp.c (diff clipped):

--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -599,7 +599,7 @@ static void iscsi_sw_tcp_conn_stop(struct iscsi_cls_conn *cls_conn, int flag)
-       if (sock->sk->sk_sleep && waitqueue_active(sock->sk->sk_sleep)) {
+       if (sock->sk->sk_sleep) {

It was killed by this merge commit in the net-next tree:

commit 278554bd6579206921f5d8a523649a7a57f8850d
Merge: 5a147e8 cea0d76
Author: David S. Miller <davem@davemloft.net>
Date:   Wed May 12 00:05:35 2010 -0700

However, the curious thing is that git seems to have lost trace of the
missing patch entirely:  if I try to find it in linus' tree with a git
log -- drivers/scsi/iscsi_tcp.c, it doesn't show up.  The merge commit
which killed it does list iscsi_tcp.c as a file conflict, but git show
on that commit doesn't list that file in the resolution diff ... even
though this is where it actually got killed.

Is this a git problem ... or is it just a mismerge in the net tree?

Either way, of course, we need the patch back ...

James
