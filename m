From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [RFC] Inverse of flowi{4,6}_oif: flowi{4,6}_not_oif
Date: Wed, 3 Feb 2016 15:27:47 +0100
Message-ID: <CAHmME9pGKeM9=qqcxrN12ELtTjhwgBkPV0K3ixfVz3a_CBugAw@mail.gmail.com>
References: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:44146 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751742AbcBCO1w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 09:27:52 -0500
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id d563679a
	for <netdev@vger.kernel.org>;
	Wed, 3 Feb 2016 14:26:42 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 4ad5b261
	TLS version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=YES
	for <netdev@vger.kernel.org>;
	Wed, 3 Feb 2016 14:26:40 +0000 (UTC)
Received: by mail-wm0-f49.google.com with SMTP id 128so168014270wmz.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 06:27:48 -0800 (PST)
In-Reply-To: <CAHmME9pgwgjKJAFH2=sEEMJauno_rVEzY6JORTQze91Xo5zefw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FYI, for v4 at least, it's ridiculously easy and simple to implement:

=~=~=~=~=~=~=~=~=

diff --git a/include/net/flow.h b/include/net/flow.h
index 83969ee..29967ad 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -26,6 +26,7 @@ struct flowi_tunnel {

 struct flowi_common {
  int flowic_oif;
+ int flowic_not_oif;
  int flowic_iif;
  __u32 flowic_mark;
  __u8 flowic_tos;
@@ -67,6 +68,7 @@ union flowi_uli {
 struct flowi4 {
  struct flowi_common __fl_common;
 #define flowi4_oif  __fl_common.flowic_oif
+#define flowi4_not_oif  __fl_common.flowic_not_oif
 #define flowi4_iif  __fl_common.flowic_iif
 #define flowi4_mark  __fl_common.flowic_mark
 #define flowi4_tos  __fl_common.flowic_tos
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 7aea0cc..d03e991 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1429,6 +1429,8 @@ found:
         flp->flowi4_oif != nh->nh_oif)
      continue;
    }
+   if (flp->flowi4_not_oif && flp->flowi4_not_oif == nh->nh_oif)
+    continue;

    if (!(fib_flags & FIB_LOOKUP_NOREF))
     atomic_inc(&fi->fib_clntref);
