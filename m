From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: [TIPC] Properly mask header fields
Date: Tue, 20 Feb 2007 10:47:24 -0800
Message-ID: <45DB423C.4010102@qualcomm.com>
References: <1171607254637-git-send-email-maxk@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	jon.maloy@ericsson.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from warlock.qualcomm.com ([129.46.50.49]:58534 "EHLO
	warlock.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030359AbXBTSxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 13:53:50 -0500
Received: from ithilien.qualcomm.com (ithilien.qualcomm.com [129.46.51.59])
	by warlock.qualcomm.com (8.13.6/8.13.6/1.0) with ESMTP id l1KIrnMj018185
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 10:53:49 -0800 (PST)
In-Reply-To: <1171607254637-git-send-email-maxk@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave, Alan, Jon,

Max Krasnyansky wrote:
> TIPC code is a bit inconsistent in masking out upper bits of various
> message fields when packing them into the headers. For the most part
> things seem to be ok but we happened to hit a corner case in our labs
> when broadcast counter reached certain value (don't remember exact
> details) and was messing up status bits in the header. At which point
> the link was busted and required a reset to bring it back up.
> It's much safer to apply proper mask in the function that does the
> actual packing rather than doing it all over the place, and missing a
> few ;-).
> 
> Signed-off-by: Max Krasnyansky <maxk@qualcomm.com>
> ---
>  net/tipc/msg.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/tipc/msg.h b/net/tipc/msg.h
> index 6699aaf..4e681c8 100644
> --- a/net/tipc/msg.h
> +++ b/net/tipc/msg.h
> @@ -72,7 +72,7 @@ static inline void msg_set_bits(struct tipc_msg *m, u32 w,
>  				u32 pos, u32 mask, u32 val)
>  {
>  	u32 word = msg_word(m,w) & ~(mask << pos);
> -	msg_set_word(m, w, (word |= (val << pos)));
> +	msg_set_word(m, w, (word |= ((val & mask) << pos)));
>  }
>  
>  /* 

Just making sure that this does not get lost in the blizzard of other patches :).
Please apply.

Thanx
Max


