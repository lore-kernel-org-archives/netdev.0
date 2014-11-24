From: Andy Lutomirski <luto@amacapital.net>
Subject: [PATCH] net-timestamp: Fix a documentation typo
Date: Mon, 24 Nov 2014 12:02:29 -0800
Message-ID: <ca6ac789334c26905d86f2a596878d2dc18e69e9.1416859110.git.luto@amacapital.net>
Cc: Andy Lutomirski <luto@amacapital.net>,
	Willem de Bruijn <willemb@google.com>
To: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:37805 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705AbaKXUCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 15:02:35 -0500
Received: by mail-pd0-f170.google.com with SMTP id fp1so10334533pdb.15
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2014 12:02:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SOF_TIMESTAMPING_OPT_ID puts the id in ee_data, not ee_info.

Cc: Willem de Bruijn <willemb@google.com>
Signed-off-by: Andy Lutomirski <luto@amacapital.net>
---

While I'm here, the docs say:

    In practice, it [ee_data] is a monotonically increasing u32 (that wraps).

Is user code supposed to rely on this and, further, on the fact that the
counter starts at zero?  If not, how else is user code supposed to match
outgoing data to timestamps?

Also, is it intentional that the payload data associated with the tx
timestamp is (I think) the full outgoing packet including lower-layer
headers?

And, finally, would it be possible to attach IP_PKTINFO to the looped
timestamp?  That way I could finally update my fancy ping program to
track which outgoing interface was used for a request.

 Documentation/networking/timestamping.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/timestamping.txt b/Documentation/networking/timestamping.txt
index 412f45ca2d73..1d6d02d6ba52 100644
--- a/Documentation/networking/timestamping.txt
+++ b/Documentation/networking/timestamping.txt
@@ -136,7 +136,7 @@ SOF_TIMESTAMPING_OPT_ID:
 
   This option is implemented only for transmit timestamps. There, the
   timestamp is always looped along with a struct sock_extended_err.
-  The option modifies field ee_info to pass an id that is unique
+  The option modifies field ee_data to pass an id that is unique
   among all possibly concurrently outstanding timestamp requests for
   that socket. In practice, it is a monotonically increasing u32
   (that wraps).
-- 
1.9.3
