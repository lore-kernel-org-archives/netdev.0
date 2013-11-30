From: =?UTF-8?B?T25kxZllaiBQdcW+bWFu?= <puzman@gmail.com>
Subject: Re: [PATCH 1/4] pch_gbe: Fix transmit queue management
Date: Sat, 30 Nov 2013 23:41:06 +0100
Message-ID: <529A6982.1090206@gmail.com>
References: <20131127.203929.1379316258754767343.davem@davemloft.net>	<1385631882-12827-2-git-send-email-puzman@gmail.com> <20131129.164229.2292905485668904870.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131129.164229.2292905485668904870.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Please format your commit  message text to 80 columns.

Ok, no problem. I did not know that 80 columns limitation applies also
for commit messages.

> You should be instead  preventing the transmit method from being
> invoked when it might be possible that a request cannot be
> satisfied. This means that at the end of a transmit request, you must
> stop the queue if a packet with the maximum number of possible
> descriptors cannot be satisfied. Then it is impossible for the
> transmit function to be invoked in a situation where it would need to
> fail for lack of available transmit descriptors. This is why drivers
> decided whether to stop their TX queues based upon calculations
> involving MAX_SKB_FRAGS.

Hmm, correct me if I'm wrong ... but the driver and hardware does not
support scatter-gather DMA. So fragmented skbs can't be passed to
ndo_start_xmit function and each skb passed to the function represents
one packet and one descriptor in tx_ring.
I do not think that in this caseit makes sense to to involve
MAX_SKB_FRAGS in any calculation and the queue should be stopped in the
moment when it gets full.
But maybe I am missing something, I am no expert in this kind of stuff.

--
Ondrej Puzman
