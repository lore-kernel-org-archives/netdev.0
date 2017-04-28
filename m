From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next v2] bpf: add support for generic xdp
Date: Fri, 28 Apr 2017 15:43:06 -0700
Message-ID: <20170428154306.02864aae@xeon-e3>
References: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, davem@davemloft.net,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34086 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967170AbdD1WnT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 18:43:19 -0400
Received: by mail-pg0-f42.google.com with SMTP id v1so21148411pgv.1
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 15:43:19 -0700 (PDT)
In-Reply-To: <e2ca217f7b95b4dd0b5fa8650e8fcf783de73967.1493386943.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 28 Apr 2017 15:44:29 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> diff --git a/ip/iplink.c b/ip/iplink.c
> index 866ad72..96b0da3 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -606,9 +606,12 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>  			if (get_integer(&mtu, *argv, 0))
>  				invarg("Invalid \"mtu\" value\n", *argv);
>  			addattr_l(&req->n, sizeof(*req), IFLA_MTU, &mtu, 4);
> -		} else if (strcmp(*argv, "xdp") == 0) {
> +		} else if (strcmp(*argv, "xdpgeneric") == 0 ||
> +			   strcmp(*argv, "xdp") == 0) {
> +			bool generic = strcmp(*argv, "xdpgeneric") == 0;
> +
>  			NEXT_ARG();
> -			if (xdp_parse(&argc, &argv, req))
> +			if (xdp_parse(&argc, &argv, req, generic))
>  				exit(-1);
>  		} else if (strcmp(*argv, "netns") == 0) {

On a slightly related note, there really ought to be bash completion
scripts for ip command.  There is a slightly out of date one for tc already.
