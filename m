From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net 7/7] openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT
Date: Wed, 30 Sep 2015 17:32:02 -0700
Message-ID: <CALnjE+ra5ys4HKcwBSzGDjRSY7DdHsOQjTRp-U0zYRXiNLnTHQ@mail.gmail.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
	<1443566380-22640-8-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443566380-22640-8-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 29, 2015 at 3:39 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, the CT_ATTR_FLAGS attribute, when nested under the
> OVS_ACTION_ATTR_CT, encoded a 32-bit bitmask of flags that modify the
> semantics of the ct action. It's more extensible to just represent each
> flag as a nested attribute, and this requires no additional error
> checking to reject flags that aren't currently supported.
>
> Suggested-by: Ben Pfaff <blp@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
...
...

> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 167cf43..effa78c 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
> @@ -42,12 +42,18 @@ struct md_label {
>         struct ovs_key_ct_label mask;
>  };
>
> +/* Flags for performing connection tracking.
> + *
> + * CT_F_COMMIT: Commits the flow to the conntrack table.
> + */
> +#define CT_F_COMMIT    BIT(0)
> +
>  /* Conntrack action context for execution. */
>  struct ovs_conntrack_info {
>         struct nf_conntrack_helper *helper;
>         struct nf_conntrack_zone zone;
>         struct nf_conn *ct;
> -       u32 flags;
> +       u8 flags;               /* bitmask of CT_F_*. */

I think bit field has better readability in such use case.
Otherwise looks good.
