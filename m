From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 13/25] hamradio: 6pack: fix error return code
Date: Sun, 29 Dec 2013 23:47:28 +0100
Message-ID: <1388357260-4843-14-git-send-email-Julia.Lawall@lip6.fr>
References: <1388357260-4843-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: ajk@comnets.uni-bremen.de, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388357260-4843-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Set the return variable to an error code as done elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}

// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
Not tested.

 drivers/net/hamradio/6pack.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hamradio/6pack.c b/drivers/net/hamradio/6pack.c
index 1450e33..66e2b19 100644
--- a/drivers/net/hamradio/6pack.c
+++ b/drivers/net/hamradio/6pack.c
@@ -662,7 +662,8 @@ static int sixpack_open(struct tty_struct *tty)
 	tty->receive_room = 65536;
 
 	/* Now we're ready to register. */
-	if (register_netdev(dev))
+	err = register_netdev(dev);
+	if (err)
 		goto out_free;
 
 	tnc_init(sp);
