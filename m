From: Paul Jackson <pj@sgi.com>
Subject: Re: 2.6.7-rc2-mm1 - bk-netdev.patch e1000_ethtool.c doesn't build
Date: Wed, 2 Jun 2004 02:21:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040602022130.35a7571d.pj@sgi.com>
References: <20040601021539.413a7ad7.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040601021539.413a7ad7.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The patch bk-netdev.patch in 2.6.7-rc2-mm1 doesn't compile.


It contains the following change, which creates two identical e1000_gstrings_stats[]
opening declaration lines in a row, and many many gcc errors, starting with:

> drivers/net/e1000/e1000_ethtool.c:57: error: parse error before "static"


diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c 2004-05-31 16:18:26 -07:00
+++ b/drivers/net/e1000/e1000_ethtool.c 2004-05-31 16:18:26 -07:00
@@ -54,6 +54,7 @@
 #define E1000_STAT(m) sizeof(((struct e1000_adapter *)0)->m), \
                      offsetof(struct e1000_adapter, m)
 static const struct e1000_stats e1000_gstrings_stats[] = {
+static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(net_stats.rx_packets) },
 	{ "tx_packets", E1000_STAT(net_stats.tx_packets) },
 	{ "rx_bytes", E1000_STAT(net_stats.rx_bytes) },


There may or may not be other errors past this - I have not gone there yet.

-- 
                          I won't rest till it's the best ...
                          Programmer, Linux Scalability
                          Paul Jackson <pj@sgi.com> 1.650.933.1373
