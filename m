From: Andrew Morton <akpm@osdl.org>
Subject: Re: [OOPS] TLAN fails on ifconfig with CONFIG_HOTPLUG=n
Date: Tue, 11 Nov 2003 15:30:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031111153013.3b9eba6e.akpm@osdl.org>
References: <20031111222933.GA2868@rivenstone.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jhf@rivenstone.net (Joseph Fannin)
In-Reply-To: <20031111222933.GA2868@rivenstone.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jhf@rivenstone.net (Joseph Fannin) wrote:
>
>     I'm getting an Oops when ifup'ing a Compaq Netelligent card that
>  uses the tlan driver running 2.6.

Does this fix it?

diff -puN drivers/net/tlan.c~tlan-oops-fix drivers/net/tlan.c
--- 25/drivers/net/tlan.c~tlan-oops-fix	2003-11-11 15:29:32.000000000 -0800
+++ 25-akpm/drivers/net/tlan.c	2003-11-11 15:29:38.000000000 -0800
@@ -234,7 +234,7 @@ static struct board {
 	const char	*deviceLabel;
 	u32	   	flags;
 	u16	   	addrOfs;
-} board_info[] __devinitdata = {
+} board_info[] = {
 	{ "Compaq Netelligent 10 T PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Netelligent 10/100 TX PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Integrated NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },

_
