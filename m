From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: reduce queue lengths if MTU is very large
Date: Tue, 20 Dec 2011 13:41:20 -0500 (EST)
Message-ID: <20111220.134120.1764634344589128309.davem@davemloft.net>
References: <20111219.163337.1185514300243434827.davem@davemloft.net>
	<1324273530-18499-1-git-send-email-peppe.cavallaro@st.com>
	<20111220073050.GA2817@mail.gnudd.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	giancarlo.asnaghi@st.com
To: rubini@gnudd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41950 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab1LTSl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2011 13:41:29 -0500
In-Reply-To: <20111220073050.GA2817@mail.gnudd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alessandro Rubini <rubini@gnudd.com>
Date: Tue, 20 Dec 2011 08:30:50 +0100

> Allocation of the queues is based on a parameter. If the parameter was
> a size, instead of a lenght, all would be fine, wouldn't it? If you
> agree, then this patch is turning the lenght into a size, in a way.

That doesn't make any sense either, queues are sized by TX descriptor
slots not bytes.

> Now, how could we deal with the fact that the size explodes if the MTU
> is increased?

Maybe... set the initial parameter appropriately?  This is enormously
better than fixing it up after the fact.

Maybe I set the number of TX entries based upon my expected packet
load of small packets.  If I happen to set my MTU to 9000 that's
irrelevant to the setting.
