From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/5] forcedeth: process TX completions using NAPI
Date: Sun, 07 Oct 2007 10:39:34 -0400
Message-ID: <4708EFA6.20902@garzik.org>
References: <20071006151250.GA17020@havoc.gtf.org> <20071006151438.GC17488@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010706080902040703000001"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752820AbXJGOj6@vger.kernel.org>
In-Reply-To: <20071006151438.GC17488@havoc.gtf.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010706080902040703000001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jeff Garzik wrote:
> commit 57cbfacc00d69be2ba02b65d1021442273b76263
> Author: Jeff Garzik <jeff@garzik.org>
> Date:   Fri Oct 5 23:25:56 2007 -0400
> 
>     [netdrvr] forcedeth: process TX completions using NAPI
>     
>     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
> 
>  drivers/net/forcedeth.c |  143 +++++++++++++++++++++++++++---------------------
>  1 file changed, 83 insertions(+), 60 deletions(-)

The attached patch fixes an obvious bug.  Once applied, TX NAPI actually 
works :)



--------------010706080902040703000001
Content-Type: text/plain;
 name="patch.fe3"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch.fe3"

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 1c236e6..e25c05e 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -3059,7 +3059,7 @@ static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 
 static int nv_napi_tx_poll(struct napi_struct *napi, int budget)
 {
-	struct fe_priv *np = container_of(napi, struct fe_priv, napi);
+	struct fe_priv *np = container_of(napi, struct fe_priv, tx_napi);
 	struct net_device *dev = np->dev;
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;

--------------010706080902040703000001--
