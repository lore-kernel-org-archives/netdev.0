From: Pravin Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH net-next] openvswitch: make generic netlink
	group const
Date: Wed, 16 Jul 2014 17:02:35 -0700
Message-ID: <CALnjE+o8rF+VzMomhfVE0P0ruRp9CKFbtachrXOEm34eP9Qyow@mail.gmail.com>
References: <20140716112552.55852dbf@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20140716112552.55852dbf@samsung-9>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On Wed, Jul 16, 2014 at 11:25 AM, Stephen Hemminger
<stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org> wrote:
> Generic netlink tables can be const.
>

OVS external module can not use const due to compatibility code. But
there is no reason we can not do it for in-kernel module.

Thanks.

> Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
>
>
> --- a/net/openvswitch/datapath.c        2014-07-09 03:06:11.400291765 -0700
> +++ b/net/openvswitch/datapath.c        2014-07-09 03:09:35.688297236 -0700
> @@ -66,16 +66,16 @@ static struct genl_family dp_packet_genl
>  static struct genl_family dp_flow_genl_family;
>  static struct genl_family dp_datapath_genl_family;
>
> -static struct genl_multicast_group ovs_dp_flow_multicast_group = {
> -       .name = OVS_FLOW_MCGROUP
> +static const struct genl_multicast_group ovs_dp_flow_multicast_group = {
> +       .name = OVS_FLOW_MCGROUP,
>  };
>
> -static struct genl_multicast_group ovs_dp_datapath_multicast_group = {
> -       .name = OVS_DATAPATH_MCGROUP
> +static const struct genl_multicast_group ovs_dp_datapath_multicast_group = {
> +       .name = OVS_DATAPATH_MCGROUP,
>  };
>
> -struct genl_multicast_group ovs_dp_vport_multicast_group = {
> -       .name = OVS_VPORT_MCGROUP
> +static const struct genl_multicast_group ovs_dp_vport_multicast_group = {
> +       .name = OVS_VPORT_MCGROUP,
>  };
>
>  /* Check if need to build a reply message.
> @@ -1190,7 +1190,7 @@ static const struct nla_policy flow_poli
>         [OVS_FLOW_ATTR_CLEAR] = { .type = NLA_FLAG },
>  };
>
> -static struct genl_ops dp_flow_genl_ops[] = {
> +static const struct genl_ops dp_flow_genl_ops[] = {
>         { .cmd = OVS_FLOW_CMD_NEW,
>           .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
>           .policy = flow_policy,
> @@ -1578,7 +1578,7 @@ static const struct nla_policy datapath_
>         [OVS_DP_ATTR_USER_FEATURES] = { .type = NLA_U32 },
>  };
>
> -static struct genl_ops dp_datapath_genl_ops[] = {
> +static const struct genl_ops dp_datapath_genl_ops[] = {
>         { .cmd = OVS_DP_CMD_NEW,
>           .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
>           .policy = datapath_policy,
> @@ -1945,7 +1945,7 @@ static const struct nla_policy vport_pol
>         [OVS_VPORT_ATTR_OPTIONS] = { .type = NLA_NESTED },
>  };
>
> -static struct genl_ops dp_vport_genl_ops[] = {
> +static const struct genl_ops dp_vport_genl_ops[] = {
>         { .cmd = OVS_VPORT_CMD_NEW,
>           .flags = GENL_ADMIN_PERM, /* Requires CAP_NET_ADMIN privilege. */
>           .policy = vport_policy,
