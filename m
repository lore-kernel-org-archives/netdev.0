From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] igb: Fix Null-pointer dereference in
 igb_reset_q_vector
Date: Tue, 18 Feb 2014 18:08:08 -0500 (EST)
Message-ID: <20140218.180808.558822435914770314.davem@davemloft.net>
References: <1392728817-21693-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	carolyn.wyborny@intel.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36989 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaBRXIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 18:08:10 -0500
In-Reply-To: <1392728817-21693-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 18 Feb 2014 14:06:57 +0100

> When igb_set_interrupt_capability() calls
> igb_reset_interrupt_capability() (e.g., because CONFIG_PCI_MSI is unset),
> num_q_vectors has been set but no vector has yet been allocated.
> 
> igb_reset_interrupt_capability() will then call igb_reset_q_vector,
> which assumes that the vector is allocated. As this is not the case, we
> are accessing a NULL-pointer.
> 
> This patch fixes it by checking that q_vector is indeed different from
> NULL.
> 
> Fixes: 02ef6e1d0b0023 (igb: Fix queue allocation method to accommodate changing during runtime)
> Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Intel folks, please queue this up, thanks.
