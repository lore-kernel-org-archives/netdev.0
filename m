From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH openvswitch] linux: Signal datapath that
 unaligned Netlink message can be received
Date: Thu, 21 Nov 2013 22:49:00 +0400
Message-ID: <528E559C.4020201@cogentembedded.com>
References: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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

Hello.

On 21-11-2013 22:15, Thomas Graf wrote:

> Following commit (''netlink: Do not enforce alignment of last Netlink
> attribute''), signal the ability to receive unaligned Netlink messages
> to the datapath to enable utilization of zerocopy optimizations.

> Signed-off-by: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
[...]

> diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
> index 1dcf321..5c952bc 100644
> --- a/lib/dpif-linux.c
> +++ b/lib/dpif-linux.c
[...]
> @@ -1839,6 +1841,10 @@ dpif_linux_dp_to_ofpbuf(const struct dpif_linux_dp *dp, struct ofpbuf *buf)
>           nl_msg_put_u32(buf, OVS_DP_ATTR_UPCALL_PID, *dp->upcall_pid);
>       }
>
> +    if (dp->user_features) {
> +        nl_msg_put_u32(buf, OVS_DP_ATTR_USER_FEATURES, dp->user_features);
> +    }
> +

    {} not needed here.

WBR, Sergei
