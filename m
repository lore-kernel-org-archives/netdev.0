From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] taskstats: fix nl parsing in accounting/getdelays.c
Date: Wed, 27 Apr 2016 17:47:57 +0200
Message-ID: <1461772077-3216-1-git-send-email-nicolas.dichtel@6wind.com>
References: <5720DED8.4090706@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, linux-wpan@vger.kernel.org,
	aar@pengutronix.de, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, pshelar@nicira.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org,
	netfilter-devel@vger.kernel.org, dev@openvswitch.org,
	steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: bsingharora@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5720DED8.4090706@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The type TASKSTATS_TYPE_NULL should always be ignored.

When jumping to the next attribute, only the length of the current
attribute should be added, not the length of all nested attributes.
This last bug was not visible before commit 80df554275c2, because the
kernel didn't put more than two nested attributes.

Fixes: a3baf649ca9c ("[PATCH] per-task-delay-accounting: documentation")
Fixes: 80df554275c2 ("taskstats: use the libnl API to align nlattr on 64-bit")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 Documentation/accounting/getdelays.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/accounting/getdelays.c b/Documentation/accounting/getdelays.c
index 7785fb5eb93f..d3caa6748a46 100644
--- a/Documentation/accounting/getdelays.c
+++ b/Documentation/accounting/getdelays.c
@@ -512,7 +512,7 @@ int main(int argc, char *argv[])
 						break;
 					}
 					len2 += NLA_ALIGN(na->nla_len);
-					na = (struct nlattr *) ((char *) na + len2);
+					na = (struct nlattr *) ((char *) na + NLA_ALIGN(na->nla_len));
 				}
 				break;
 
-- 
2.8.1
