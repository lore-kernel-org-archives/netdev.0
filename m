From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next] xen-netback: Rework rx_work_todo
Date: Wed, 15 Jan 2014 10:37:07 +0000
Message-ID: <20140115103707.GI5698@zion.uk.xensource.com>
References: <1389727719-21439-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389727719-21439-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 07:28:39PM +0000, Zoltan Kiss wrote:
> The recent patch to fix receive side flow control (11b57f) solved the spinning
> thread problem, however caused an another one. The receive side can stall, if:
> - xenvif_rx_action sets rx_queue_stopped to false
> - interrupt happens, and sets rx_event to true
> - then xenvif_kthread sets rx_event to false
> 

If you mean "rx_work_todo" returns false.

In this case

(!skb_queue_empty(&vif->rx_queue) && !vif->rx_queue_stopped) || vif->rx_event;

can still be true, can't it?

> Also, through rx_event a malicious guest can force the RX thread to spin. This
> patch ditch that two variable, and rework rx_work_todo. If the thread finds it

This seems to be a bigger problem. Can you elaborate?

Wei.
