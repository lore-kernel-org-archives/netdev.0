From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v9 0/9] Request for inclusion: per-cgroup tcp memory
 pressure controls
Date: Tue, 13 Dec 2011 14:59:08 +0100
Message-ID: <1323784748.2950.4.camel@edumazet-laptop>
References: <1323676029-5890-1-git-send-email-glommer@parallels.com>
	 <20111212.190734.1967808916779299221.davem@davemloft.net>
	 <4EE757D7.6060006@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: David Miller <davem@davemloft.net>, glommer@parallels.com,
	linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com,
	kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, gthelen@google.com,
	netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name,
	avagin@parallels.com, devel@openvz.org, cgroups@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4EE757D7.6060006@uclouvain.be>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Le mardi 13 d=C3=A9cembre 2011 =C3=A0 14:49 +0100, Christoph Paasch a =C3=
=A9crit :

> now there are plenty of compiler-warnings when CONFIG_CGROUPS is not se=
t:
>=20
> In file included from include/linux/tcp.h:211:0,
>                  from include/linux/ipv6.h:221,
>                  from include/net/ip_vs.h:23,
>                  from kernel/sysctl_binary.c:6:
> include/net/sock.h:67:57: warning: =E2=80=98struct cgroup_subsys=E2=80=99=
 declared
> inside parameter list [enabled by default]
> include/net/sock.h:67:57: warning: its scope is only this definition or
> declaration, which is probably not what you want [enabled by default]
> include/net/sock.h:67:57: warning: =E2=80=98struct cgroup=E2=80=99 decl=
ared inside
> parameter list [enabled by default]
> include/net/sock.h:68:61: warning: =E2=80=98struct cgroup_subsys=E2=80=99=
 declared
> inside parameter list [enabled by default]
> include/net/sock.h:68:61: warning: =E2=80=98struct cgroup=E2=80=99 decl=
ared inside
> parameter list [enabled by default]
>=20
>=20
> Because struct cgroup is only declared if CONFIG_CGROUPS is enabled.
> (cfr. linux/cgroup.h)
>=20

Yes, we probably need forward reference like this :

Thanks !

[PATCH net-next] net: fix build error if CONFIG_CGROUPS=3Dn

Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index 18ecc99..6fe0dae 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -64,6 +64,8 @@
 #include <net/dst.h>
 #include <net/checksum.h>
=20
+struct cgroup;
+struct cgroup_subsys;
 int mem_cgroup_sockets_init(struct cgroup *cgrp, struct cgroup_subsys *s=
s);
 void mem_cgroup_sockets_destroy(struct cgroup *cgrp, struct cgroup_subsy=
s *ss);
 /*


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
