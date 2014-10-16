From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH 1/1 net-next] openvswitch: use vport instead of p
Date: Wed, 15 Oct 2014 18:11:52 -0700
Message-ID: <CALnjE+ohd=zcCVmBEcaGqyD70uX=DXj-YoKP2pFw5JuncxjiFQ@mail.gmail.com>
References: <1413399821-8558-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog014.obsmtp.com ([74.125.150.68]:32931 "HELO
	na6sys009bog014.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751001AbaJPBLx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:11:53 -0400
Received: by mail-ig0-f177.google.com with SMTP id a13so2526863igq.10
        for <netdev@vger.kernel.org>; Wed, 15 Oct 2014 18:11:52 -0700 (PDT)
In-Reply-To: <1413399821-8558-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2014 at 12:03 PM, Fabian Frederick <fabf@skynet.be> wrote:
> All functions used struct vport *vport except
> ovs_vport_find_upcall_portid.
>
> This fixes 1 kerneldoc warning
>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>


Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.

> ---
>  net/openvswitch/vport.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index 53001b0..6015802 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -408,13 +408,13 @@ int ovs_vport_get_upcall_portids(const struct vport *vport,
>   *
>   * Returns the portid of the target socket.  Must be called with rcu_read_lock.
>   */
> -u32 ovs_vport_find_upcall_portid(const struct vport *p, struct sk_buff *skb)
> +u32 ovs_vport_find_upcall_portid(const struct vport *vport, struct sk_buff *skb)
>  {
>         struct vport_portids *ids;
>         u32 ids_index;
>         u32 hash;
>
> -       ids = rcu_dereference(p->upcall_portids);
> +       ids = rcu_dereference(vport->upcall_portids);
>
>         if (ids->n_ids == 1 && ids->ids[0] == 0)
>                 return 0;
> --
> 1.9.3
>
