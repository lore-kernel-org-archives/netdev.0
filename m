From: Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>
Subject: [PATCH] hugetlb: release pages in the error path of hugetlb_cow()
 (was: Re: 3.2-rc2+: Reported regressions from 3.0 and 3.1)
Date: Mon, 28 Nov 2011 09:33:13 +0100
Message-ID: <20111128083313.GA18337@tiehlicka.suse.cz>
References: <lx6sezwGldO.A.IhF.UBpWOB@chimera>
 <201111212249.31196.rjw@sisk.pl>
 <CA+55aFygSFt+O5KLoiE_0V+o45eKfsoDDV5ML8EF=J0n9z_D-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Florian Mickler <florian-sVu6HhrpSfRAfugRpC6u6w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFygSFt+O5KLoiE_0V+o45eKfsoDDV5ML8EF=J0n9z_D-Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon 21-11-11 14:18:29, Linus Torvalds wrote:
> On Mon, Nov 21, 2011 at 1:49 PM, Rafael J. Wysocki <rjw-KKrjLPT3xs0@public.gmane.org> wrot=
e:
> >
> > Subject =A0 =A0: hugetlb oops on 3.1.0-rc8-devel
> > Submitter =A0: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> > Date =A0 =A0 =A0 : 2011-11-01 22:20
> > Message-ID : CALCETrW1mpVCz2tO5roaz1r6vnno+srHR-dHA6_pkRi2qiCfdw@ma=
il.gmail.com
> > References : http://marc.info/?l=3Dlinux-kernel&m=3D132018604426692=
&w=3D2
>=20
> Despite the subject line, that's not an oops, it's a BUG_ON().
>=20
> And it *should* be fixed by commit ea4039a34c4c ("hugetlb: release
> pages in the error path of hugetlb_cow()") although I don't think And=
y
> ever confirmed that (since it was hard to trigger).

AFAICS the issue has been introduced by 0fe6e20b (hugetlb, rmap:
add reverse mapping for hugepage) in 2.6.36-rc1 so this is a stable
material. I do not see the patch in any stable branch so here we go.
The patch is on top of 3.0.y branch and it applies as is to 3.1.y
as well.
---
=46rom fdaa4aaa008cce149a5fd60934112acd8988e0b6 Mon Sep 17 00:00:00 200=
1
=46rom: Hillf Danton <dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue, 15 Nov 2011 14:36:12 -0800
Subject: [PATCH] hugetlb: release pages in the error path of hugetlb_co=
w()

commit ea4039a34c4c206d015d34a49d0b00868e37db1d upstream.

If we fail to prepare an anon_vma, the {new, old}_page should be releas=
ed,
or they will leak.

Signed-off-by: Hillf Danton <dhillf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Andrea Arcangeli <aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Hugh Dickins <hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Johannes Weiner <jweiner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Signed-off-by: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---
 mm/hugetlb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bfcf153..2b57cd9 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2415,6 +2415,8 @@ retry_avoidcopy:
 	 * anon_vma prepared.
 	 */
 	if (unlikely(anon_vma_prepare(vma))) {
+		page_cache_release(new_page);
+		page_cache_release(old_page);
 		/* Caller expects lock to be held */
 		spin_lock(&mm->page_table_lock);
 		return VM_FAULT_OOM;
--=20
1.7.7.3


--=20
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9   =20
Czech Republic
