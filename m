From: Harald Welte <laforge@gnumonks.org>
Subject: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins hash for neigh / Statistics)
Date: Tue, 28 Sep 2004 13:19:06 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928111906.GB29961@sunbeam.de.gnumonks.org>
References: <20040925005623.2faf8faf.davem@davemloft.net> <E1CBu70-00010X-00@gondolin.me.apana.org.au> <20040927121403.767e2308.davem@davemloft.net> <20040927222613.GE3236@sunbeam.de.gnumonks.org> <20040927160636.7741d973.davem@davemloft.net> <1096327658.1729.19.camel@localhost.localdomain> <16729.9326.93269.422940@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="O5XBE6gyVG5Rl6Rj"
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Content-Disposition: inline
In-Reply-To: <16729.9326.93269.422940@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--O5XBE6gyVG5Rl6Rj
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Content-Disposition: inline


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Sep 28, 2004 at 10:44:30AM +0200, Robert Olsson wrote:
>=20
> Stephen Hemminger writes:
>=20
>  > > Harald Welte <laforge@gnumonks.org> wrote:
>  > >=20
>  > > > As stated before, I would like to change rt_stat and ct_stat in or=
der to
>  > > > include a first 'template' line, too.  This way it is easier to wr=
ite a
>  > > > generic foo_stat program, that could deal with any of those statis=
tics
>  > > > files, even with new ones...  but this of course would break exist=
ing
>  > > > rtstat binaries.  I personally  don't care, since it's a little-kn=
own
>  > > > and little-used feature, which to my knowledge is in a lot of
>  > > > distributions either non-existant [Debian] or incompatible [SuSE].=
 What
>  > > > do you think?
>  > >=20
>  > > I agree.  And while we're add it let's get a fixed rtstat into
>  > > iproute2 and make sure that binary gets installed by default
>  > > so maybe the dists will start shipping it properly.
>  >=20
>  > I have the old one in the repository.
>=20
>  I sent you the latest rtstat (Martin sent ctstat) during netfilter works=
hop.=20
>  Remember? Having a common foo_stat sounds like a good idea.

I'm working on this right now.  The plan is to make the parser code
shared between a commandline tool and some daemon that can be run on
production systems to gather long-term statistics.  You can select the
fields you're interested in with keys like "rt_stat:entries".  Maybe
I'll even add stuff like mysql/pgsql-logging like ulogd has, but that
future plans for now.

I've called it lnstat for now (as in linux networking statistics), but
I'm open to better suggestions on the name ;)

Please find the current kernel-part patch attached to this mail,
it adds teplate-headerlines and moves all statistics files to
/proc/net/stat.  It even cleans up the neigh_stat code a bit.
Depends on my latest neighbour statistics patch that davem has already
merged.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="laforge-rtstat-ctstat-template.patch"
Content-Transfer-Encoding: quoted-printable


This patch moves the following files in /proc:
	/proc/net/rt_cache_stat 	/proc/net/stat/rt_cache
	/proc/net/ip_conntrack_stat	/proc/net/stat/ip_conntrack
	/proc/net/arp_cache_stat	/proc/net/stat/arp_cache
	/proc/net/clip_arp_cache_stat	/proc/net/stat/clib_arp_cache
	/proc/net/dn_neigh_cache_stat	/proc/net/stat/dn_neigh_cache

This allows a generic statistics tool to scan for all available statistics
by doing readdir(2) on /proc/net/stat

It also adds a special first "template" line to rt_cache and ip_conntrack
in order to facilitate compatibility once somebody adds new fields to the
output lines.

WARNING:=20
	This breaks existing rtstat.c and ctstat.c userspace programs
	(hopefully for the last time).  rtstat is non-existant or broken in
	major distributions anyway, and ctstat is too new for any distros
	having it picked up.  Therefore, we justify this breakage.

A new unified statistics tool for routing cache, connection tracking and
neighbour cache is under development and will be included with iproute2.

Signed-off-by: Harald Welte <laforge@gnumonks.org>

Index: linux-2.6.9-rc2-bk9-neigh1/net/ipv4/netfilter/ip_conntrack_standalon=
e.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/net/ipv4/netfilter/ip_conntrack_standal=
one.c	2004-09-28 10:33:07.000000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/net/ipv4/netfilter/ip_conntrack_standalone.c=
	2004-09-28 10:55:17.000000000 +0200
