From: Anish Bhatt <anish@chelsio.com>
Subject: RE: [PATCH net-next] libcxgbi/cxgb4i : Fix ipv6 build failure
 caught with randconfig
Date: Tue, 12 Aug 2014 22:40:35 +0000
Message-ID: <525DB349B3FB5444AE057A887CB2A8D859F81B@nice.asicdesigners.com>
References: <1407880481-22352-1-git-send-email-anish@chelsio.com>,<20140812.152215.2300902059999669762.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"hch@infradead.org" <hch@infradead.org>,
	Karen Xie <kxie@chelsio.com>,
	Manoj Malviya <manojmalviya@chelsio.com>,
	"jim.epost@gmail.com" <jim.epost@gmail.com>,
	"sfr@canb.auug.org.au" <sfr@canb.auug.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-228.uvs.sntcca.sbcglobal.net ([99.65.72.228]:14590
	"EHLO stargate.chelsio.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750699AbaHLWla convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Aug 2014 18:41:30 -0400
In-Reply-To: <20140812.152215.2300902059999669762.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So the recommended fix would be that the inbuilt option for cxgbi should be
disabled if ipv6 is compiled as a module ?

This patch was based on code currently in net-next, and I presumed that would
be the correct way to go. I'll change it and rebase to net.
-Anish
________________________________________
From: David Miller [davem@davemloft.net]
Sent: Tuesday, August 12, 2014 3:22 PM
To: Anish Bhatt
Cc: netdev@vger.kernel.org; hch@infradead.org; Karen Xie; Manoj Malviya; jim.epost@gmail.com; sfr@canb.auug.org.au
Subject: Re: [PATCH net-next] libcxgbi/cxgb4i : Fix ipv6 build failure caught with randconfig

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 12 Aug 2014 14:54:41 -0700

> Previous guard of IS_ENABLED(CONFIG_IPV6) is not sufficient when cxgbi drivers
> are built into kernel but ipv6 is not. Change guard to only enable when either
> ipv6 is built-in or both are modules.
>
> Fixes: e81fbf6cd652 ("libcxgbi:cxgb4i Guard ipv6 code with a config check")
> Fixes: fc8d0590d914 ("libcxgbi: Add ipv6 api to driver")
> Signed-off-by: Anish Bhatt <anish@chelsio.com>

That's not how you fix problems like this.

Instead, you should use Kconfig conditions to make sure your driver is
enabled in a manner which is compatible with what IPV6 has been set to.

No user should have to know about these strange dependencies just to get
IPV6 enabled in your driver.

Really, your change makes IPV6 get disabled if IPV6 is modular and your
driver is built statically.  I do not think any user would consider that
reasonable behavior.
