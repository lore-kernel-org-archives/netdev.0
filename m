From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1512/1524] net/ipv4/af_inet.c:1486:26: error:
 'offt' undeclared
Date: Sun, 30 Aug 2015 22:41:33 -0700 (PDT)
Message-ID: <20150830.224133.1682564292994363817.davem@davemloft.net>
References: <201508311307.3W9KBVXz%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghavendra.kt@linux.vnet.ibm.com, kbuild-all@01.org,
	netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbHaFlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 01:41:36 -0400
In-Reply-To: <201508311307.3W9KBVXz%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Mon, 31 Aug 2015 13:06:10 +0800

>    net/ipv4/af_inet.c: In function 'snmp_get_cpu_field64':
>>> net/ipv4/af_inet.c:1486:26: error: 'offt' undeclared (first use in this function)
>       v = *(((u64 *)bhptr) + offt);
>                              ^
>    net/ipv4/af_inet.c:1486:26: note: each undeclared identifier is reported only once for each function it appears in
>    net/ipv4/af_inet.c: In function 'snmp_fold_field64':
>>> net/ipv4/af_inet.c:1499:39: error: 'offct' undeclared (first use in this function)
>       res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>                                           ^
>>> net/ipv4/af_inet.c:1499:10: error: too many arguments to function 'snmp_get_cpu_field'
>       res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
>              ^
>    net/ipv4/af_inet.c:1455:5: note: declared here
>     u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offt)
>         ^
>    net/ipv4/af_inet.c:1499: confused by earlier errors, bailing out

Thanks, this should fix it:

====================
[PATCH] ipv4: Fix 32-bit build.

   net/ipv4/af_inet.c: In function 'snmp_get_cpu_field64':
>> net/ipv4/af_inet.c:1486:26: error: 'offt' undeclared (first use in this function)
      v = *(((u64 *)bhptr) + offt);
                             ^
   net/ipv4/af_inet.c:1486:26: note: each undeclared identifier is reported only once for each function it appears in
   net/ipv4/af_inet.c: In function 'snmp_fold_field64':
>> net/ipv4/af_inet.c:1499:39: error: 'offct' undeclared (first use in this function)
      res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
                                          ^
>> net/ipv4/af_inet.c:1499:10: error: too many arguments to function 'snmp_get_cpu_field'
      res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
             ^
   net/ipv4/af_inet.c:1455:5: note: declared here
    u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offt)
        ^

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/af_inet.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 0c69c0b..c2d0ebc 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1471,7 +1471,7 @@ EXPORT_SYMBOL_GPL(snmp_fold_field);
 
 #if BITS_PER_LONG==32
 
-u64 snmp_get_cpu_field64(void __percpu *mib, int cpu, int offct,
+u64 snmp_get_cpu_field64(void __percpu *mib, int cpu, int offt,
 			 size_t syncp_offset)
 {
 	void *bhptr;
@@ -1496,7 +1496,7 @@ u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
+		res += snmp_get_cpu_field(mib, cpu, offt, syncp_offset);
 	}
 	return res;
 }
-- 
2.1.0
