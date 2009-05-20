From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Question about /proc/net/netlink mystery
Date: Wed, 20 May 2009 15:44:08 -0400
Message-ID: <20090520194408.GA8062@hmsreliant.think-freely.org>
References: <eb3ff54b0905201222t6ecc241bq2168538742b48deb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rami Rosen <ramirose@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48074 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508AbZETToQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2009 15:44:16 -0400
Content-Disposition: inline
In-Reply-To: <eb3ff54b0905201222t6ecc241bq2168538742b48deb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 20, 2009 at 10:22:46PM +0300, Rami Rosen wrote:
> Hi,
> I tried to figure this out, but something is mysterious here to me.
> 
>  cat /proc/net/netlink
> shows:
> sk       Eth Pid    Groups   Rmem     Wmem     Dump     Locks
> 
> Why is the Eth here in the second column title?
> It does not seem that this column has anything to do with network
> interfaces.
> 
> A short look to the code, in netlink_seq_show() , net/netlink/af_netlink.c,
> will show that the values in this column are s->sk_protocol.
> 
> So it seems that the title should be here different; it should represent
> the protocol (since s->sk_protocol is assigned
> the number of the protocol of the netlink socket ;
> for example, NETLINK_ROUTE is 0, NETLINK_AUDIT is 9, and so on ; (see
> include/linux/netfilter.h)
> 
> So shouldn't it be something like "Proto"?
> 
Someone might have been mistakenly thinking [Eth]ertype for that field, but
regardless, it seems wrong.  Honestly, The colum should likely be proto, but who
knows what apps parsing you break if you make that change now.

Neil

> Regards,
> Rami Rosen
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
