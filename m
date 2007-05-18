From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] gianfar: Add I/O barriers when touching buffer descriptor
 ownership.
Date: Thu, 17 May 2007 20:45:49 -0400
Message-ID: <464CF73D.9050505@garzik.org>
References: <20070516200659.GA23548@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43551 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755591AbXERApw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:45:52 -0400
In-Reply-To: <20070516200659.GA23548@ld0162-tx32.am.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Scott Wood wrote:
> The hardware must not see that is given ownership of a buffer until it is
> completely written, and when the driver receives ownership of a buffer,
> it must ensure that any other reads to the buffer reflect its final
> state.  Thus, I/O barriers are added where required.
> 
> Without this patch, I have observed GCC reordering the setting of
> bdp->length and bdp->status in gfar_new_skb.  Hardware reordering
> was also theoretically possible.
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
> I've added the requested comments to the source code about
> the use of eieio().  Jeff, please consider for 2.6.22, as it
> fixes a bug that has been observed.
> 
>  drivers/net/gianfar.c |   11 +++++++++++
>  1 files changed, 11 insertions(+), 0 deletions(-)

applied


