From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: Adjust min age inc for HZ > 256
Date: Sun, 4 Mar 2012 21:03:50 -0800
Message-ID: <20120304210350.629ec5c6@nehalam.linuxnetplumber.net>
References: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58279 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1749667Ab2CEFDx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2012 00:03:53 -0500
In-Reply-To: <1330625539-10247-1-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Mar 2012 19:12:18 +0100
Joakim Tjernlund <Joakim.Tjernlund@transmode.se> wrote:

> min age increment needs to round up its min age tick for all
> HZ values to guarantee message age is increasing.
> 
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
> 
> The bridge list seems very slow so try netdev instead.
> 
>  net/bridge/br_stp.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index a04eeb6..9a8aebd 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -17,9 +17,9 @@
>  #include "br_private_stp.h"
>  
>  /* since time values in bpdu are in jiffies and then scaled (1/256)
> - * before sending, make sure that is at least one.
> + * before sending, make sure that is at least one STP tick.
>   */
> -#define MESSAGE_AGE_INCR	((HZ < 256) ? 1 : (HZ/256))
> +#define MESSAGE_AGE_INCR	((HZ / 256) + 1)
>  
>  static const char *const br_port_state_names[] = {
>  	[BR_STATE_DISABLED] = "disabled",

I don't understand why this is required.
  HZ = 100 then incr = 1
  HZ = 1000 then incr = 3 (your patch would make it for 4).
