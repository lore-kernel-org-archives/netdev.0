From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] linux: Signal datapath that unaligned
 Netlink message can be received
Date: Mon, 16 Dec 2013 17:23:43 -0800
Message-ID: <CAEP_g=-XN+fHnLpvpQ4A9MadYH4z9uKHcRBa84vOjWaV_K_YDg@mail.gmail.com>
References: <a960865f3ad68da1016f35085c1d84126e92f0a5.1385814128.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <a960865f3ad68da1016f35085c1d84126e92f0a5.1385814128.git.tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 30, 2013 at 4:25 AM, Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
> index 6c482d0..2d8a1aa 100644
> --- a/lib/dpif-linux.c
> +++ b/lib/dpif-linux.c
> @@ -73,6 +73,7 @@ struct dpif_linux_dp {
>      /* Attributes. */
>      const char *name;                  /* OVS_DP_ATTR_NAME. */
>      const uint32_t *upcall_pid;        /* OVS_DP_ATTR_UPCALL_PID. */
> +    uint32_t user_features;            /* OVS_DP_ATTR_USER_FEATURES */
>      struct ovs_dp_stats stats;         /* OVS_DP_ATTR_STATS. */
>      struct ovs_dp_megaflow_stats megaflow_stats;
>                                         /* OVS_DP_ATTR_MEGAFLOW_STATS.*/
> @@ -228,6 +229,7 @@ dpif_linux_open(const struct dpif_class *class OVS_UNUSED, const char *name,
>          dp_request.cmd = OVS_DP_CMD_NEW;
>          upcall_pid = 0;
>          dp_request.upcall_pid = &upcall_pid;
> +        dp_request.user_features |= OVS_DP_F_UNALIGNED;
>      } else {
>          dp_request.cmd = OVS_DP_CMD_GET;
>      }

Does this handle the case where we are opening an existing datapath
and need to update the features?
