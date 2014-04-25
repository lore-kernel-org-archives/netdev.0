From: Brendan Hickey <bhickey@google.com>
Subject: [PATCH] tools: bpf_dbg: register misuse
Date: Fri, 25 Apr 2014 16:52:45 -0400
Message-ID: <CA+Z8YJKFhGQ5QPjMS6PHZnDpGJ7osrCJGDw+AMAPMckKiB8EDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: dborkman@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:58100 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbaDYUxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 16:53:06 -0400
Received: by mail-vc0-f179.google.com with SMTP id ij19so5416273vcb.38
        for <netdev@vger.kernel.org>; Fri, 25 Apr 2014 13:53:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed a mistaken use of the X register instead of the K register
in bpf_dbg. Enclosed is a fix.

Brendan


From: Brendan Hickey <bhickey@google.com>
Date: Fri, 25 Apr 2014 15:54:13 -0400
Subject: [PATCH] bpf_dbg: Fix erroneous register use for AND

The AND instruction is erroneously using the X register instead of the K
register.
---
 tools/net/bpf_dbg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
index 65dc757..5e54848 100644
--- a/tools/net/bpf_dbg.c
+++ b/tools/net/bpf_dbg.c
@@ -823,7 +823,7 @@ do_div:
  r->A &= r->X;
  break;
  case BPF_ALU_AND | BPF_K:
- r->A &= r->X;
+ r->A &= K;
  break;
  case BPF_ALU_OR | BPF_X:
  r->A |= r->X;


--
1.9.1.423.g4596e3a
