From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] Net: rxrpc: signed and unsigned issue, need type cast for
 n_elem.
Date: Mon, 22 Apr 2013 18:24:00 +0800
Message-ID: <51750FC0.8000603@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"dhowells@redhat.com" <dhowells@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Serge Hallyn <serge.hallyn@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:33271 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab3DVKYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 06:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  n_elem is unsigned int which never < 0.
  but it seems, we realy need check it whether < 0.
  so need a type cast for it.

  find it by EXTRA_CFLAGS=-W


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/rxrpc/ar-key.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 7633a75..ba0b722 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -346,7 +346,7 @@ static int rxrpc_krb5_decode_tagged_array(struct krb5_tagged_data **_td,
 
 	n_elem = ntohl(*xdr++);
 	toklen -= 4;
-	if (n_elem < 0 || n_elem > max_n_elem)
+	if ((int)n_elem < 0 || n_elem > max_n_elem)
 		return -EINVAL;
 	*_n_elem = n_elem;
 	if (n_elem > 0) {
-- 
1.7.7.6
