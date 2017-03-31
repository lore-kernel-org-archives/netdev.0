From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] bluetooth: 6lowpan: fix delay work init in
 add_peer_chan()
Date: Fri, 31 Mar 2017 12:10:44 +0200
Message-ID: <6B40174C-6834-4C3D-BF41-92119E78E353@holtmann.org>
References: <20170329061054.4300-1-michael.scott@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jukka Rissanen <jukka.rissanen@linux.intel.com>,
        linux-bluetooth@vger.kernel.org, linux-wpan@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Scott <michael.scott@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from coyote.holtmann.net ([212.227.132.17]:53860 "EHLO
        mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932342AbdCaKKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 31 Mar 2017 06:10:47 -0400
In-Reply-To: <20170329061054.4300-1-michael.scott@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

> When adding 6lowpan devices very rapidly we sometimes see a crash:
> [23122.306615] CPU: 2 PID: 0 Comm: swapper/2 Not tainted 4.9.0-43-arm64 #1 Debian 4.9.9.linaro.43-1
> [23122.315400] Hardware name: HiKey Development Board (DT)
> [23122.320623] task: ffff800075443080 task.stack: ffff800075484000
> [23122.326551] PC is at expire_timers+0x70/0x150
> [23122.330907] LR is at run_timer_softirq+0xa0/0x1a0
> [23122.335616] pc : [<ffff000008142dd8>] lr : [<ffff000008142f58>] pstate: 600001c5
> 
> This was due to add_peer_chan() unconditionally initializing the
> lowpan_btle_dev->notify_peers delayed work structure, even if the
> lowpan_btle_dev passed into add_peer_chan() had previously been
> initialized.
> 
> Normally, this would go unnoticed as the delayed work timer is set for
> 100 msec, however when calling add_peer_chan() faster than 100 msec it
> clears out a previously queued delay work causing the crash above.
> 
> To fix this, let add_peer_chan() know when a new lowpan_btle_dev is passed
> in so that it only performs the delay work initialization when needed.
> 
> Signed-off-by: Michael Scott <michael.scott@linaro.org>
> ---
> net/bluetooth/6lowpan.c | 10 +++++++---
> 1 file changed, 7 insertions(+), 3 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
