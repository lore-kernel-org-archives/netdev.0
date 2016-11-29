From: Pravin Shelar <pshelar@ovn.org>
Subject: Re: [PATCH] openvswitch: add sanity check in queue_userspace_packet.
Date: Mon, 28 Nov 2016 21:15:52 -0800
Message-ID: <CAOrHB_AgEXL4hrrZ5FCes2dQXMBUTA6NssvFDKs=uxjy=aOHwg@mail.gmail.com>
References: <1480394196-73882-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:52661 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754124AbcK2FP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 00:15:58 -0500
In-Reply-To: <1480394196-73882-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 8:36 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> kernel will crash in oops if genlmsg_put return NULL,
> so add the sanity check.
>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  net/openvswitch/datapath.c | 4 ++++
>  1 file changed, 4 insertions(+)
>
> diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
> index 2d4c4d3..ceb1b1e 100644
> --- a/net/openvswitch/datapath.c
> +++ b/net/openvswitch/datapath.c
> @@ -474,6 +474,10 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
>
>         upcall = genlmsg_put(user_skb, 0, 0, &dp_packet_genl_family,
>                              0, upcall_info->cmd);
> +       if (!upcall) {
> +               err = -EMSGSIZE;
> +               goto out;
> +       }

user_skb has already enough space allocated, so there is no need to
check upcall pointer.
