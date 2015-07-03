From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: add NV congestion control
Date: Fri, 03 Jul 2015 07:00:23 +0200
Message-ID: <1435899623.11970.61.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:35581 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbbGCFA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 01:00:27 -0400
Received: by wgjx7 with SMTP id x7so78587123wgj.2
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 22:00:25 -0700 (PDT)
In-Reply-To: <1435886484-1709996-1-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-02 at 18:21 -0700, Lawrence Brakmo wrote:
> This is a request for comments.
> 
> TCP-NV (New Vegas) is a major update to TCP-Vegas. An earlier version of
> NV was presented at 2010's LPC (slides). It is a delayed based
> congestion avoidance for the data center. This version has been tested
> within a 10G rack where the HW RTTs are 20-50us.
> 
> A description of TCP-NV, including implementation and experimental
> results, can be found at:
> http://www.brakmo.org/networking/tcp-nv/TCPNV.html
> 
> The current version includes many module parameters to support
> experimentation with the parameters.
> 
> Signed-off-by: Lawrence Brakmo <lawrence@brakmo.org>
> ---
>  include/linux/skbuff.h     |   2 +-
>  include/linux/tcp.h        |   4 +
>  include/net/tcp.h          |   5 +-
>  net/ipv4/Kconfig           |  16 ++
>  net/ipv4/Makefile          |   1 +
>  net/ipv4/sysctl_net_ipv4.c |   9 +
>  net/ipv4/tcp_input.c       |   5 +
>  net/ipv4/tcp_nv.c          | 477 +++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv4/tcp_output.c      |   4 +-
>  9 files changed, 520 insertions(+), 3 deletions(-)
>  create mode 100644 net/ipv4/tcp_nv.c
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index d6cdd6e..96a131d 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -547,7 +547,7 @@ struct sk_buff {
>  	 * want to keep them across layers you have to do a skb_clone()
>  	 * first. This is owned by whoever has the skb queued ATM.
>  	 */
> -	char			cb[48] __aligned(8);
> +	char			cb[52] __aligned(8);
>  

skb bloat alert.

This adds 8 bytes to cb[], and sk_buff, for no reason.

tcp_skb_cb is currently 44 bytes, so even if you add one u32, it should
not exceed cb[]
