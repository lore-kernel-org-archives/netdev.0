From: Olof Johansson <olof@lixom.net>
Subject: INET_LRO as tristate and use from modules (was: Re: [BUILD FAILURE
	08/12] Next April 21 : PPC64 randconfig
	[drivers/net/pasemi_mac_driver.ko])
Date: Tue, 21 Apr 2009 14:33:19 -0500
Message-ID: <20090421193319.GB20237@lixom.net>
References: <1240339984.9110.141.camel@subratamodak.linux.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Geoff Levand <geoffrey.levand@am.sony.com>,
	Linuxppc-dev <Linuxppc-dev@ozlabs.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	sachinp <sachinp@linux.vnet.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>, themann@de.ibm.com,
	davem@davemloft.net
To: Subrata Modak <subrata@linux.vnet.ibm.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1240339984.9110.141.camel@subratamodak.linux.ibm.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 22, 2009 at 12:23:03AM +0530, Subrata Modak wrote:
> Reported this on 9th April earlier:
> http://lkml.org/lkml/2009/4/9/276,
> 
> I hope the following Patch will solve this problem as well:
> Geoff Levand <geoffrey.levand@am.sony.com> provided a patch on 17th
> April.
> http://lkml.org/lkml/2009/4/17/313,

No, that's a separate issue.

>   MODPOST 338 modules
> ERROR: ".lro_receive_skb" [drivers/net/pasemi_mac_driver.ko] undefined!
> ERROR: ".lro_flush_all" [drivers/net/pasemi_mac_driver.ko] undefined!
> WARNING: modpost: Found 1 section mismatch(es).
> To see full details build your kernel with:
> 'make CONFIG_DEBUG_SECTION_MISMATCH=y'
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2

This seems to be a problem with all tristate-capable drivers that use
LRO (and uses select INET_LRO in their Kconfig): INET_LRO is a tristate
and can thus be a module. Looks like it needs to be a bool instead?


-Olof
