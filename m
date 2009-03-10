From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/13] forcedeth: add/modify tx done with limit
Date: Tue, 10 Mar 2009 05:32:12 -0700 (PDT)
Message-ID: <20090310.053212.39968484.davem@davemloft.net>
References: <49B013A2.8030806@nvidia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, jgarzik@pobox.com, akpm@osdl.org,
	netdev@vger.kernel.org
To: aabdulla@nvidia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42678
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753136AbZCJMc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 08:32:26 -0400
In-Reply-To: <49B013A2.8030806@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayaz Abdulla <aabdulla@nvidia.com>
Date: Thu, 05 Mar 2009 13:02:10 -0500

> There are two tx_done routines to handle tx completion processing. Both these functions now take in a limit value and return the amount of tx completions. This will be used by a future patch to determine the total amount of work done.
> 
> Signed-off-by: Ayaz Abdulla <aabdulla@nvidia.com>

Applied.

But I would absolutely not count TX completion processing in the
NAPI work limit as you do in one of the subsequent patches.

TX completely is just buffer freeing, very cheap.

Whereas RX processing involves actually network stack processing
which is real work and is what NAPI should be limiting.

Also, please get rid of the NAPI config option for this driver and
make NAPI unconditionally enabled.

Thanks.
