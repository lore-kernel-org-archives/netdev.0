From: David Miller <davem@davemloft.net>
Subject: Re: drivers/net/niu.c: possible array overflows
Date: Mon, 15 Oct 2007 01:36:47 -0700 (PDT)
Message-ID: <20071015.013647.95041541.davem@davemloft.net>
References: <20071014175024.GH4211@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@sunset.davemloft.net, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47026
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755075AbXJOIgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:36:42 -0400
In-Reply-To: <20071014175024.GH4211@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 14 Oct 2007 19:50:24 +0200

> The Coverity checker spotted the following in drivers/net/niu.c:

Thanks for the report Adrian, I'll fix it like this:

commit 503211a947ab13fb44d920f78f1e19057efc277f
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Mon Oct 15 01:36:24 2007 -0700

    [NIU]: Fix write past end of array in niu_pci_probe_sprom().
    
    Noticed by Coverity checker and reported by Adrian Bunk.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 43bfe7e..54166bd 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -6213,7 +6213,7 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	val = nr64(ESPC_MOD_STR_LEN);
 	niudbg(PROBE, "SPROM: MOD_STR_LEN[%llu]\n",
 	       (unsigned long long) val);
-	if (val > 8 * 4)
+	if (val >= 8 * 4)
 		return -EINVAL;
 
 	for (i = 0; i < val; i += 4) {
@@ -6229,7 +6229,7 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	val = nr64(ESPC_BD_MOD_STR_LEN);
 	niudbg(PROBE, "SPROM: BD_MOD_STR_LEN[%llu]\n",
 	       (unsigned long long) val);
-	if (val > 4 * 4)
+	if (val >= 4 * 4)
 		return -EINVAL;
 
 	for (i = 0; i < val; i += 4) {
