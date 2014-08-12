From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] libcxgbi/cxgb4i : Fix ipv6 build failure
 caught with randconfig
Date: Tue, 12 Aug 2014 15:46:52 -0700 (PDT)
Message-ID: <20140812.154652.1490202340036045493.davem@davemloft.net>
References: <1407880481-22352-1-git-send-email-anish@chelsio.com>
	<20140812.152215.2300902059999669762.davem@davemloft.net>
	<525DB349B3FB5444AE057A887CB2A8D859F81B@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hch@infradead.org, kxie@chelsio.com,
	manojmalviya@chelsio.com, jim.epost@gmail.com, sfr@canb.auug.org.au
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39697 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbaHLWqy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 18:46:54 -0400
In-Reply-To: <525DB349B3FB5444AE057A887CB2A8D859F81B@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue, 12 Aug 2014 22:40:35 +0000

> So the recommended fix would be that the inbuilt option for cxgbi
> should be disabled if ipv6 is compiled as a module ?

If IPV6 is enabled, you should only allow cxgbi to be enabled in
a mode which is "compatible" with that setting.

This means if IPV6 is enabled statically, cxgbi should be offered
both statically and modular.  Whereas if IPV6 is modular, cxgbi
should only be offered to be enabled modular.

This occurs often enough that there is a common pattern for this
kind of dependency:

	depends on IPV6 || IPV6=n

Alternatively, depending upon what IPV6 interfaces you need to use
in the cxgbi driver, you can potentially move them into the ipv6
components we've split out to always be statically built into the
kernel in order to avoid problems of this nature.  See the code
linked in by the "obj-y +=" rule in net/ipv6/Makefile.

> This patch was based on code currently in net-next, and I presumed that would
> be the correct way to go. I'll change it and rebase to net.

The net-next tree isn't even open and active at this time, I said last week
(as I do every single merge window) that I would explicitly announce on
netdev when the net-next tree is openned.

But, much more importantly, bug fixes for issues present in 'net'
should always be targetted to the 'net' tree.
