From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] xfrm: Fix kernel panic when flush and dump SPD
 entries
Date: Mon, 01 Dec 2008 00:38:21 -0800 (PST)
Message-ID: <20081201.003821.42061993.davem@davemloft.net>
References: <493383E9.50509@cn.fujitsu.com>
	<4933975E.3030503@cn.fujitsu.com>
	<20081201081111.GA19615@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59672
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750740AbYLAIiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 03:38:21 -0500
In-Reply-To: <20081201081111.GA19615@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 1 Dec 2008 16:11:11 +0800

> On Mon, Dec 01, 2008 at 03:50:54PM +0800, Wei Yongjun wrote:
> > After flush the SPD entries, dump the SPD entries will cause kernel painc.
> > 
> > Used the following commands to reproduct:
> > 
> > - echo 'spdflush;' | setkey -c
> > - echo 'spdadd 3ffe:501:ffff:ff01::/64 3ffe:501:ffff:ff04::/64  any -P out ipsec \
> >   ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
> >   spddump;' | setkey -c
> > - echo 'spdflush; spddump;' | setkey -c
> > - echo 'spdadd 3ffe:501:ffff:ff01::/64 3ffe:501:ffff:ff04::/64  any -P out ipsec \
> >   ah/tunnel/3ffe:501:ffff:ff00:200:ff:fe00:b0b0-3ffe:501:ffff:ff02:200:ff:fe00:a1a1/require;\
> >   spddump;' | setkey -c
> > 
> > This is because when flush the SPD entries, the SPD entry is not remove
> > from the list.
> > 
> > This patch fix the problem by remove the SPD entry from the list. And
> > also do clean up of remove SPD entry.
> 
> I like the clean-up but it's best if you separate the two changes
> into two patches.  That way it's easy to see exactly what the bug
> fix patch is trying to fix and to verify that the clean-up patch
> really doesn't change behaviour.

Agreed.  Wei, please do this.
