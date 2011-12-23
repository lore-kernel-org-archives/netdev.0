From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/9] net/rfkill/rfkill-gpio.c: introduce missing kfree
Date: Fri, 23 Dec 2011 18:39:27 +0100
Message-ID: <1324661974-17281-2-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Error handling code following a kmalloc should free the allocated data.
The label fail_alloc already does this for rfkill.

A simplified version of the semantic match that finds the problem is as
follows: (http://coccinelle.lip6.fr)

// <smpl>
@r exists@
local idexpression x;
statement S;
identifier f1;
position p1,p2;
expression *ptr != NULL;
@@

x@p1 = \(kmalloc\|kzalloc\|kcalloc\)(...);
...
if (x == NULL) S
<... when != x
     when != if (...) { <+...x...+> }
x->f1
...>
(
 return \(0\|<+...x...+>\|ptr\);
|
 return@p2 ...;
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

print "* file: %s kmalloc %s return %s" % (p1[0].file,p1[0].line,p2[0].line)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 net/rfkill/rfkill-gpio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index ca355e7..865adb6 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -105,7 +105,7 @@ static int rfkill_gpio_probe(struct platform_device *pdev)
 		ret = pdata->gpio_runtime_setup(pdev);
 		if (ret) {
 			pr_warn("%s: can't set up gpio\n", __func__);
-			return ret;
+			goto fail_alloc;
 		}
 	}
 
