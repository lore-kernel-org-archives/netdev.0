From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 04/21] vswitchd: Add iface_parse_tunnel
Date: Thu, 24 May 2012 09:47:38 -0700
Message-ID: <20120524164738.GE26173@nicira.com>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
	<1337850554-10339-5-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1337850554-10339-5-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

The concept seems OK to me here.  I have only a few minor comments.

On Thu, May 24, 2012 at 06:08:57PM +0900, Simon Horman wrote:
> +#define TNL_F_CSUM          (1 << 0) /* Checksum packets. */
> +#define TNL_F_TOS_INHERIT	(1 << 1) /* Inherit ToS from inner packet. */
> +#define TNL_F_TTL_INHERIT	(1 << 2) /* Inherit TTL from inner packet. */
> +#define TNL_F_DF_INHERIT	(1 << 3) /* Inherit DF bit from inner packet. */
> +#define TNL_F_DF_DEFAULT	(1 << 4) /* Set DF bit if inherit off or
> +                                      * not IP. */
> +#define TNL_F_PMTUD		    (1 << 5) /* Enable path MTU discovery. */
> +#define TNL_F_HDR_CACHE		(1 << 6) /* Enable tunnel header caching. */
> +#define TNL_F_IPSEC		    (1 << 7) /* Traffic is IPsec encrypted. */
> +#define TNL_F_IN_KEY	    (1 << 8) /* Tunnel port has input key. */
> +#define TNL_F_OUT_KEY	    (1 << 9) /* Tunnel port has output key. */

Some of the above definitions use all spaces, others use tabs.  It's
OVS userspace code so it's better to use all spaces, I think.

> +    if (is_ipsec) {
> +        char *file_name = xasprintf("%s/%s", ovs_rundir(),
> +                "ovs-monitor-ipsec.pid");
> +        pid_t pid = read_pidfile(file_name);
> +        free(file_name);
> +        if (pid < 0) {
> +            VLOG_ERR("%s: IPsec requires the ovs-monitor-ipsec daemon",
> +                     iface_cfg->name);
> +            goto err;
> +        }

I just noticed that we re-read this pidfile every time we parse an
IPsec tunnel.  I guess that would be a big waste of time if we have a
lot of IPsec tunnels.  I'll make a note to consider fixing this
separately (it's not your problem).
