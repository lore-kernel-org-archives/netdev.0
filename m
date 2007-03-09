From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check
 kmalloc() return value.
Date: Thu, 08 Mar 2007 23:29:08 -0800 (PST)
Message-ID: <20070308.232908.92582631.davem@davemloft.net>
References: <20070308232215.aa512aaa.amit2030@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
To: amit2030@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46271
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993058AbXCIH3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 02:29:08 -0500
In-Reply-To: <20070308232215.aa512aaa.amit2030@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amit Choudhary <amit2030@gmail.com>
Date: Thu, 8 Mar 2007 23:22:15 -0800

> Description: Check the return value of kmalloc() in function wrandom_set_nhinfo(), in file net/ipv4/multipath_wrandom.c.
> 
> Signed-off-by: Amit Choudhary <amit2030@gmail.com>

This kind of patch has been submitted several times before and it's
never accepted because you have to do much more than this to recover
from the allocation error.

There is no error status returned to the caller, so the callers assume
the operation succeeded, and will either OOPS or crash in some other
way.

Therefore, just adding some NULL pointer checks and returning is not
going to fix this bug.

The whole cahce-multipath subsystem has to have it's guts revamped for
proper error handling.
