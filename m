From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 0/2] gue: Generalize remote checksum offload
Date: Tue, 25 Nov 2014 11:21:18 -0800
Message-ID: <1416943280-28473-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:54748 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbaKYTVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 14:21:39 -0500
Received: by mail-ie0-f179.google.com with SMTP id rp18so1158944iec.24
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 11:21:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The remote checksum offload is generalized by creating a common
function (remcsum_adjust) that does the work of modifying the
checksum in remote checksum offload. This function can be called
from normal or GRO path. GUE was modified to use this function.

Remote checksum offload is described in
https://tools.ietf.org/html/draft-herbert-remotecsumoffload-01

Tested by running 200 TCP_STREAM connections over GUE, did not see
any problems with remote checksum offload enabled.

Tom Herbert (2):
  net: Add remcsum_adjust as common function for remote checksum offload
  gue: Call remcsum_adjust

 include/net/checksum.h | 16 ++++++++++
 net/ipv4/fou.c         | 84 ++++++++++----------------------------------------
 2 files changed, 33 insertions(+), 67 deletions(-)

-- 
2.1.0.rc2.206.gedb03e5
