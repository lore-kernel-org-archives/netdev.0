From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: stmmac: fix NULL pointer dereference in
 stmmac_get_tx_hwtstamp
Date: Wed, 15 Jan 2014 16:58:45 -0800 (PST)
Message-ID: <20140115.165845.1813878173743840445.davem@davemloft.net>
References: <1389795967-2452-1-git-send-email-damuzi000@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: damuzi000@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389795967-2452-1-git-send-email-damuzi000@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bruce Liu <damuzi000@gmail.com>
Date: Wed, 15 Jan 2014 22:26:07 +0800

> When timestamping is enabled, stmmac_tx_clean will call
> stmmac_get_tx_hwtstamp to get tx TS.
> But the skb can be NULL because the last of its tx_skbuff is NULL
> if this packet frame is filled in more than one descriptors.
> 
> Signed-off-by: Bruce Liu <damuzi000@gmail.com>

Sometimes the cure is worse than the disease.

Your change means that every multi-segment packet will never have
it's timestamp properly recorded, which is of course bogus.

You need to change this code such that the SKB from the first
descriptor is maintained so that we can pass it into
stmmac_get_tx_hwtstamp() at the appropriate time.

Thanks.
