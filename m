From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] vmxnet3: Use correct minimum MTU value
Date: Wed, 18 Oct 2017 09:15:49 +0200
Message-ID: <20171018071549.GB30059@lunn.ch>
References: <1508250823-1954-1-git-send-email-mgamal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, skhare@vmware.com, pv-drivers@vmware.com,
        linux-kernel@vger.kernel.org, cavery@redhat.com, otubo@redhat.com,
        vkuznets@redhat.com
To: Mohammed Gamal <mgamal@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:49121 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1761186AbdJRHPv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 03:15:51 -0400
Content-Disposition: inline
In-Reply-To: <1508250823-1954-1-git-send-email-mgamal@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 04:33:43PM +0200, Mohammed Gamal wrote:
> Currently the vmxnet3 driver has a minimum MTU value of 60. Which
> goes against the RFC791 spec which specifies it at 68.
> 
> Setting MTU to values between 60 <= MTU <= 67 causes the network
> interface to lose its IP, and it fails to restart.
> 
> This sets the minimum value to ETH_MIN_MTU (68) which is compatible
> with is according to spec.

Hi Mohammed

I'm not sure this is actually correct. Yes, IP sets a minimum of 68,
and the IP address will be removed if you set a smaller MTU. But the
interface should still usable for other protocols. It can still send
and receive frames.

Is the hardware happy to send 60 byte frames?

       Andrew

> 
> Reported-by: Bo Yang <boyang@redhat.com>
> Signed-off-by: Mohammed Gamal <mgamal@redhat.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_defs.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/vmxnet3/vmxnet3_defs.h b/drivers/net/vmxnet3/vmxnet3_defs.h
> index c3a3164..4ad905a 100644
> --- a/drivers/net/vmxnet3/vmxnet3_defs.h
> +++ b/drivers/net/vmxnet3/vmxnet3_defs.h
> @@ -749,7 +749,7 @@ struct Vmxnet3_DriverShared {
>  	((vfTable[vid >> 5] & (1 << (vid & 31))) != 0)
>  
>  #define VMXNET3_MAX_MTU     9000
> -#define VMXNET3_MIN_MTU     60
> +#define VMXNET3_MIN_MTU     ETH_MIN_MTU
>  
>  #define VMXNET3_LINK_UP         (10000 << 16 | 1)    /* 10 Gbps, up */
>  #define VMXNET3_LINK_DOWN       0
> -- 
> 1.8.3.1
> 
