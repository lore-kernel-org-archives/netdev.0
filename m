From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [Patch 1/1] tun: signedness warning
Date: Thu, 1 Jan 2009 11:55:57 +0100
Message-ID: <20090101105557.GA4695@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50930 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755532AbZAAK4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jan 2009 05:56:01 -0500
Received: from laptev.erg.abdn.ac.uk (Debian-exim@ra-gerrit.erg.abdn.ac.uk [139.133.204.38])
	by erg.abdn.ac.uk (8.13.4/8.13.4) with ESMTP id n01AtpsX000224
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 1 Jan 2009 10:55:56 GMT
Received: from gerrit by laptev.erg.abdn.ac.uk with local (Exim 4.69)
	(envelope-from <gerrit@laptev.erg.abdn.ac.uk>)
	id 1LILDZ-0001Ew-26
	for netdev@vger.kernel.org; Thu, 01 Jan 2009 11:55:57 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tun: Eliminate sparse signedness warning

register_pernet_gen_device() expects 'int*', found via sparse.

 CHECK   drivers/net/tun.c
 drivers/net/tun.c:1245:36: warning: incorrect type in argument 1 (different signedness)
 drivers/net/tun.c:1245:36:    expected int *id
 drivers/net/tun.c:1245:36:    got unsigned int static [toplevel] *<noident>

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 tun.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -213,7 +213,7 @@ static int check_filter(struct tap_filter *filter, const struct sk_buff *skb)
 
 /* Network device part of the driver */
 
-static unsigned int tun_net_id;
+static int tun_net_id;
 struct tun_net {
 	struct list_head dev_list;
 };
