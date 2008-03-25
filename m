From: Hideo AOKI <haoki@redhat.com>
Subject: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Tue, 25 Mar 2008 14:39:04 -0400
Message-ID: <47E946C8.6020006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Hideo AOKI <haoki@redhat.com>
To: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757186AbYCYSrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 14:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

This patch set fixes a potential bug in pskb_expand_head().

Current pskb_expand_head() doesn't change truesize, while it
reallocates memory. Then, if argument nhead or ntail aren't 0, caller
must update truesize.

We had this bug at audit_expand() in January and fixed it as commit
406a1d868001423c85a3165288e566e65f424fe6. However, some drivers and
subsystems still use pskb_expand_head() without updating truesize.

In addition, there is another problem to update truesise. Since
pskb_expand_head() aligns memory size before reallocation, caller
functions may not update turesize correctly if they just add nhaad
and ntail to turesize.

To solve above problems, this patch set does the following:

  - updating truesize in pskb_expand_head()
  - removing turesize update due to pskb_expand_head() from caller
    functions

This patch set can be applied to net-2.6.

Comments and suggestions are welcome.

Best regards,
Hideo Aoki

-- 
Hitachi Computer Products (America) Inc.
