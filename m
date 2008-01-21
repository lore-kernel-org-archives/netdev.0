From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/4] dsmark: get rid of trivial function
Date: Mon, 21 Jan 2008 01:16:32 +0100
Message-ID: <4793E460.5020804@trash.net>
References: <20080120130542.16720b45@deepthought> <20080120132550.056370c0@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37504 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027AbYAUAQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 19:16:40 -0500
In-Reply-To: <20080120132550.056370c0@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Replace loop in dsmark_valid_indices with equivalent bit math.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> --- a/net/sched/sch_dsmark.c	2008-01-20 13:07:58.000000000 -0800
> +++ b/net/sched/sch_dsmark.c	2008-01-20 13:22:54.000000000 -0800
> @@ -45,13 +45,8 @@ struct dsmark_qdisc_data {
>  
>  static inline int dsmark_valid_indices(u16 indices)
>  {
> -	while (indices != 1) {
> -		if (indices & 1)
> -			return 0;
> -		indices >>= 1;
> -	}
> -
> -	return 1;
> +	/* Must have only one bit set */
> +	return (indices & (indices - 1)) == 0;


hweight seems easier to understand, it took me a bit
to realize that the comment matches the code :)
