From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] bridge: fix message_age_timer calculation
Date: Tue, 10 Sep 2013 11:41:52 -0700
Message-ID: <20130910114152.40b28ef3@nehalam.linuxnetplumber.net>
References: <1378745768-4495-1-git-send-email-cphealy@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	buytenh@wantstofly.org
To: Chris Healy <cphealy@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:61037 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901Ab3IJSl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 14:41:56 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so8168502pad.33
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 11:41:55 -0700 (PDT)
In-Reply-To: <1378745768-4495-1-git-send-email-cphealy@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Sep 2013 09:56:08 -0700
Chris Healy <cphealy@gmail.com> wrote:

> This changes the message_age_timer calculation to use the BPDU's max age as opposed to the local bridge's max age.  This is in accordance with section 8.6.2.3.2 Step 2 of the 802.1D-1998 sprecification.
> 
> With the current implementation, when running with very large bridge diameters, convergance will not always occur even if a root bridge is configured to have a longer max age.
> 
> Tested successfully on bridge diameters of ~200.
> 
> Signed-off-by: Chris Healy <cphealy@gmail.com>
> ---
>  net/bridge/br_stp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index 1c0a50f..f1887ba 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -209,7 +209,7 @@ static void br_record_config_information(struct net_bridge_port *p,
>  	p->designated_age = jiffies - bpdu->message_age;
>  
>  	mod_timer(&p->message_age_timer, jiffies
> -		  + (p->br->max_age - bpdu->message_age));
> +		  + (bpdu->max_age - bpdu->message_age));
>  }
>  
>  /* called under bridge lock */

This makes sense.

Acked-by: Stephen Hemminger <stephen@networkplumber.org>
