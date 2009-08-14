From: Davidlohr Bueso <dave@gnu.org>
Subject: Re: [PATCH] s2io: Remove unnecessary casts
Date: Thu, 13 Aug 2009 23:57:33 -0400
Message-ID: <20090814035733.GA29707@fencepost.gnu.org>
References: <20090814020328.GA21588@fencepost.gnu.org> <20090813.201452.21119996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ram.vepa@neterion.com, santosh.rastapur@neterion.com,
	sivakumar.subramani@neterion.com, sreenivasa.honnur@neterion.com,
	anil.murthy@neterion.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([140.186.70.10]:59027 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754520AbZHND5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 23:57:33 -0400
Content-Disposition: inline
In-Reply-To: <20090813.201452.21119996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2009 at 08:14:52PM -0700, David Miller wrote:
> From: Davidlohr Bueso <dave@gnu.org>
> Date: Thu, 13 Aug 2009 22:03:28 -0400
> 
> > 
> > No need to cast kmalloc.
> > 
> > Signed-off-by: Davidlohr Bueso <dave@gnu.org>
> 
> Yeah but:
> 
> >  
> > -                                       ba->ba_0_org = (void *) kmalloc
> > -                                           (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
> > +                                       ba->ba_0_org = kmalloc(BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
> 
> Now the code line extends way over 80 columns.
Ok, resubmitting and verified by checkpatch.pl

Thanks.

Signed-off-by: Davidlohr Bueso <dave@gnu.org>

---
 drivers/net/s2io.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 458daa0..2bc62d3 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -870,8 +870,10 @@ static int init_shared_mem(struct s2io_nic *nic)
                                while (k != rxd_count[nic->rxd_mode]) {
                                        ba = &mac_control->rings[i].ba[j][k];
 
-                                       ba->ba_0_org = (void *) kmalloc
-                                           (BUF0_LEN + ALIGN_SIZE, GFP_KERNEL);
+                                       ba->ba_0_org = kmalloc
+                                               (BUF0_LEN + ALIGN_SIZE,
+                                                GFP_KERNEL);
+
                                        if (!ba->ba_0_org)
                                                return -ENOMEM;
                                        mem_allocated +=
@@ -881,8 +883,10 @@ static int init_shared_mem(struct s2io_nic *nic)
                                        tmp &= ~((unsigned long) ALIGN_SIZE);
                                        ba->ba_0 = (void *) tmp;
 
-                                       ba->ba_1_org = (void *) kmalloc
-                                           (BUF1_LEN + ALIGN_SIZE, GFP_KERNEL);
+                                       ba->ba_1_org = kmalloc
+                                               (BUF1_LEN + ALIGN_SIZE,
+                                                GFP_KERNEL);
+
                                        if (!ba->ba_1_org)
                                                return -ENOMEM;
                                        mem_allocated
