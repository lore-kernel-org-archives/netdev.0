From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] sky2: safer transmit ring cleaning (v4)
Date: Thu, 14 Jan 2010 10:43:06 -0500
Message-ID: <4B4F3B8A.4050402@majjas.com>
References: <20100113194148.139091a3@nehalam>
 <20100114101445.GA7210@ff.dom.local> <20100114111636.GB7210@ff.dom.local>
 <20100114.032009.20669539.davem@davemloft.net>
 <20100114112653.GA8543@ff.dom.local> <4B4F19EB.5080207@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	flyboy@gmail.com, rjw@sisk.pl, netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta4.srv.hcvlny.cv.net ([167.206.4.199]:60999 "EHLO
	mta4.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683Ab0ANPnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 10:43:37 -0500
Received: from mail.majjas.com (ool-44c00dc8.dyn.optonline.net [68.192.13.200])
 by mta4.srv.hcvlny.cv.net
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 with ESMTP id <0KW800HYLUCN8RU0@mta4.srv.hcvlny.cv.net> for
 netdev@vger.kernel.org; Thu, 14 Jan 2010 10:43:36 -0500 (EST)
In-reply-to: <4B4F19EB.5080207@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/2010 8:19 AM, Mike McCormack wrote:
> Here's what was sitting in my tree...
> ...
>   err_out:
> @@ -1596,6 +1598,8 @@ static inline int tx_inuse(const struct sky2_port *sky2)
>   /* Number of list elements available for next tx */
>   static inline int tx_avail(const struct sky2_port *sky2)
>   {
> +	if (unlikely(!sky2->tx_ring))
> +		return 0;
>   	return sky2->tx_pending - tx_inuse(sky2);
>   }
>    
This hunk (patch) conflicts with the v4 patch Stephen sent out last 
night. He added an smp_mb in front of the return. I'm going to give this 
a go with the smb_mb before the unlikely test.


