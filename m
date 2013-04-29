From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next 1/2] vxlan: do not set SKB_GSO_UDP
Date: Mon, 29 Apr 2013 09:35:58 -0700
Message-ID: <CALnjE+ogi+PN9r-CfcsF_e7fQFK+h=8bkWruXqY6gKUtrCY8yg@mail.gmail.com>
References: <1367172962-17369-1-git-send-email-dmitry@broadcom.com>
	<1367172962-17369-2-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:54890 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757500Ab3D2Qf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 12:35:59 -0400
Received: by mail-qc0-f200.google.com with SMTP id j34so9658533qco.3
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 09:35:58 -0700 (PDT)
In-Reply-To: <1367172962-17369-2-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 28, 2013 at 11:16 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> Since SKB_GSO_* flags are set by appropriate gso_segment callback
> in TCP/UDP layer.
>
> CC: Pravin B Shelar <pshelar@nicira.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---

udp flag was set since we are using udp offload handler for vxlan gso.
But I think it forces to have udp offload for tunnel offloading.
Therefore the change looks right.

Acked-by: Pravin B Shelar <pshelar@nicira.com>

>  drivers/net/vxlan.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index a7fd9a0..b92c6a0 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -913,7 +913,7 @@ static int handle_offloads(struct sk_buff *skb)
>                 if (unlikely(err))
>                         return err;
>
> -               skb_shinfo(skb)->gso_type |= (SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP);
> +               skb_shinfo(skb)->gso_type |= SKB_GSO_UDP_TUNNEL;
>         } else if (skb->ip_summed != CHECKSUM_PARTIAL)
>                 skb->ip_summed = CHECKSUM_NONE;
>
> --
> 1.8.1.4
>
>
