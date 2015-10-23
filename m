From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] amd-xgbe: Use wmb before updating current
 descriptor count
Date: Fri, 23 Oct 2015 02:59:43 -0700 (PDT)
Message-ID: <20151023.025943.873672852211823864.davem@davemloft.net>
References: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christoffer.dall@linaro.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbbJWJnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:43:13 -0400
In-Reply-To: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 21 Oct 2015 15:37:05 -0500

> The code currently uses the lightweight dma_wmb barrier before updating
> the current descriptor count. Under heavy load, the Tx cleanup routine
> was seeing the updated current descriptor count before the updated
> descriptor information. As a result, the Tx descriptor was being cleaned
> up before it was used because it was not "owned" by the hardware yet,
> resulting in a Tx queue hang.
> 
> Using the wmb barrier insures that the descriptor is updated before the
> descriptor counter preventing the Tx queue hang. For extra insurance,
> the Tx cleanup routine is changed to grab the current decriptor count on
> entry and uses that initial value in the processing loop rather than
> trying to chase the current value.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> Tested-by: Christoffer Dall <christoffer.dall@linaro.org>

Applied, thanks.
