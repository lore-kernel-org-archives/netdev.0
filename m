From: Eric Dumazet <dada1@cosmosbay.com>
Subject: about : [NET]: Replace CONFIG_NET_DEBUG with sysctl.
Date: Fri, 09 Mar 2007 07:34:15 +0100
Message-ID: <45F0FFE7.1080304@cosmosbay.com>
References: <20070308205214.580772044@linux-foundation.org>	<20070308205305.582324346@linux-foundation.org> <20070308.204209.69409441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010804050309080604050408"
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:45276 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993001AbXCIGeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 01:34:31 -0500
In-Reply-To: <20070308.204209.69409441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010804050309080604050408
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello David and Stephen

I see git commit 8e2101a9faab43dcf307d46784a1ede7997fe729
and its potential problems :

Here on my x86_64 machine :

ffffffff806e7520 d rtnl_mutex
ffffffff806e7538 D net_msg_cost
ffffffff806e753c D net_msg_burst
ffffffff806e7540 D net_msg_warn
ffffffff806e7560 d lweventlist_lock

So net_msg_{cost|burst|warn} are on two 'heavy' cachelines.

I gently ask that any new sysctl is '__read_mostly' tagged.

After this patch applied, this looks much better :

ffffffff80725d20 d ifla_policy
ffffffff80725d68 D net_msg_cost
ffffffff80725d6c D net_msg_burst
ffffffff80725d70 D net_msg_warn
ffffffff80725d78 d flow_cachep
ffffffff80725d80 d nla_attr_minlen
ffffffff80725da0 d ctrl_policy

Thank you
Eric

[PATCH] NET : New sysctls should use __read_mostly tags

net_msg_warn should be placed in the read_mostly section, to avoid performance 
problems on SMP

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------010804050309080604050408
Content-Type: text/plain;
 name="net_msg_warn_readmostly.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net_msg_warn_readmostly.patch"

diff --git a/net/core/utils.c b/net/core/utils.c
index 34f0810..adecfd2 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -30,9 +30,9 @@ #include <asm/byteorder.h>
 #include <asm/system.h>
 #include <asm/uaccess.h>
 
-int net_msg_cost = 5*HZ;
-int net_msg_burst = 10;
-int net_msg_warn = 1;
+int net_msg_cost __read_mostly = 5*HZ;
+int net_msg_burst __read_mostly = 10;
+int net_msg_warn __read_mostly = 1;
 EXPORT_SYMBOL(net_msg_warn);
 
 /*

--------------010804050309080604050408--
