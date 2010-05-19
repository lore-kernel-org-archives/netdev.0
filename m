From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH] bfin_mac: fix memleak in mii_bus{probe|remove}
Date: Wed, 19 May 2010 09:18:15 +0400
Message-ID: <20100519051814.GA4493@coldcone>
References: <20100518092839.GA21791@coldcone>
 <AANLkTikcB3f0KmkcnDsV46Xrpm3WcCLQklxbLSJfMTlW@mail.gmail.com>
 <20100518113445.GA28386@coldcone>
 <20100518.141318.45114681.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: michael.hennerich@analog.com, sonic.zhang@analog.com,
	cooloney@kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:47666 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab0ESFQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 01:16:15 -0400
Received: by fxm10 with SMTP id 10so1885592fxm.19
        for <netdev@vger.kernel.org>; Tue, 18 May 2010 22:16:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100518.141318.45114681.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 18, 2010 at 14:13 -0700, David Miller wrote:
> From: Denis Kirjanov <kirjanov@gmail.com>
> Date: Tue, 18 May 2010 15:34:46 +0400
> 
> > [PATCH] bfin_mac: fix memleak in mii_bus_{probe|remove}
> > Fix memory leak with miibus->irq
> > 
> > Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
> 
> I've already applied the original patch.
> 
> Therefore, it makes no sense to send a fresh complete version
> of the original patch to fix this.
> 
> You'll need to send a relative patch against the other one to
> fix the problem.
Ok, here it is. Sorry for the previous one.

[PATCH] bfin_mac: fix invalid pointer dereference in bfin_mii_bus_probe
Fix invalid memory access.

Signed-off-by: Denis Kirjanov: <dkirjanov@kernel.org>
---

drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 7a17b8a..368f333 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -1626,8 +1626,8 @@ static int __devinit bfin_mii_bus_probe(struct platform_device *pdev)
 	return 0;
 
 out_err_mdiobus_register:
-	mdiobus_free(miibus);
 	kfree(miibus->irq);
+	mdiobus_free(miibus);
 out_err_alloc:
 	peripheral_free_list(pin_req);
 
