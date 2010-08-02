From: Andreas Petlund <apetlund@simula.no>
Subject: Re: [PATCH] net: Add getsockopt support for TCP thin-streams
Date: Mon, 02 Aug 2010 13:46:32 +0200
Message-ID: <4C56B018.8030309@simula.no>
References: <1280533775-7700-1-git-send-email-johunt@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, juhlenko@akamai.com
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:59450 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab0HBMWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 08:22:24 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1OftTy-0004pu-NG
	for netdev@vger.kernel.org; Mon, 02 Aug 2010 13:47:02 +0200
In-Reply-To: <1280533775-7700-1-git-send-email-johunt@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2010 01:49 AM, Josh Hunt wrote:
> Initial TCP thin-stream commit did not add getsockopt support for the new
> socket options: TCP_THIN_LINEAR_TIMEOUTS and TCP_THIN_DUPACK. This adds support
> for them.
> 
> Signed-off-by: Josh Hunt <johunt@akamai.com>
> ---
>  net/ipv4/tcp.c |    6 ++++++
>  1 files changed, 6 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 65afeae..3ed3525 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -2591,6 +2591,12 @@ static int do_tcp_getsockopt(struct sock *sk, int level,
>  			return -EFAULT;
>  		return 0;
>  	}
> +	case TCP_THIN_LINEAR_TIMEOUTS:
> +		val = tp->thin_lto;
> +		break;
> +	case TCP_THIN_DUPACK:
> +		val = tp->thin_dupack;
> +		break;
>  	default:
>  		return -ENOPROTOOPT;
>  	}

Thanks for noticing and fixing this :)

Tested-by: Andreas Petlund <apetlund@simula.no>
Acked-by: Andreas Petlund <apetlund@simula.no>

-Andreas
