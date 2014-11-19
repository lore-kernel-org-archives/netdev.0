From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Wed, 19 Nov 2014 11:34:13 +0100
Message-ID: <20141119103413.GA19092@midget.suse.cz>
References: <20141117013448.GA26743@midget.suse.cz>
 <8698539.evYG7fs8jS@wuerfel>
 <20141118221057.GA13473@midget.suse.cz>
 <1609909.1jJeqOzgZ8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:51714 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753650AbaKSKeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 05:34:16 -0500
Content-Disposition: inline
In-Reply-To: <1609909.1jJeqOzgZ8@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 09:32:54AM +0100, Arnd Bergmann wrote:
> I'm more interested in the code structure, in particular this bit
> 
> @@ -1807,8 +1812,10 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
>  
>         rc = skb_copy_datagram_iovec(skb, sizeof(struct ipxhdr), msg->msg_iov,
>                                      copied);
> -       if (rc)
> -               goto out_free;
> +       if (rc) {
> +               skb_free_datagram(sk, skb);
> +               goto out;
> +       }
> 
> 
> after your change mixes coding styles: in some failure cases you just goto
> a cleanup part, in other cases you do the cleanup before the goto.
> 
> If I'm reading the patch correctly, this change has introduced a leak

Very lame of me - thanks so much for spotitng this!
Sending a restructured v3.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
