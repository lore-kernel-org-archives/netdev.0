From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH v2] openvswitch: distinguish between the dropped and
 consumed skb
Date: Wed, 3 Sep 2014 13:36:26 -0700
Message-ID: <CALnjE+qTNTAH=XaPh86BvRntLzSNnRXYLSJpkdpGJJgVNbVODA@mail.gmail.com>
References: <1409737426-22245-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@noironetworks.com>
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog020.obsmtp.com ([74.125.150.80]:58533 "HELO
	na6sys009bog020.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756606AbaICUg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 16:36:27 -0400
Received: by mail-ie0-f171.google.com with SMTP id rp18so10412270iec.16
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 13:36:26 -0700 (PDT)
In-Reply-To: <1409737426-22245-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 3, 2014 at 2:43 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> distinguish between the dropped and consumed skb, not assume the skb
> is consumed always
>
> Cc: Thomas Graf <tgraf@noironetworks.com>
> Cc: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.
> ---
>  net/openvswitch/datapath.c |    7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 35d866f..91d66b7 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -265,8 +265,11 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
>                 upcall.key = &key;
>                 upcall.userdata = NULL;
>                 upcall.portid = ovs_vport_find_upcall_portid(p, skb);
> -               ovs_dp_upcall(dp, skb, &upcall);
> -               consume_skb(skb);
> +               error = ovs_dp_upcall(dp, skb, &upcall);
> +               if (unlikely(error))
> +                       kfree_skb(skb);
> +               else
> +                       consume_skb(skb);
>                 stats_counter = &stats->n_missed;
>                 goto out;
>         }
> --
> 1.7.10.4
>
