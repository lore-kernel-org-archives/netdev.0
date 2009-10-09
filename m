From: Dmitry Artamonow <mad_soft@inbox.ru>
Subject: Re: [PATCH] irda/sa1100_ir: check return value of startup hook
Date: Sat, 10 Oct 2009 00:12:24 +0400
Message-ID: <20091009201224.GA6208@rainbow>
References: <1255073153-24962-1-git-send-email-mad_soft@inbox.ru>
	<4ACF293C.7070803@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Cc: netdev@vger.kernel.org, Samuel Ortiz <samuel@sortiz.org>,
	Russell King <linux@arm.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <4ACF293C.7070803@ru.mvista.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 16:14 Fri 09 Oct     , Sergei Shtylyov wrote:

[...]
> > -	if (si->pdata->startup)
> > -		si->pdata->startup(si->dev);
> > +	if (si->pdata->startup)	{
> > +		ret = si->pdata->startup(si->dev);
> > +		if (ret)
> > +			return ret;
> > +		}
> 
>     Overindented brace.
> 

Nice catch, thanks!

Updated patch in attachment.

-- 
Best regards,
Dmitry "MAD" Artamonow


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-irda-sa1100_ir-check-return-value-of-startup-hook.patch"

>From ba1fe701950634aae46aa59431633e99f8bd18cc Mon Sep 17 00:00:00 2001
From: Dmitry Artamonow <mad_soft@inbox.ru>
Date: Fri, 9 Oct 2009 21:56:21 +0400
Subject: [PATCH v2] irda/sa1100_ir: check return value of startup hook

Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
---
 drivers/net/irda/sa1100_ir.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/sa1100_ir.c b/drivers/net/irda/sa1100_ir.c
index 38bf7cf..c412e80 100644
--- a/drivers/net/irda/sa1100_ir.c
+++ b/drivers/net/irda/sa1100_ir.c
@@ -232,8 +232,11 @@ static int sa1100_irda_startup(struct sa1100_irda *si)
 	/*
 	 * Ensure that the ports for this device are setup correctly.
 	 */
-	if (si->pdata->startup)
-		si->pdata->startup(si->dev);
+	if (si->pdata->startup)	{
+		ret = si->pdata->startup(si->dev);
+		if (ret)
+			return ret;
+	}
 
 	/*
 	 * Configure PPC for IRDA - we want to drive TXD2 low.
-- 
1.6.3.4


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--opJtzjQTFsWo+cga--
