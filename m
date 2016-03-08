From: Nick Wang <nwang@suse.com>
Subject: [PATCH] include/net/inet_connection_sock.h: Use pr_devel() instead of pr_debug()
Date: Tue,  8 Mar 2016 13:52:28 +0800
Message-ID: <1457416348-32463-1-git-send-email-nwang@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: whs_alex@163.com, nwang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nick Wang <nwang@suse.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:33689 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbcCHFyE (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:0:0>);
	Tue, 8 Mar 2016 00:54:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When DYNAMIC_DEBUG enabled, pr_debug() depends on KBUILD_MODNAME which
also depends on the modules name in Makefile.
Refer to the information in "scripts/Makefile.lib":

 # $(modname_flags) #defines KBUILD_MODNAME as the name of the module i=
t will
 # end up in (or would, if it gets compiled in)
 # Note: Files that end up in two or more modules are compiled without =
the
 #       KBUILD_MODNAME definition. The reason is that any made-up name=
 would
 #       differ in different configs.

=46ile "inet_connection_sock.h" is a common share header that not can=20
be use for one module, so use pr_devel instead of pr_debug is OK.

In file included from include/linux/printk.h:277:0,
                 from include/linux/kernel.h:13,
                 from include/linux/list.h:8,
                 from include/linux/kobject.h:20,
                 from include/linux/device.h:17,
                 from include/rdma/ib_verbs.h:43,
                 from /usr/src/drbd-9.0/drbd/drbd-kernel-compat/tests/h=
ave_ib_cq_init_attr.c:1:
include/net/inet_connection_sock.h: In function =E2=80=98inet_csk_clear=
_xmit_timer=E2=80=99:
include/linux/dynamic_debug.h:66:14: error: =E2=80=98KBUILD_MODNAME=E2=80=
=99 undeclared (first use in this function)
   .modname =3D KBUILD_MODNAME,   \
              ^
include/linux/dynamic_debug.h:76:2: note: in expansion of macro =E2=80=98=
DEFINE_DYNAMIC_DEBUG_METADATA=E2=80=99
  DEFINE_DYNAMIC_DEBUG_METADATA(descriptor, fmt);  \
  ^
include/linux/printk.h:283:2: note: in expansion of macro =E2=80=98dyna=
mic_pr_debug=E2=80=99
  dynamic_pr_debug(fmt, ##__VA_ARGS__)
  ^
include/net/inet_connection_sock.h:213:3: note: in expansion of macro =E2=
=80=98pr_debug=E2=80=99
   pr_debug("%s", inet_csk_timer_bug_msg);
   ^

Signed-off-by: Nick Wang <nwang@suse.de>
---
 include/net/inet_connection_sock.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_conn=
ection_sock.h
index 49dcad4..b59be52 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -210,7 +210,7 @@ static inline void inet_csk_clear_xmit_timer(struct=
 sock *sk, const int what)
 	}
 #ifdef INET_CSK_DEBUG
 	else {
-		pr_debug("%s", inet_csk_timer_bug_msg);
+		pr_devel("%s", inet_csk_timer_bug_msg);
 	}
 #endif
 }
@@ -226,7 +226,7 @@ static inline void inet_csk_reset_xmit_timer(struct=
 sock *sk, const int what,
=20
 	if (when > max_when) {
 #ifdef INET_CSK_DEBUG
-		pr_debug("reset_xmit_timer: sk=3D%p %d when=3D0x%lx, caller=3D%p\n",
+		pr_devel("reset_xmit_timer: sk=3D%p %d when=3D0x%lx, caller=3D%p\n",
 			 sk, what, when, current_text_addr());
 #endif
 		when =3D max_when;
@@ -244,7 +244,7 @@ static inline void inet_csk_reset_xmit_timer(struct=
 sock *sk, const int what,
 	}
 #ifdef INET_CSK_DEBUG
 	else {
-		pr_debug("%s", inet_csk_timer_bug_msg);
+		pr_devel("%s", inet_csk_timer_bug_msg);
 	}
 #endif
 }
--=20
1.8.5.6
