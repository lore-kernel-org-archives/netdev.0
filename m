From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net] openvswitch: Don't validate IPv6 label masks.
Date: Wed, 19 Nov 2014 14:05:09 -0800
Message-ID: <CALnjE+rtJG+o_jwQtCaWJkjiGOeNA7fWNbDhgFnx-_v4kpA5hA@mail.gmail.com>
References: <1416434089-47062-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1416434089-47062-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2014 at 1:54 PM, Joe Stringer <joestringer@nicira.com> wrote:
> When userspace doesn't provide a mask, OVS datapath generates a fully
> unwildcarded mask for the flow by copying the flow and setting all bits
> in all fields. For IPv6 label, this creates a mask that matches on the
> upper 12 bits, causing the following error:
>
> openvswitch: netlink: Invalid IPv6 flow label value (value=ffffffff, max=fffff)
>
> This patch ignores the label validation check for masks, avoiding this
> error.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Thanks for the fix.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

> ---
> v3: Alternative approach.
>     Was "openvswitch: Fix mask generation for IPv6 labels."
> v2: OR lower 20 bits (upper 12 bits remain from earlier memdup)
> ---
>  net/openvswitch/flow_netlink.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index fa4ec2e..089b195 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -690,7 +690,7 @@ static int ovs_key_from_nlattrs(struct sw_flow_match *match, u64 attrs,
>                         return -EINVAL;
>                 }
>
> -               if (ipv6_key->ipv6_label & htonl(0xFFF00000)) {
> +               if (!is_mask && ipv6_key->ipv6_label & htonl(0xFFF00000)) {
>                         OVS_NLERR("IPv6 flow label %x is out of range (max=%x).\n",
>                                   ntohl(ipv6_key->ipv6_label), (1 << 20) - 1);
>                         return -EINVAL;
> --
> 1.7.10.4
>
