From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for July 6 (NET_DSA + PHYLIB kconfig)
Date: Tue, 6 Jul 2010 10:34:17 -0700
Message-ID: <20100706103417.8923b697.randy.dunlap@oracle.com>
References: <20100706190519.93d8b785.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100706190519.93d8b785.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 6 Jul 2010 19:05:19 +1000 Stephen Rothwell wrote:

> Hi all,
> 
> Changes since 20100705:
> 
> My fixes tree contains:
> 	kbuild: Fix path to scripts/setlocalversion
> 
> ----------------------------------------------------------------------------

kconfig now detects symbol dependency errors and warns about them.
E.g.:

warning: (NET_DSA && NET && EXPERIMENTAL && !S390 || MACB && NETDEVICES && NET_ETHERNET && (AVR32 || ARCH_AT91SAM9260 || ARCH_AT91SAM9263 || ARCH_AT91SAM9G20 || ARCH_AT91SAM9G45 || ARCH_AT91CAP9) || IXP4XX_ETH && NETDEVICES && NET_ETHERNET && ARM && ARCH_IXP4XX && IXP4XX_NPE && IXP4XX_QMGR || W90P910_ETH && NETDEVICES && NET_ETHERNET && ARM && ARCH_W90X900 || MIPS_AU1X00_ENET && NETDEVICES && NET_ETHERNET && SOC_AU1X00 || SH_ETH && NETDEVICES && NET_ETHERNET && SUPERH && (CPU_SUBTYPE_SH7710 {{20 lines deleted}}
selects PHYLIB which has unmet direct dependencies (!S390 && NET_ETHERNET)

says that NET_DSA & PHYLIB have some kind of problem.
NET_DSA selects PHYLIB.  PHYLIB depends on NET_ETHERNET, which is not enabled
in this randconfig.  net/dsa code does need PHYLIB code, so PHYLIB symbol should
either drop "depends on NET_ETHERNET" or it should be changed to
	depends on NET_ETHERNET || NET_DSA

Preference?

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
