From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] bpf_dbg: fix wrong register usage
Date: Wed, 30 Apr 2014 10:24:38 +0200
Message-ID: <1398846278-1053-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Brendan Hickey <bhickey@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757781AbaD3IYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2014 04:24:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brendan Hickey <bhickey@google.com>

The AND instruction is erroneously using the X register instead
of the K register.

Signed-off-by: Brendan Hickey <bhickey@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 Resending correctly for Brendan. (I'm back from vaction on 11th
 of May, so I don't have much Internet access, I didn't want to
 get this one lost in meantime though.)

 tools/net/bpf_dbg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/net/bpf_dbg.c b/tools/net/bpf_dbg.c
index bb31813..9a287be 100644
--- a/tools/net/bpf_dbg.c
+++ b/tools/net/bpf_dbg.c
@@ -820,7 +820,7 @@ do_div:
 		r->A &= r->X;
 		break;
 	case BPF_ALU_AND | BPF_K:
-		r->A &= r->X;
+		r->A &= K;
 		break;
 	case BPF_ALU_OR | BPF_X:
 		r->A |= r->X;
-- 
1.7.11.7
