From: David Miller <davem@davemloft.net>
Subject: Re: RAW netfilter - "advanced netfilter setting" or not?
Date: Wed, 23 Nov 2011 16:07:19 -0500 (EST)
Message-ID: <20111123.160719.540568233963799514.davem@davemloft.net>
References: <CA+55aFzvZowH1_bA66VZ5Aw0wF3KzdGSqiNZLw46J3u4gpKnxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.weinberger@gmail.com, pablo@netfilter.org,
	netdev@vger.kernel.org, kaber@trash.net,
	netfilter-devel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFzvZowH1_bA66VZ5Aw0wF3KzdGSqiNZLw46J3u4gpKnxA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 23 Nov 2011 12:58:20 -0800

> On Nov 23, 2011 12:51 PM, "richard -rw- weinberger" <
> richard.weinberger@gmail.com> wrote:
>>
>> SuSEfirewall2 is using NOTRACK for the lo interface.
>>
>> iptables -t raw -A PREROUTING -j NOTRACK -i lo
>> iptables -t raw -A OUTPUT -j NOTRACK -o lo
> 
> Yeah, and that (NOTRACK) was another thing that was disabled due to
> depending on advanced config... Which is probably why my raw table was
> empty even after I enabled that one by hand.
> 
> So we'd need to unhide both raw and notrack, methinks.

I just tossed the following into my tree:

--------------------
[PATCH] netfilter: Remove NOTRACK/RAW dependency on NETFILTER_ADVANCED.

Distributions are using this in their default scripts, so don't hide
them behind the advanced setting.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter/Kconfig |    1 -
 net/ipv6/netfilter/Kconfig |    1 -
 net/netfilter/Kconfig      |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1dfc18a..f19f218 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -325,7 +325,6 @@ config IP_NF_TARGET_TTL
 # raw + specific targets
 config IP_NF_RAW
 	tristate  'raw table support (required for NOTRACK/TRACE)'
-	depends on NETFILTER_ADVANCED
 	help
 	  This option adds a `raw' table to iptables. This table is the very
 	  first in the netfilter framework and hooks in at the PREROUTING
diff --git a/net/ipv6/netfilter/Kconfig b/net/ipv6/netfilter/Kconfig
index 4484648..f792b34 100644
--- a/net/ipv6/netfilter/Kconfig
+++ b/net/ipv6/netfilter/Kconfig
@@ -186,7 +186,6 @@ config IP6_NF_MANGLE
 
 config IP6_NF_RAW
 	tristate  'raw table support (required for TRACE)'
-	depends on NETFILTER_ADVANCED
 	help
 	  This option adds a `raw' table to ip6tables. This table is the very
 	  first in the netfilter framework and hooks in at the PREROUTING
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8260b13..e8f3796 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -542,7 +542,6 @@ config NETFILTER_XT_TARGET_NOTRACK
 	tristate  '"NOTRACK" target support'
 	depends on IP_NF_RAW || IP6_NF_RAW
 	depends on NF_CONNTRACK
-	depends on NETFILTER_ADVANCED
 	help
 	  The NOTRACK target allows a select rule to specify
 	  which packets *not* to enter the conntrack/NAT
-- 
1.7.6.4

