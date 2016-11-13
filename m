From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Sun, 13 Nov 2016 14:27:45 +0200
Message-ID: <CAJ3xEMhcVW8Y1SHx6WqW1C=m9VFgqtEK46PBi41YmfX6sYc9JA@mail.gmail.com>
References: <20161110105030.3724fe28@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Networking <netdev@vger.kernel.org>,
        linux-next <linux-next@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20161110105030.3724fe28@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 10, 2016 at 1:50 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi all,
>
> Today's linux-next merge of the net-next tree got a conflict in:
>
>   drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
>
> between commit:
>   ee39fbc4447d ("net/mlx5: E-Switch, Set the actions for offloaded rules properly")
> from the net tree and commit:
>   66958ed906b8 ("net/mlx5: Support encap id when setting new steering entry")
> from the net-next tree.

> I fixed it up (see below) and can carry the fix as necessary.

Thanks Stephen, the fix is correct. Dave will hit the conflict the
next time he rebases
net-next on net and will solve it there. Hence the conflict will not
show up in linux-next
once you re-peek net-next.

Or.

> diff --cc drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> index d239f5d0ea36,50fe8e8861bb..000000000000
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> @@@ -57,14 -58,14 +58,15 @@@ mlx5_eswitch_add_offloaded_rule(struct
>         if (esw->mode != SRIOV_OFFLOADS)
>                 return ERR_PTR(-EOPNOTSUPP);
>
>  -      flow_act.action = attr->action;
>  +      /* per flow vlan pop/push is emulated, don't set that into the firmware */
> -       action = attr->action & ~(MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH | MLX5_FLOW_CONTEXT_ACTION_VLAN_POP);
> ++      flow_act.action = attr->action & ~(MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH | MLX5_FLOW_CONTEXT_ACTION_VLAN_POP);
>
> -       if (action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
> -               dest.type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
> -               dest.vport_num = attr->out_rep->vport;
> -               action = MLX5_FLOW_CONTEXT_ACTION_FWD_DEST;
> -       } else if (action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
> +       if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST) {
> +               dest[i].type = MLX5_FLOW_DESTINATION_TYPE_VPORT;
> +               dest[i].vport_num = attr->out_rep->vport;
> +               i++;
> +       }
> +       if (flow_act.action & MLX5_FLOW_CONTEXT_ACTION_COUNT) {
>                 counter = mlx5_fc_create(esw->dev, true);
>                 if (IS_ERR(counter))
>                         return ERR_CAST(counter);
