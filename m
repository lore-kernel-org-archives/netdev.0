From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the akpm-current tree with the net tree
Date: Wed, 28 Aug 2013 18:09:40 +1000
Message-ID: <20130828180940.b571fb3354d4d95a9ac0e04f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__28_Aug_2013_18_09_40_+1000_X03=4LYTJEDF0C3X"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andy Lutomirski <luto@amacapital.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__28_Aug_2013_18_09_40_+1000_X03=4LYTJEDF0C3X
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

Today's linux-next merge of the akpm-current tree got a conflict in
kernel/fork.c between commit c2b1df2eb429 ("Rename nsproxy.pid_ns to
nsproxy.pid_ns_for_children") from the net tree and commits 74a7cb7237ad
("pidns: fix vfork() after unshare(CLONE_NEWPID)"), 98c53a09f937 ("pidns:
kill the unnecessary CLONE_NEWPID in copy_process()") and ddb3b016a3f7
("fork: unify and tighten up CLONE_NEWUSER/CLONE_NEWPID checks") from the
akpm-current tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc kernel/fork.c
index df6e2a8,04a8c2a..0000000
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@@ -1173,13 -1171,15 +1171,16 @@@ static struct task_struct *copy_process
  		return ERR_PTR(-EINVAL);
 =20
  	/*
- 	 * If the new process will be in a different pid namespace
- 	 * don't allow the creation of threads.
+ 	 * If the new process will be in a different pid or user namespace
+ 	 * do not allow it to share a thread group or signal handlers or
+ 	 * parent with the forking task.
  	 */
- 	if ((clone_flags & (CLONE_VM|CLONE_NEWPID)) &&
- 	    (task_active_pid_ns(current) !=3D
- 	     current->nsproxy->pid_ns_for_children))
- 		return ERR_PTR(-EINVAL);
+ 	if (clone_flags & (CLONE_SIGHAND | CLONE_PARENT)) {
+ 		if ((clone_flags & (CLONE_NEWUSER | CLONE_NEWPID)) ||
 -		    (task_active_pid_ns(current) !=3D current->nsproxy->pid_ns))
++		    (task_active_pid_ns(current) !=3D
++		     current->nsproxy->pid_ns_for_children))
+ 			return ERR_PTR(-EINVAL);
+ 	}
 =20
  	retval =3D security_task_create(clone_flags);
  	if (retval)

--Signature=_Wed__28_Aug_2013_18_09_40_+1000_X03=4LYTJEDF0C3X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSHbBIAAoJEECxmPOUX5FEWugP/0NGmWV04tV5DD/hX36DKAYs
GocVd5SR5Ri+fm3aAiP0cuf2ec4Sm4bpI/oAYhsje62oJjysVCxKgs75ws2LWfpt
DJN8t4RBGpl5PErqN4qn8PX4Z2WwwFlQ5WO3BuN7K+XWPgMIxzc/ua26ALAJXf3l
uN9EDQ8xB2hJmWpkTm1AuJRI1K8RtUBe4ZNF5NfUaFqDpuU3G9C2ewnuXOqDfBpm
c96Kk6tcXSDsAu3jnbUtdGJN5j7KxpqiP2+SWybrFOyCPfwNVxFwMRunPYZWF5y9
jyxH43tHkJg5vyMCRDwOsNRe17rJjA9NdvYISJf6U70s8usZTdxpwLpXvsFWHImq
9E1Dkd1Ctw02bVBL1XFIml7Wr+WHzHfsQomLGnpF7xEwB+/sM3uVhAJ/DsQzrn2s
DjT0oThiFfFNmakc6hFOVrUcZH9T2RV+8yc7uwYNdWtI9NwWetIPQ/4tDo9d9BqE
sbr2QBLEGjXAGNoZ+1nIQBR5zVJ2xyNdVpzf1WoWcwOHVjt4mBtJl8ak41Q3SxWs
PCM6BYDJQnhcs2Qn6O3cgSJt/NlzCXBydOhxa3tFSsaWpySZLtqpRkRwd1SZDBjA
2fISof93N3IAf3LVJws2buC4MWXw6CTGNStoZ7Ze33YU7JbsWtl9NdLPO505ySwK
p5eqcsRBqWWZPb2WyTIB
=NwuK
-----END PGP SIGNATURE-----

--Signature=_Wed__28_Aug_2013_18_09_40_+1000_X03=4LYTJEDF0C3X--
