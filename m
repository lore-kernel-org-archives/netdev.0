From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [patch] fix up generic csum_ipv6_magic function prototype
Date: Mon, 13 Nov 2006 09:12:22 +0000
Message-ID: <20061113091222.GA26628@flint.arm.linux.org.uk>
References: <000301c703a3$0eedb340$ff0da8c0@amr.corp.intel.com> <20061108.230059.57444310.davem@davemloft.net> <20061109072216.GL29920@ftp.linux.org.uk> <20061108.235548.12921799.davem@davemloft.net> <20061113085223.GR29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kenneth.w.chen@intel.com,
	akpm@osdl.org, jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([217.147.92.249]:2322 "EHLO
	caramon.arm.linux.org.uk") by vger.kernel.org with ESMTP
	id S1753482AbWKMJMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 04:12:48 -0500
To: Al Viro <viro@ftp.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <20061113085223.GR29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 13, 2006 at 08:52:23AM +0000, Al Viro wrote:
> After doing the above we have the following:
> 
> Platform-dependent:
> __wsum csum_tcpudp_nofold(__be32, __be32, T1, T2, __wsum);
> On arm/arm26: T1 = unsigned short, T2 = unsigned int.
> __sum16 csum_tcpudp_magic(__be32, __be32, unsigned short, T, __wsum);
> On arm/arm26 T is unsigned int, elsewhere it's unsigned short.

Could both become unsigned short or unsigned int.  Would prefer
unsigned int on ARM, since otherwise the compiler generate code to
truncate any variable "int"s to an unsigned short.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:  2.6 Serial core
