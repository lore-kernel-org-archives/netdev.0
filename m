From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] ehea: do not dereference possible NULL port
Date: Tue, 17 Apr 2012 22:29:12 -0400 (EDT)
Message-ID: <20120417.222912.1038252957653077871.davem@davemloft.net>
References: <1334673715-16338-1-git-send-email-cascardo@linux.vnet.ibm.com>
	<1334673715-16338-4-git-send-email-cascardo@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: cascardo@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32770 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032Ab2DRC3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:29:19 -0400
In-Reply-To: <1334673715-16338-4-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Date: Tue, 17 Apr 2012 11:41:55 -0300

> port may be NULL when we receive an interrupt too early in the probe.
> 
> commit 8c4877a4128e7931077b024a891a4b284d8756a3, in particular, has
> introduced this problem in the case of port state change interrupt.
> 
> This causes crashes in some situations:

Never fix this kind of bug like this.  Do not make a tasklet or
an irq handler pay the price of the probe not doing things in the
right order.

Do not register asynchronous threads of control until all the
state is setup properly.

That's the right way to fix this problem.
