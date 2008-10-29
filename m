From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [xfs-masters] linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 09:24:59 +0100
Message-ID: <20081029082459.GA6364@elte.hu>
References: <20081028175604.81c31cea.akpm@linux-foundation.org> <20081029074032.GI4985@disturbed>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: xfs-masters@oss.sgi.com, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gon
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:55718 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752294AbYJ2IZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 04:25:27 -0400
Content-Disposition: inline
In-Reply-To: <20081029074032.GI4985@disturbed>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Dave Chinner <david@fromorbit.com> wrote:

> > > fs/xfs/xfs_rtalloc.c: In function `xfs_growfs_rt':
> > > fs/xfs/xfs_rtalloc.c:1875: warning: 'tp' might be used uninitiali=
zed in this function
>=20
> False positive, and I don't get this reported, either.
>=20
> Hold on - the above gcc binary only emits a warning for the=20
> xfs_growfs_rt issue when CONFIG_CC_OPTIMIZE_FOR_SIZE=3Dy is set. It=20
> still doesn't catch the quota bug, though. This is so fucked up....

=46YI, i've got 3 XFS warnings mapped in tip/auto-warnings-next:

 earth4:~/tip> gll linus..auto-warnings-next | grep xfs

 ec2f37c: work around warning in fs/xfs/xfs_mount.c
 8501db3: work around warning in fs/xfs/xfs_rtalloc.c
 8077af8: warnings: fix xfs posix acl

you can find those commits in the auto-warnings-next branch of -tip:

  http://people.redhat.com/mingo/tip.git/README

the rtalloc annotation is below. I went through the flow and the code=20
seems to be correct and GCC is wrong.

	Ingo

------------->
=46rom 8501db35588df4f35d67d8ba207422006a214ae7 Mon Sep 17 00:00:00 200=
1
=46rom: Ingo Molnar <mingo@elte.hu>
Date: Mon, 18 Aug 2008 15:21:19 +0200
Subject: [PATCH] work around warning in fs/xfs/xfs_rtalloc.c
MIME-Version: 1.0
Content-Type: text/plain; charset=3Dutf-8
Content-Transfer-Encoding: 8bit

fix warning:

  fs/xfs/xfs_rtalloc.c: In function =E2=80=98xfs_growfs_rt=E2=80=99:
  fs/xfs/xfs_rtalloc.c:1875: warning: =E2=80=98tp=E2=80=99 may be used =
uninitialized in this function

This is a spurious gcc warning - it does not realize the correct/bug-fr=
ee
flow of logic regarding the 'error' and 'tp' variables.

No code changed:
   7c10fd959065115c8e252ff5a861a01e  xfs_rtalloc.o.before.asm
   7c10fd959065115c8e252ff5a861a01e  xfs_rtalloc.o.after.asm

Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 fs/xfs/xfs_rtalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/xfs/xfs_rtalloc.c b/fs/xfs/xfs_rtalloc.c
index e2f68de..fe5de08 100644
--- a/fs/xfs/xfs_rtalloc.c
+++ b/fs/xfs/xfs_rtalloc.c
@@ -1872,7 +1872,7 @@ xfs_growfs_rt(
 	xfs_extlen_t	rsumblocks;	/* current number of rt summary blks */
 	xfs_sb_t	*sbp;		/* old superblock */
 	xfs_fsblock_t	sumbno;		/* summary block number */
-	xfs_trans_t	*tp;		/* transaction pointer */
+	xfs_trans_t	*uninitialized_var(tp);	/* transaction pointer */
=20
 	sbp =3D &mp->m_sb;
 	cancelflags =3D 0;
