From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next] bnx2: Close device if tx_timeout reset fails
Date: Sat, 16 Jul 2011 00:16:06 -0300
Message-ID: <20110716001606.528a55c8@asterix.rh>
References: <1310748838-30877-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865Ab1GPDQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 23:16:11 -0400
In-Reply-To: <1310748838-30877-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Jul 2011 09:53:58 -0700
"Michael Chan" <mchan@broadcom.com> wrote:
...
> To fix it, we call dev_close() if bnx2_init_nic() fails.
> One minor wrinkle to deal with is the cancel_work_sync()
> call in bnx2_close() to cancel bnx2_reset_task().  The
> call will wait forever because it is trying to cancel
> itself and the workqueue will be stuck.
> 
> Since bnx2_reset_task() holds the rtnl_lock() and checks
> for netif_running() before proceeding, there is no need
> to cancel bnx2_reset_task() in bnx2_close() even if
> bnx2_close() and bnx2_reset_task() are running concurrently.
> The rtnl_lock() serializes the 2 calls.
> 
> We need to move the cancel_work_sync() call to
> bnx2_remove_one() to make sure it is canceled before freeing
> the netdev struct.

It looks good. I'm traveling now, so I'll test this on Monday.
thanks,
fbl
