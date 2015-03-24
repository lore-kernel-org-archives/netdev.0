From: Greg KH <greg@kroah.com>
Subject: Re: Responsible Disclosure
Date: Tue, 24 Mar 2015 20:55:17 +0100
Message-ID: <20150324195517.GB10851@kroah.com>
References: <1425861908.8414.12.camel@modio.se>
 <20150309054916.GA8575@kroah.com>
 <1427153139.14059.2.camel@takeit.se>
 <20150324184517.GA24177@kroah.com>
 <1427225461.3276.1.camel@takeit.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "security@kernel.org" <security@kernel.org>,
	security <security@android.com>, netdev@vger.kernel.org
To: ljungmark@modio.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:41263 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753574AbbCXTzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 15:55:19 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id A163520F3F
	for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:55:16 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <1427225461.3276.1.camel@takeit.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 08:31:01PM +0100, D. S. Ljungmark wrote:
> 
> This patch prevents a link-local DoS against ipv6. 
> 
> 
> To exploit, push an RA packet without any routing information, but with
> the hop limit reduced to 1.
> 
> //D.S. Ljungmark
> 
> 
> 
> 
> 
> 

> diff -urw linux-3.18.7-200.fc21.x86_64/net/ipv6/ndisc.c linux-3.18.7-200.fc21.x86_64/net/ipv6/ndisc.c
> --- linux-3.18.7-200.fc21.x86_64/net/ipv6/ndisc.c	2015-03-08 13:01:36.567000000 -0400
> +++ linux-3.18.7-200.fc21.x86_64/net/ipv6/ndisc.c	2015-03-08 12:50:55.446000000 -0400
> @@ -1215,7 +1215,15 @@
>  	if (rt)
>  		rt6_set_expires(rt, jiffies + (HZ * lifetime));
>  	if (ra_msg->icmph.icmp6_hop_limit) {
> +		/*
> +		 *	Only set hop_limit on the interface if it is higher than the current hop_limit.
> +		 *	Prevents silly routes with hop_limit 1 from affecting everyone.
> +		 */
> +		if (in6_dev->cnf.hop_limit < ra_msg->icmph.icmp6_hop_limit) {
>  		in6_dev->cnf.hop_limit = ra_msg->icmph.icmp6_hop_limit;
> +		} else {
> +			ND_PRINTK(2, warn, "RA: Got route advertisement with lower hop_limit than current\n");
> +		}
>  		if (rt)
>  			dst_metric_set(&rt->dst, RTAX_HOPLIMIT,
>  				       ra_msg->icmph.icmp6_hop_limit);


Please submit this in a form that can be applied.

Take a look at Documentation/SubmittingPatches for the proper format.

Also, you are messing with the coding style here for no reason (hint,
indent after the if, and wrap your lines properly.)

Can you fix that up, and resend, starting a new email thread, netdev
doesn't care about the prior subject, you need to pick a proper one for
the patch.

thanks,

greg k-h
