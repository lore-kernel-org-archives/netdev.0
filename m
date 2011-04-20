From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 3/9] sctp: remove redundant check when walking
 through a list of TLV parameters
Date: Wed, 20 Apr 2011 15:27:07 +0800
Message-ID: <4DAE8ACB.9060006@cn.fujitsu.com>
References: <4DAE8A27.3040007@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62808 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753450Ab1DTH1F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 03:27:05 -0400
In-Reply-To: <4DAE8A27.3040007@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>

When  pos.v <= (void *)chunk + end - ntohs(pos.p->length) and
ntohs(pos.p->length) >= sizeof(sctp_paramhdr_t) these two expressions are all true,
pos.v <= (void *)chunk + end - sizeof(sctp_paramhdr_t) *must* be true.

This patch removes this kind of redundant check.
It's same to  _sctp_walk_errors macro.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 include/net/sctp/sctp.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 505845d..7e8e34c 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -531,7 +531,6 @@ _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
 
 #define _sctp_walk_params(pos, chunk, end, member)\
 for (pos.v = chunk->member;\
-     pos.v <= (void *)chunk + end - sizeof(sctp_paramhdr_t) &&\
      pos.v <= (void *)chunk + end - ntohs(pos.p->length) &&\
      ntohs(pos.p->length) >= sizeof(sctp_paramhdr_t);\
      pos.v += WORD_ROUND(ntohs(pos.p->length)))
@@ -542,7 +541,6 @@ _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_hdr)->length))
 #define _sctp_walk_errors(err, chunk_hdr, end)\
 for (err = (sctp_errhdr_t *)((void *)chunk_hdr + \
 	    sizeof(sctp_chunkhdr_t));\
-     (void *)err <= (void *)chunk_hdr + end - sizeof(sctp_errhdr_t) &&\
      (void *)err <= (void *)chunk_hdr + end - ntohs(err->length) &&\
      ntohs(err->length) >= sizeof(sctp_errhdr_t); \
      err = (sctp_errhdr_t *)((void *)err + WORD_ROUND(ntohs(err->length))))
-- 
1.6.5.2


