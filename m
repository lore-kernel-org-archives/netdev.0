From: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 03/21] odp-util: Add tun_key to
 parse_odp_key_attr()
Date: Thu, 24 May 2012 09:29:11 -0700
Message-ID: <20120524162911.GD26173@nicira.com>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
	<1337850554-10339-4-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1337850554-10339-4-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

On Thu, May 24, 2012 at 06:08:56PM +0900, Simon Horman wrote:
> Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>

But I don't see him CCed?

> +        ovs_be32 ipv4_src;
> +        ovs_be32 ipv4_dst;
> +        unsigned long long tun_flags;
> +        int ipv4_tos;
> +        int ipv4_ttl;
> +        int n = -1;
> +
> +        if (sscanf(s, "ipv4_tunnel(tun_id=%31[x0123456789abcdefABCDEF]"
> +                   ",flags=%llx,src="IP_SCAN_FMT",dst="IP_SCAN_FMT
> +                   ",tos=%i,ttl=%i)%n",
> +                   tun_id_s, &tun_flags,
> +                   IP_SCAN_ARGS(&ipv4_src), IP_SCAN_ARGS(&ipv4_dst),
> +                   &ipv4_tos, &ipv4_ttl, &n) > 0
> +            && n > 0) {

Does this compile?  I don't see a declaration of tun_id_s.

In the ODP printer and parser, we usually require fields that are
hexadecimal to be written with an explicit "0x" on output (using
something like "0x%x" or "%#x" on output), and then use "%i" on input,
so that it is always unambiguous at a glance whether a number is
decimal or hexadecimal.  I'd appreciate it if we could maintain that
here (I didn't look over at the printer code to see if it writes 0x,
but I'd like it to).

Otherwise, this looks good, thank you.
