From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [KJ] [PATCH] net/pcnet32: replace schedule_timeout() with
	ssleep_interruptible()
Date: Mon, 1 Nov 2004 14:10:41 -0800
Message-ID: <20041101221041.GB4255@us.ibm.com>
References: <E1CO1vx-0002OW-FJ@sputnik> <4184C701.5030103@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============25760278290309824=="
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4184C701.5030103@pobox.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============25760278290309824==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Oct 31, 2004 at 06:05:37AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >diff -puN drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32 
> >drivers/net/pcnet32.c
> >--- 
> >linux-2.6.10-rc1/drivers/net/pcnet32.c~msleep_interruptible-drivers_net_pcnet32	2004-10-24 17:05:14.000000000 +0200
> >+++ linux-2.6.10-rc1-max/drivers/net/pcnet32.c	2004-10-24 
> >17:05:14.000000000 +0200
> >@@ -847,7 +847,7 @@ static int pcnet32_phys_id(struct net_de
> >     if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
> >     data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
> > 
> >-    schedule_timeout(data * HZ);
> >+    msleep_interruptible(data * 1000);
> 
> 
> clearly and obviously ssleep()

Here is the corrected patch.

Description: Use ssleep_interruptible() instead of schedule_timeout()
to guarantee the task delays as expected.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-rc1-vanilla/drivers/net/pcnet32.c	2004-10-30 15:33:28.000000000 -0700
+++ 2.6.10-rc1/drivers/net/pcnet32.c	2004-11-01 14:08:10.000000000 -0800
@@ -847,7 +847,7 @@ static int pcnet32_phys_id(struct net_de
     if ((!data) || (data > (u32)(MAX_SCHEDULE_TIMEOUT / HZ)))
     data = (u32)(MAX_SCHEDULE_TIMEOUT / HZ);
 
-    schedule_timeout(data * HZ);
+    ssleep_interruptible(data);
     del_timer_sync(&lp->blink_timer);
 
     /* Restore the original value of the bcrs */


--===============25760278290309824==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============25760278290309824==--
