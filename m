From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH ipsec-next v3 0/2] IPsec: do not ignore crypto err in ah input
Date: Mon, 16 Jan 2017 13:17:54 +0200
Message-ID: <1484565476-19371-1-git-send-email-gilad@benyossef.com>
Cc: ofir.drang@arm.com, gilad.benyossef@arm.com,
        Alexander Alemayhu <alexander@alemayhu.com>
To: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:50202 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751074AbdAPLSK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 06:18:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ah input processing uses the asynchronous hash crypto API which
supplies an error code as part of the operation completion but
the error code was being ignored.

Treat a crypto API error indication as a verification failure.

While a crypto API reported error would almost certainly result
in a memcpy of the digest failing anyway and thus the security
risk seems minor, performing a memory compare on what might be
uninitialized memory is wrong.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Alexander Alemayhu <alexander@alemayhu.com>
---

The change was boot tested on Arm64 but I did not exercise
the specific error code path in question.

Changes from v2:
- Added fix for same problem in IPv6 pointed out by Steffen Klassert

Changes from v1:
- Fixed typo in patch description pointed out by Alexander

Gilad Ben-Yossef (2):
  IPsec: do not ignore crypto err in ah4 input
  IPsec: do not ignore crypto err in ah6 input

 net/ipv4/ah4.c | 3 +++
 net/ipv6/ah6.c | 3 +++
 2 files changed, 6 insertions(+)

-- 
2.1.4
