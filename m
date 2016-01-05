From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/3] nfp: free buffers before changing MTU
Date: Mon, 04 Jan 2016 22:46:04 -0500 (EST)
Message-ID: <20160104.224604.57284296950465229.davem@davemloft.net>
References: <1451923395-24533-1-git-send-email-jakub.kicinski@netronome.com>
	<1451923395-24533-2-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, simon.horman@netronome.com,
	rolf.neugebauer@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51303 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbcAEDqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:46:06 -0500
In-Reply-To: <1451923395-24533-2-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon,  4 Jan 2016 16:03:13 +0000

> For freeing DMA buffers we depend on nfp_net.fl_bufsz having the same
> value as during allocation therefore in .ndo_change_mtu we must first
> free the buffers and then change the setting.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Rolf Neugebauer <rolf.neugebauer@netronome.com>

The behavior implemented by this patch is not acceptable.

If an error occurs reopenning the device after the MTU
change, the user is left with an inoperable interface and
zero feedback about what happened or why.

You MUST, therefore, specifically try to allocate the new memory and
resources that correspond to the new MTU value.

And if you can successfully allocate everything and be guarateed to
succeed, only then can you change the MTU and commit to the new
resources.

Otherwise you must leave the interface in exactly the state it was
in prior to the MTU change call and return an error to the caller.
