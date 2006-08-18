From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 4/6]: powerpc/cell spidernet ethtool -i version number info.
Date: Sat, 19 Aug 2006 00:56:34 +0200
Message-ID: <200608190056.35775.arnd@arndb.de>
References: <20060818220700.GG26889@austin.ibm.com> <20060818222500.GK26889@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linas Vepstas <linas@austin.ibm.com>,
	Jeff Garzik <jgarzik@pobox.com>, akpm@osdl.org,
	netdev@vger.kernel.org, James K Lewis <jklewis@us.ibm.com>,
	linux-kernel@vger.kernel.org,
	ens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:5878 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1751559AbWHRW4y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2006 18:56:54 -0400
To: linuxppc-dev@ozlabs.org
In-Reply-To: <20060818222500.GK26889@austin.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 19 August 2006 00:25, Linas Vepstas wrote:
> This patch adds version information as reported by=20
> ethtool -i to the Spidernet driver.

Acked-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>

except for

> @@ -2293,6 +2294,8 @@ static struct pci_driver spider_net_driv
> =A0 */
> =A0static int __init spider_net_init(void)
> =A0{
> +=A0=A0=A0=A0=A0=A0=A0printk("spidernet Version %s.\n",VERSION);
> +

This printk is missing a level (KERN_INFO or similar). Moreover,
it is rather strange for a driver to print a message when no
device is actually used by it. I'd rather drop the version
printk completely, but I know that Jim has strong feelings about
what to do with version information. I suggest that if we decide
to keep something like that in the driver, it should be printed
in spider_net_probe().

	Arnd <><
