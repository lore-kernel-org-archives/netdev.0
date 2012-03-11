From: "Hans Schillstrom" <hans@schillstrom.com>
Subject: Re[2]:  linux-next: Tree for Mar 9 (netfilter)
Date: Sun, 11 Mar 2012 13:37:25 +0100 (CET)
Message-ID: <giupeu1.ee21a87813f836d9f587ea0b0e19a695@obelix.schillstrom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 8BIT
Cc: "Randy Dunlap" <rdunlap@xenotime.net>,
	"Stephen Rothwell" <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, "LKML" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "Pablo Neira Ayuso" <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello
>On Fri, Mar 09, 2012 at 12:30:42PM -0800, Randy Dunlap wrote:
>> On 03/09/2012 12:11 AM, Stephen Rothwell wrote:
>> 
>> > Hi all,
>> > 
>> > There will be no linux-next release on March 12 due to a public holiday.
>> > 
>> > Changes since 20120308:
>> 
>> 
>> xt_LOG.c:(.text+0x789b1): undefined reference to `ip6t_ext_hdr'
>> 
>> Full randconfig file is attached.
>
>The patch attached fixes this problem, thanks!


This one is needed as well,

To force xt_LOG  to be configured as a module if ipv6 is a module,
otherwise you end up in the same linking problem

Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
---
 net/netfilter/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 0c6f67e..4ef9c80 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -547,6 +547,7 @@ config NETFILTER_XT_TARGET_LED
 
 config NETFILTER_XT_TARGET_LOG
 	tristate "LOG target support"
+	depends on (IPV6 || IPV6=n)
 	default m if NETFILTER_ADVANCED=n
 	help
 	  This option adds a `LOG' target, which allows you to create rules in
-- 
1.7.3.4