@@ -270,10 +270,13 @@
 {
 	int cpu;
=20
-	for (cpu =3D *pos; cpu < NR_CPUS; ++cpu) {
+	if (*pos =3D=3D 0)
+		return SEQ_START_TOKEN;
+
+	for (cpu =3D *pos-1; cpu < NR_CPUS; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
-		*pos =3D cpu;
+		*pos =3D cpu+1;
 		return &per_cpu(ip_conntrack_stat, cpu);
 	}
=20
@@ -284,10 +287,10 @@
 {
 	int cpu;
=20
-	for (cpu =3D *pos + 1; cpu < NR_CPUS; ++cpu) {
+	for (cpu =3D *pos; cpu < NR_CPUS; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
-		*pos =3D cpu;
+		*pos =3D cpu+1;
 		return &per_cpu(ip_conntrack_stat, cpu);
 	}
=20
@@ -303,6 +306,11 @@
 	unsigned int nr_conntracks =3D atomic_read(&ip_conntrack_count);
 	struct ip_conntrack_stat *st =3D v;
=20
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_printf(seq, "entries  searched found new invalid ignore delete delet=
e_list insert insert_failed drop early_drop icmp_error  expect_new expect_c=
reate expect_delete\n");
+		return 0;
+	}
+
 	seq_printf(seq, "%08x  %08x %08x %08x %08x %08x %08x %08x "
 			"%08x %08x %08x %08x %08x  %08x %08x %08x \n",
 		   nr_conntracks,
@@ -729,10 +737,11 @@
 					&exp_file_ops);
 	if (!proc_exp) goto cleanup_proc;
=20
-	proc_stat =3D proc_net_fops_create("ip_conntrack_stat", S_IRUGO,
-					 &ct_cpu_seq_fops);
+	proc_stat =3D create_proc_entry("ip_conntrack", S_IRUGO, proc_net_stat);
 	if (!proc_stat)
 		goto cleanup_proc_exp;
+
+	proc_stat->proc_fops =3D &ct_cpu_seq_fops;
 	proc_stat->owner =3D THIS_MODULE;
 #endif
=20
Index: linux-2.6.9-rc2-bk9-neigh1/net/ipv4/route.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/net/ipv4/route.c	2004-09-26 12:11:20.00=
0000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/net/ipv4/route.c	2004-09-28 12:12:42.0000000=
00 +0200
@@ -356,10 +356,13 @@
 {
 	int cpu;
=20
-	for (cpu =3D *pos; cpu < NR_CPUS; ++cpu) {
+	if (*pos =3D=3D 0)
+		return SEQ_START_TOKEN;
+
+	for (cpu =3D *pos-1; cpu < NR_CPUS; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
-		*pos =3D cpu;
+		*pos =3D cpu+1;
 		return per_cpu_ptr(rt_cache_stat, cpu);
 	}
 	return NULL;
@@ -369,10 +372,10 @@
 {
 	int cpu;
=20
-	for (cpu =3D *pos + 1; cpu < NR_CPUS; ++cpu) {
+	for (cpu =3D *pos; cpu < NR_CPUS; ++cpu) {
 		if (!cpu_possible(cpu))
 			continue;
-		*pos =3D cpu;
+		*pos =3D cpu+1;
 		return per_cpu_ptr(rt_cache_stat, cpu);
 	}
 	return NULL;
@@ -387,6 +390,11 @@
 static int rt_cpu_seq_show(struct seq_file *seq, void *v)
 {
 	struct rt_cache_stat *st =3D v;
+
+	if (v =3D=3D SEQ_START_TOKEN) {
+		seq_printf(seq, "entries  in_hit in_slow_tot in_no_route in_brd in_marti=
an_dst in_martian_src  out_hit out_slow_tot out_slow_mc  gc_total gc_ignore=
d gc_goal_miss gc_dst_overflow in_hlist_search out_hlist_search\n");
+		return 0;
+	}
 =09
 	seq_printf(seq,"%08x  %08x %08x %08x %08x %08x %08x %08x "
 		   " %08x %08x %08x %08x %08x %08x %08x %08x %08x \n",
@@ -2783,12 +2791,16 @@
 	add_timer(&rt_secret_timer);
=20
 #ifdef CONFIG_PROC_FS
+	{
+	struct proc_dir_entry *rtstat_pde =3D NULL; /* keep gcc happy */
 	if (!proc_net_fops_create("rt_cache", S_IRUGO, &rt_cache_seq_fops) ||
-	    !proc_net_fops_create("rt_cache_stat", S_IRUGO, &rt_cpu_seq_fops)) {
+	    !(rtstat_pde =3D create_proc_entry("rt_cache", S_IRUGO,=20
+			    		     proc_net_stat))) {
 		free_percpu(rt_cache_stat);
 		return -ENOMEM;
 	}
-
+	rtstat_pde->proc_fops =3D &rt_cpu_seq_fops;
+	}
 #ifdef CONFIG_NET_CLS_ROUTE
 	create_proc_read_entry("rt_acct", 0, proc_net, ip_rt_acct_read, NULL);
 #endif
Index: linux-2.6.9-rc2-bk9-neigh1/fs/proc/root.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/fs/proc/root.c	2004-09-13 07:33:11.0000=
00000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/fs/proc/root.c	2004-09-28 11:41:10.000000000=
 +0200
@@ -18,7 +18,7 @@
 #include <asm/bitops.h>
 #include <linux/smp_lock.h>
=20
-struct proc_dir_entry *proc_net, *proc_bus, *proc_root_fs, *proc_root_driv=
er;
+struct proc_dir_entry *proc_net, *proc_net_stat, *proc_bus, *proc_root_fs,=
 *proc_root_driver;
=20
 #ifdef CONFIG_SYSCTL
 struct proc_dir_entry *proc_sys_root;
@@ -53,6 +53,8 @@
 	}
 	proc_misc_init();
 	proc_net =3D proc_mkdir("net", NULL);
+	proc_net_stat =3D proc_mkdir("net/stat", NULL);
+
 #ifdef CONFIG_SYSVIPC
 	proc_mkdir("sysvipc", NULL);
 #endif
@@ -157,5 +159,6 @@
 EXPORT_SYMBOL(proc_root);
 EXPORT_SYMBOL(proc_root_fs);
 EXPORT_SYMBOL(proc_net);
+EXPORT_SYMBOL(proc_net_stat);
 EXPORT_SYMBOL(proc_bus);
 EXPORT_SYMBOL(proc_root_driver);
Index: linux-2.6.9-rc2-bk9-neigh1/include/linux/proc_fs.h
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/include/linux/proc_fs.h	2004-09-13 07:3=
3:39.000000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/include/linux/proc_fs.h	2004-09-28 10:47:17.=
000000000 +0200
@@ -79,6 +79,7 @@
 extern struct proc_dir_entry proc_root;
 extern struct proc_dir_entry *proc_root_fs;
 extern struct proc_dir_entry *proc_net;
+extern struct proc_dir_entry *proc_net_stat;
 extern struct proc_dir_entry *proc_bus;
 extern struct proc_dir_entry *proc_root_driver;
 extern struct proc_dir_entry *proc_root_kcore;
Index: linux-2.6.9-rc2-bk9-neigh1/net/core/neighbour.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- linux-2.6.9-rc2-bk9-neigh1.orig/net/core/neighbour.c	2004-09-28 00:15:5=
1.000000000 +0200
+++ linux-2.6.9-rc2-bk9-neigh1/net/core/neighbour.c	2004-09-28 10:56:44.000=
000000 +0200
@@ -1333,22 +1333,11 @@
 		panic("cannot create neighbour cache statistics");
 =09
 #ifdef CONFIG_PROC_FS
-#define NC_STAT_SUFFIX "_stat"
-	{
-	char *proc_stat_name;
-	proc_stat_name =3D kmalloc(strlen(tbl->id) +=20
-				 strlen(NC_STAT_SUFFIX) + 1, GFP_KERNEL);
-	if (!proc_stat_name)
-		panic("cannot allocate neighbour cache proc name buffer");
-	strcpy(proc_stat_name, tbl->id);
-	strcat(proc_stat_name, NC_STAT_SUFFIX);
-
-	tbl->pde =3D create_proc_entry(proc_stat_name, 0, proc_net);
+	tbl->pde =3D create_proc_entry(tbl->id, 0, proc_net_stat);
 	if (!tbl->pde)=20
 		panic("cannot create neighbour proc dir entry");
 	tbl->pde->proc_fops =3D &neigh_stat_seq_fops;
 	tbl->pde->data =3D tbl;
-	}
 #endif
=20
 	tbl->hash_mask =3D 0x1f;

--YZ5djTAD1cGYuMQK--

--O5XBE6gyVG5Rl6Rj
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBWUiqXaXGVTD0i/8RAjFKAKCUo+k3hIQQP3mZAobRwH6c+/avIACfRLVN
S6mXt6Z4qSsj5/dENKb2Px4=
=qISG
-----END PGP SIGNATURE-----

--O5XBE6gyVG5Rl6Rj--
