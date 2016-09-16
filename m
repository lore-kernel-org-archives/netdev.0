From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: fix SSN comparision
Date: Fri, 16 Sep 2016 09:13:53 -0400
Message-ID: <20160916131353.GA13122@hmsreliant.think-freely.org>
References: <9f22e4725d836feda1b2c2483303adb30838216f.1473962178.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33860 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756624AbcIPNOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 09:14:09 -0400
Content-Disposition: inline
In-Reply-To: <9f22e4725d836feda1b2c2483303adb30838216f.1473962178.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 15, 2016 at 03:02:38PM -0300, Marcelo Ricardo Leitner wrote:
> This function actually operates on u32 yet its paramteres were declared
> as u16, causing integer truncation upon calling.
> 
> Note in patch context that ADDIP_SERIAL_SIGN_BIT is already 32 bits.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> ---
> 
> This issue exists since before git import, so I can't put a Fixes tag.
> Also, that said, probably not worth queueing it to stable.
> Thanks
> 
>  include/net/sctp/sm.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
> index efc01743b9d641bf6b16a37780ee0df34b4ec698..bafe2a0ab9085f24e17038516c55c00cfddd02f4 100644
> --- a/include/net/sctp/sm.h
> +++ b/include/net/sctp/sm.h
> @@ -382,7 +382,7 @@ enum {
>  	ADDIP_SERIAL_SIGN_BIT = (1<<31)
>  };
>  
> -static inline int ADDIP_SERIAL_gte(__u16 s, __u16 t)
> +static inline int ADDIP_SERIAL_gte(__u32 s, __u32 t)
>  {
>  	return ((s) == (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT);
>  }
> -- 
> 2.7.4
> 

Acked-by: Neil Horman <nhorman@tuxdriver.com>

> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
