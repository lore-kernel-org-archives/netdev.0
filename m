From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Thu, 18 Feb 2016 15:28:35 -0500 (EST)
Message-ID: <20160218.152835.353900764459662279.davem@davemloft.net>
References: <20160218122855.55e3f09d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, Yuval.Mintz@qlogic.com,
	Ariel.Elior@qlogic.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46801 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1948297AbcBRU2h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 15:28:37 -0500
In-Reply-To: <20160218122855.55e3f09d@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 18 Feb 2016 12:28:55 +1100

> After merging the net-next tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
> 
> In file included from drivers/net/ethernet/broadcom/bnx2x/bnx2x.h:56:0,
>                  from drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:30:
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c: In function 'bnx2x_dcbx_get_ap_feature':
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: error: 'DCBX_APP_SF_DEFAULT' undeclared (first use in this function)
>            DCBX_APP_SF_DEFAULT) &&  
>            ^
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h:120:45: note: in definition of macro 'GET_FLAGS'
>  #define GET_FLAGS(flags, bits)  ((flags) & (bits))
>                                              ^
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c:224:11: note: each undeclared identifier is reported only once for each function it appears in
>            DCBX_APP_SF_DEFAULT) &&  
>            ^
> drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h:120:45: note: in definition of macro 'GET_FLAGS'
>  #define GET_FLAGS(flags, bits)  ((flags) & (bits))
>                                              ^
> 
> Caused by commit
> 
>   e5d3a51cefbb ("This adds support for default application priority.")
> 
> This build is big endian.

Yuval and Ariel, you _MUST_ fix this.

This build failure has been in the tree for 24 hours and I haven't heard anything
from you two yet.

If this persists for another day I'm reverting all of your changes.
