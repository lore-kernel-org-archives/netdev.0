From: David Miller <davem@davemloft.net>
Subject: Re: v4 [PATCH 1/9] af_packet: Check return of
 dev_set_promiscuity/allmulti
Date: Mon, 14 Jul 2008 20:51:10 -0700 (PDT)
Message-ID: <20080714.205110.266962405.davem@davemloft.net>
References: <487C0ABA.1070506@cn.fujitsu.com>
	<487C127D.9010908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46506
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751889AbYGODvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 23:51:10 -0400
In-Reply-To: <487C127D.9010908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Tue, 15 Jul 2008 10:59:09 +0800

> dev_set_promiscuity/allmulti might overflow.
> Commit: "netdevice: Fix promiscuity and allmulti overflow" in net-next makes
> dev_set_promiscuity/allmulti return error number if overflow happened.
> 
> In af_packet, we check all positive increment for promiscuity and allmulti
> to get error return.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> Acked-by: Patrick McHardy <kaber@trash.net> 

Applied, thanks.

What are the exact locking rules for po->mclist btw?  Obviously
changes to the list are RTNL protected, but what about readers?

If readers lock differently, this error recovery where we unlink 'i'
could cause an OOPS.  It is ok to add new elements while allowing
readers to traverse independantly but removal needs to interlock with
such readers.
