From: Scott Thompson <postfailathushmaildotcom@yahoo.com>
Subject: [PATCH 3/3] /drivers/net ucc_geth ioremap balancing/returncode check (resend)
Date: Mon, 13 Aug 2007 21:47:16 -0700 (PDT)
Message-ID: <246708.59171.qm@web44916.mail.sp1.yahoo.com>
Reply-To: postfail@hushmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, postfail@hushmail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S939848AbXHNErc@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

resending patchset against 2.6.23-rc3 for /drivers/net ioremap balancing / return check,
previous patchset contained wordwrap errors:

  corrects:
  --sbus_ioremap return unchecked.
  --ioremap function unchecked
  --function failure cases did not clean up ioremap'd values.
  lne390.c  -- believe had incorrect/not ideal variable check on if for iounmap

this audit was only for files directly in drivers/net directory, not the full tree.

Signed-off-by: Scott Thompson <postfail <at> hushmail.com>
----------------------------------------------------------
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e01b2..30acbe2 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2430,6 +2430,11 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 
 	ugeth->ug_regs = (struct ucc_geth *) ioremap(uf_info->regs, sizeof(struct ucc_geth));
 
+	if (!ugeth->ug_regs){
+		ugeth_err("%s: Failed to ioremap.", __FUNCTION__);
+		return -ENOMEM;
+	}
+
 	return 0;
 }
 



       
____________________________________________________________________________________
Choose the right car based on your needs.  Check out Yahoo! Autos new Car Finder tool.
http://autos.yahoo.com/carfinder/


       
____________________________________________________________________________________
Need a vacation? Get great deals
to amazing places on Yahoo! Travel.
http://travel.yahoo.com/
