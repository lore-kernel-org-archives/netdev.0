From: Feng Gao <gfree.wind@gmail.com>
Subject: Re: [PATCH v1 1/1 net-next] 8139cp: Fix one possible deadloop in cp_rx_poll
Date: Thu, 25 Aug 2016 22:37:20 +0800
Message-ID: <CA+6hz4o5CcoENp0Dmky0gAdsxiQv41PZgfRpodN9Oj=N-F9XOQ@mail.gmail.com>
References: <1472089539-11543-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: dwmw2@infradead.org, "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Gao Feng <fgao@ikuai8.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:34293 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750969AbcHYOhV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 10:37:21 -0400
Received: by mail-ua0-f179.google.com with SMTP id k90so86979323uak.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 07:37:21 -0700 (PDT)
In-Reply-To: <1472089539-11543-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 9:45 AM,  <fgao@ikuai8.com> wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> When cp_rx_poll does not get enough packet, it will check the rx
> interrupt status again. If so, it will jumpt to rx_status_loop again.
> But the goto jump resets the rx variable as zero too.
>
> As a result, it causes one possible deadloop. Assume this case,
> rx_status_loop only gets the packet count which is less than budget,
> and (cpr16(IntrStatus) & cp_rx_intr_mask) condition is always true.
> It causes the deadloop happens and system is blocked.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---
>  drivers/net/ethernet/realtek/8139cp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index deae10d..5297bf7 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
> @@ -467,8 +467,8 @@ static int cp_rx_poll(struct napi_struct *napi, int budget)
>         unsigned int rx_tail = cp->rx_tail;
>         int rx;
>
> -rx_status_loop:
>         rx = 0;
> +rx_status_loop:
>         cpw16(IntrStatus, cp_rx_intr_mask);
>
>         while (rx < budget) {
> --
> 1.9.1
>
>

Sorry, this commit should be for net.git, not net-next.git
Because it fixed one possible infinite loop.

Best Regards
Feng
