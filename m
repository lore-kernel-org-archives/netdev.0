From: "Scott Thompson" <postfail@hushmail.com>
Subject: [PATCH 4/4]  /drivers/net ioremap balancing/returncode check (ucc_geth.c.c)
Date: Fri, 10 Aug 2007 14:41:52 -0400
Message-ID: <20070810184153.19F06DA81F@mailserver7.hushmail.com>
Reply-To: postfail@hushmail.com
Content-Type: text/plain; charset="UTF-8"
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<kernel-janitors@vger.kernel.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

patchset against 2.6.23-rc2 for /drivers/net ioremap balancing / 
return check:

  corrects:
  --sbus_ioremap return unchecked.
  --ioremap function unchecked
  --function failure cases did not clean up ioremap'd values.
  lne390.c
   -- believe had incorrect/not ideal variable check on if for 
iounmap

this audit was only for files directly in drivers/net directory, 
not the full tree.

I split patches up by file changed as each file had different 
'owner' to ease accept/reject/revision process.

Signed-off-by: Scott Thompson <postfail <at> hushmail.com>
----------------------------------------------------------
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 12e01b2..30acbe2 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -2430,6 +2430,11 @@ static int ucc_struct_init(struct 
ucc_geth_private *ugeth)
 
 	ugeth->ug_regs = (struct ucc_geth *) ioremap(uf_info->regs, 
sizeof(struct ucc_geth));
 
+	if (!ugeth->ug_regs){
+		ugeth_err("%s: Failed to ioremap.", __FUNCTION__);
+		return -ENOMEM;
+	}
+
 	return 0;
}

