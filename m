From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4 1/3] net: ipv6: Unduplicate {raw,udp}v6_sendmsg code
Date: Thu, 24 Apr 2014 17:00:19 +0200
Message-ID: <20140424150019.GE1960@order.stressinduktion.org>
References: <1398154415-24486-1-git-send-email-lorenzo@google.com> <1398235078-27088-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	davem@davemloft.net, eric.dumazet@gmail.com
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37011 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849AbaDXPAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 11:00:20 -0400
Content-Disposition: inline
In-Reply-To: <1398235078-27088-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 03:37:56PM +0900, Lorenzo Colitti wrote:
>  	if (msg->msg_flags&MSG_CONFIRM)
>  		goto do_confirm;
> @@ -1262,8 +1164,6 @@ back_from_confirm:
>  	up->pending = AF_INET6;
>  
>  do_append_data:
> -	if (dontfrag < 0)
> -		dontfrag = np->dontfrag;

I am afraid we could jump to do_append_data without having dontfrag
initialized. The jump happens before we call to ip6_datagram_send_common.

So the initialization of dontfrag to -1 needs to be added to the caller.

>  	up->len += ulen;
>  	getfrag  =  is_udplite ?  udplite_getfrag : ip_generic_getfrag;
>  	err = ip6_append_data(sk, getfrag, msg->msg_iov, ulen,
