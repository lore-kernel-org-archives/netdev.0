From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 06:23:33 +0200
Message-ID: <1340079813.7491.2164.camel@edumazet-glaptop>
References: <20120618.194016.2282814982594761206.davem@davemloft.net>
	 <1340078846.7491.2127.camel@edumazet-glaptop>
	 <20120618.211539.105938285016510975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64240 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742Ab2FSEXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2012 00:23:38 -0400
Received: by eaak11 with SMTP id k11so1805905eaa.19
        for <netdev@vger.kernel.org>; Mon, 18 Jun 2012 21:23:37 -0700 (PDT)
In-Reply-To: <20120618.211539.105938285016510975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-18 at 21:15 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 19 Jun 2012 06:07:26 +0200
> 
> > On Mon, 2012-06-18 at 19:40 -0700, David Miller wrote:
> >> You know you want it.
> >> 
> >> Signed-off-by: David S. Miller <davem@davemloft.net>
> > 
> > Yeah, very good idea David ;)
> > 
> > needs some polishing of course.
> 
> Such as?  IPv6 support?
> 

I was referring to socket leak in :

+       if (sk) {
+               skb->sk = sk;
+               skb->destructor = sock_edemux;
+               if (sk->sk_state != TCP_TIME_WAIT) {
+                       struct dst_entry *dst = sk->sk_rx_dst;
+                       if (dst) {
+                               skb_dst_set_noref(skb, dst);
+                               err = 0;
+                       }
+               }
+       }
