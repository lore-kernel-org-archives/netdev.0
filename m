From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/ipv4/ip_output.c:ip_send_check() mustn't be inline
Date: Mon, 28 Apr 2008 18:38:42 +0300
Message-ID: <20080428153842.GF2813@cs181133002.pp.htv.fi>
References: <20080424215739.GA32378@elte.hu> <alpine.LFD.1.10.0804241510420.2779@woody.linux-foundation.org> <20080426151516.GA27894@elte.hu> <alpine.LFD.1.10.0804260955300.2813@woody.linux-foundation.org> <20080426172222.GD17345@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Alexander van Heukelum <heukelum@mailshack.com>,
	jdike@addtoit.com, Ingo Molnar <mingo@elte.hu>,
	netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:34998 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935887AbYD1PjP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 11:39:15 -0400
Content-Disposition: inline
In-Reply-To: <20080426172222.GD17345@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following build error with UML and gcc 4.3:

<--  snip  -->

=2E..
  CC      net/ipv4/ip_output.o
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/ip_output.c: In func=
tion =E2=80=98__ip_local_out=E2=80=99:
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/ip_output.c:89: sorr=
y, unimplemented: inlining failed in call to =E2=80=98ip_send_check=E2=80=
=99: function body not available
/home/bunk/linux/kernel-2.6/git/linux-2.6/net/ipv4/ip_output.c:99: sorr=
y, unimplemented: called from here
make[3]: *** [net/ipv4/ip_output.o] Error 1

<--  snip  -->

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
936e490777359bfde622148ff5af1e19d8c248b5 diff --git a/net/ipv4/ip_outpu=
t.c b/net/ipv4/ip_output.c
index 0834926..985a719 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -85,7 +85,7 @@
 int sysctl_ip_default_ttl __read_mostly =3D IPDEFTTL;
=20
 /* Generate a checksum for an outgoing IP datagram. */
-__inline__ void ip_send_check(struct iphdr *iph)
+void ip_send_check(struct iphdr *iph)
 {
 	iph->check =3D 0;
 	iph->check =3D ip_fast_csum((unsigned char *)iph, iph->ihl);

