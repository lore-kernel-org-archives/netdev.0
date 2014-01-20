From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: Rework rx_work_todo
Date: Mon, 20 Jan 2014 16:38:14 +0000
Message-ID: <20140120163814.GE11681@zion.uk.xensource.com>
References: <1389805867-22409-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389805867-22409-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 15, 2014 at 05:11:07PM +0000, Zoltan Kiss wrote:
> The recent patch to fix receive side flow control (11b57f) solved the spinning
> thread problem, however caused an another one. The receive side can stall, if:
> - [THREAD] xenvif_rx_action sets rx_queue_stopped to true
> - [INTERRUPT] interrupt happens, and sets rx_event to true
> - [THREAD] then xenvif_kthread sets rx_event to false
> - [THREAD] rx_work_todo doesn't return true anymore
> 
> Also, if interrupt sent but there is still no room in the ring, it take quite a
> long time until xenvif_rx_action realize it. This patch ditch that two variable,
> and rework rx_work_todo. If the thread finds it can't fit more skb's into the
> ring, it saves the last slot estimation into rx_last_skb_slots, otherwise it's
> kept as 0. Then rx_work_todo will check if:
> - there is something to send to the ring (like before)
> - there is space for the topmost packet in the queue
> 
> I think that's more natural and optimal thing to test than two bool which are
> set somewhere else.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Sorry for the delay.

Paul, thanks for reviewing.

Acked-by: Wei Liu <wei.liu2@citrix.com>

Wei.
