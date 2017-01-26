From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ip_rcv_finish() NULL pointer kernel panic
Date: Thu, 26 Jan 2017 07:57:59 -0800
Message-ID: <1485446279.5145.141.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.02.1701260627510.24491@maul.oc9.org>
         <alpine.LNX.2.02.1701260927040.24491@maul.oc9.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Roy Keene <lkml@rkeene.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34299 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752449AbdAZQFl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 11:05:41 -0500
In-Reply-To: <alpine.LNX.2.02.1701260927040.24491@maul.oc9.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-01-26 at 09:32 -0600, Roy Keene wrote:
> This bug appears to have existed for a long time:
> 
>  	https://www.spinics.net/lists/netdev/msg222459.html
> 
>  	http://www.kernelhub.org/?p=2&msg=823752
> 
> Though possibly with different things not setting the "input" function 
> pointer in the "struct dst_entry".
> 
> include/net/dst.h:
>   496 static inline int dst_input(struct sk_buff *skb) {
>   498         return skb_dst(skb)->input(skb);
>   499 }
> 
> Is there any reason not to check to see if this pointer is NULL before 
> blindly calling it ?

Sure. It can not be NULL at this point.

Just look at the code in ip_rcv_finish() :

It first make sure to get a valid dst.

Something is broken, probably in bridge netfilter code.

I suspect the dst here points to &br->fake_rtable, and this is not
expected.

br_drop_fake_rtable() should have been called somewhere ...
