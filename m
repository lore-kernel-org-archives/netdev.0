From: Cong Wang <cwang@twopensource.com>
Subject: Compile error: 'nf_skb_duplicated' undeclared (first use in this function)
Date: Mon, 24 Aug 2015 22:26:53 -0700
Message-ID: <CAHA+R7Opb8En7zsKjUL09h0SvUD8zDTbCr=hb25A3f3upjF-cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:36452 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbHYF0y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 01:26:54 -0400
Received: by ykfw73 with SMTP id w73so145294870ykf.3
        for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 22:26:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I just got:

net/ipv4/netfilter/nf_dup_ipv4.c: In function =E2=80=98nf_dup_ipv4=E2=80=
=99:
net/ipv4/netfilter/nf_dup_ipv4.c:72:16: error: =E2=80=98nf_skb_duplicat=
ed=E2=80=99
undeclared (first use in this function)
  if (this_cpu_read(nf_skb_duplicated))
                ^
net/ipv4/netfilter/nf_dup_ipv4.c:72:16: note: each undeclared
identifier is reported only once for each function it appears in

And the following patch could fix it, but I haven't looked into it
yet, maybe some Kconfig symbol dependency issue too.

diff --git a/net/ipv4/netfilter/nf_dup_ipv4.c b/net/ipv4/netfilter/nf_d=
up_ipv4.c
index b5bb375..2d79e6e 100644
--- a/net/ipv4/netfilter/nf_dup_ipv4.c
+++ b/net/ipv4/netfilter/nf_dup_ipv4.c
@@ -13,6 +13,7 @@
 #include <linux/percpu.h>
 #include <linux/route.h>
 #include <linux/skbuff.h>
+#include <linux/netfilter.h>
 #include <net/checksum.h>
 #include <net/icmp.h>
 #include <net/ip.h>
diff --git a/net/ipv6/netfilter/nf_dup_ipv6.c b/net/ipv6/netfilter/nf_d=
up_ipv6.c
index d8ab654..89c2624 100644
--- a/net/ipv6/netfilter/nf_dup_ipv6.c
+++ b/net/ipv6/netfilter/nf_dup_ipv6.c
@@ -11,6 +11,7 @@
 #include <linux/module.h>
 #include <linux/percpu.h>
 #include <linux/skbuff.h>
+#include <linux/netfilter.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/netfilter/ipv6/nf_dup_ipv6.h>
