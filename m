From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [net-next PATCH 2/2] samples/bpf: fix XDP_FLAGS_SKB_MODE detach
 for xdp_tx_iptunnel
Date: Mon, 1 May 2017 09:28:45 -0400
Message-ID: <20170501132845.GA62204@C02RW35GFVH8.dhcp.broadcom.net>
References: <149363078062.17600.11958698183756401134.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsa@cumulusnetworks.com, netdev@vger.kernel.org,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35477 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2992663AbdEAN2p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 09:28:45 -0400
Received: by mail-qt0-f193.google.com with SMTP id o36so16402883qtb.2
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 06:28:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <149363078062.17600.11958698183756401134.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 11:26:20AM +0200, Jesper Dangaard Brouer wrote:
> The xdp_tx_iptunnel program can be terminated in two ways, after
> N-seconds or via Ctrl-C SIGINT.  The SIGINT code path does not
> handle detatching the correct XDP program, in-case the program
> was attached with XDP_FLAGS_SKB_MODE.
> 
> Fix this by storing the XDP flags as a global variable, which is
> available for the SIGINT handler function.
> 
> Fixes: 3993f2cb983b ("samples/bpf: Add support for SKB_MODE to xdp1 and xdp_tx_iptunnel")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Reviewed-by: Andy Gospodarek <andy@greyhouse.net>

> ---
>  samples/bpf/xdp_tx_iptunnel_user.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
> index 880dd4aebfa4..92b8bde9337c 100644
> --- a/samples/bpf/xdp_tx_iptunnel_user.c
> +++ b/samples/bpf/xdp_tx_iptunnel_user.c
> @@ -25,11 +25,12 @@
>  #define STATS_INTERVAL_S 2U
>  
>  static int ifindex = -1;
> +static __u32 xdp_flags = 0;
>  
>  static void int_exit(int sig)
>  {
>  	if (ifindex > -1)
> -		set_link_xdp_fd(ifindex, -1, 0);
> +		set_link_xdp_fd(ifindex, -1, xdp_flags);
>  	exit(0);
>  }
>  
> @@ -142,7 +143,6 @@ int main(int argc, char **argv)
>  	struct iptnl_info tnl = {};
>  	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
>  	struct vip vip = {};
> -	__u32 xdp_flags = 0;
>  	char filename[256];
>  	int opt;
>  	int i;
