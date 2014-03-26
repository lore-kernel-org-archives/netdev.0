From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] xen-netback: Stop using
 xenvif_tx_pending_slots_available
Date: Wed, 26 Mar 2014 16:33:54 -0400 (EDT)
Message-ID: <20140326.163354.278397819499294364.davem@davemloft.net>
References: <1395705591-23976-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.campbell@citrix.com, wei.liu2@citrix.com,
	xen-devel@lists.xenproject.org, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jonathan.davies@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395705591-23976-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 24 Mar 2014 23:59:49 +0000

> Since the early days TX stops if there isn't enough free pending slots to
> consume a maximum sized (slot-wise) packet. Probably the reason for that is to
> avoid the case when we don't have enough free pending slot in the ring to finish
> the packet. But if we make sure that the pending ring has the same size as the
> shared ring, that shouldn't really happen. The frontend can only post packets
> which fit the to the free space of the shared ring. If it doesn't, the frontend
> has to stop, as it can only increase the req_prod when the whole packet fits
> onto the ring.
> This patch avoid using this checking, makes sure the 2 ring has the same size,
> and remove a checking from the callback. As now we don't stop the NAPI instance
> on this condition, we don't have to wake it up if we free pending slots up.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied.
