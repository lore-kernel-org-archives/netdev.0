From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 5/6] stmmac: remove useless check in the
 stmmac_tx_clean
Date: Wed, 26 Feb 2014 16:14:22 -0500 (EST)
Message-ID: <20140226.161422.431061479377150157.davem@davemloft.net>
References: <1393401667-6452-1-git-send-email-peppe.cavallaro@st.com>
	<1393401667-6452-6-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaBZVOY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 16:14:24 -0500
In-Reply-To: <1393401667-6452-6-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 26 Feb 2014 09:01:06 +0100

> There is an useless if condition that this patch is removing
> when the driver cleans the tx resources.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

It is not useless, the first check is optimistic and lock free.

You must retest the condition under the lock in order to avoid
spurious wakeups.

Such a spurious wakeup could overlap another asynchronous context
filling the TX queue and sleeping it, resulting in corruption.

Furthermore, that cleanup patch in this series is absolutely not
appropriate for 'net' which is for real bug fixes only.  Specifically
I'm talking about patch #4.
