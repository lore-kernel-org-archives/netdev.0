From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.4] Use double-linked list for dev->qdisc_list
Date: Wed, 04 Aug 2004 15:30:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4110E505.1010205@trash.net>
References: <20040804125926.GA15324@krezus.e-wro.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Paszkowski <tomasz.paszkowski@e-wro.pl>
In-Reply-To: <20040804125926.GA15324@krezus.e-wro.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tomasz Paszkowski wrote:

>This patch changes dev->qdisc_list to a double-linked list. This solves
>the performance problems when destroying qdiscs with large number of inner
>qdiscs.
>
>This is backported version of Patrick McHardy patch (03-qdisc_list-list_h.diff)
>or 2.6 kernels.
>  
>
Looks good, except for the last hunk, the BUG_TRAP is valid in 2.4 because
it doesn't use RCU. Change it to BUG_TRAP(list_empty(&dev->qdisc_list)).

>  
>
>------------------------------------------------------------------------
>
> #endif
>-	BUG_TRAP(dev->qdisc_list == NULL);
> 	BUG_TRAP(!timer_pending(&dev->watchdog_timer));
>-	dev->qdisc_list = NULL;
> 	spin_unlock_bh(&dev->queue_lock);
> 	write_unlock(&qdisc_tree_lock);
> }
>  
>
