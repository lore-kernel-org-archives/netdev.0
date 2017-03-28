From: walter harms <wharms@bfs.de>
Subject: Re: [PATCH] VSOCK: remove unnecessary ternary operator on return
 value
Date: Tue, 28 Mar 2017 18:04:45 +0200
Message-ID: <58DA899D.70209@bfs.de>
References: <20170328155424.22873-1-colin.king@canonical.com>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        Adit Ranadive <aditr@vmware.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Stefan Hajnoczi <stefanha@redhat.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02-sz.bfs.de ([194.94.69.103]:39741 "EHLO mx02-sz.bfs.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751386AbdC1QFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 12:05:09 -0400
In-Reply-To: <20170328155424.22873-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 28.03.2017 17:54, schrieb Colin King:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Rather than assign the positive errno values to ret and then
> checking if it is positive and flip the sign, just set ret to
> be the -ve errno value.
> 
> Detected by CoverityScan, CID#986649 ("Logically Dead Code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/vmw_vsock/vmci_transport.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/vmw_vsock/vmci_transport.c b/net/vmw_vsock/vmci_transport.c
> index 4be4fbbc0b50..a68cd6b0fb72 100644
> --- a/net/vmw_vsock/vmci_transport.c
> +++ b/net/vmw_vsock/vmci_transport.c
> @@ -100,27 +100,27 @@ static s32 vmci_transport_error_to_vsock_error(s32 vmci_error)
>  
>  	switch (vmci_error) {
>  	case VMCI_ERROR_NO_MEM:
> -		err = ENOMEM;
> +		err = -ENOMEM;
>  		break;
>  	case VMCI_ERROR_DUPLICATE_ENTRY:
>  	case VMCI_ERROR_ALREADY_EXISTS:
> -		err = EADDRINUSE;
> +		err = -EADDRINUSE;
>  		break;
>  	case VMCI_ERROR_NO_ACCESS:
> -		err = EPERM;
> +		err = -EPERM;
>  		break;
>  	case VMCI_ERROR_NO_RESOURCES:
> -		err = ENOBUFS;
> +		err = -ENOBUFS;
>  		break;
>  	case VMCI_ERROR_INVALID_RESOURCE:
> -		err = EHOSTUNREACH;
> +		err = -EHOSTUNREACH;
>  		break;
>  	case VMCI_ERROR_INVALID_ARGS:
>  	default:
> -		err = EINVAL;
> +		err = -EINVAL;
>  	}
>  
> -	return err > 0 ? -err : err;
> +	return err;
>  }
>  
>  static u32 vmci_transport_peer_rid(u32 peer_cid)


yes, but because there is nothing to do you could return directly
and forget about err.

note: why is there a MCI_ERROR_NO_MEM when you can map this to ENOMEM ?

re,
 wh
