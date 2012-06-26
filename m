From: David McCullough <david_mccullough@mcafee.com>
Subject: Re: [PATCH] net/ipv6/route.c: packets originating on device match
 lo
Date: Tue, 26 Jun 2012 11:38:31 +1000
Message-ID: <20120626013831.GA3455@mcafee.com>
References: <20120625065030.GA28914@mcafee.com>
 <20120625.162832.804773711822642700.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dalsmrelay2.nai.com ([205.227.136.216]:25791 "EHLO
	dalsmrelay2.nai.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757862Ab2FZBio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 21:38:44 -0400
Content-Disposition: inline
In-Reply-To: <20120625.162832.804773711822642700.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Jivin David Miller lays it down ...
> From: David McCullough <david_mccullough@mcafee.com>
> Date: Mon, 25 Jun 2012 16:50:30 +1000
> 
> > @@ -931,6 +931,9 @@ struct dst_entry * ip6_route_output(stru
> >  {
> >  	int flags = 0;
> >  
> > +	if (fl6->flowi6_iif == 0)
> > +		fl6->flowi6_iif = net->loopback_dev->ifindex;
> > +		
> 
> Like ipv4, you should make this assignment unconditionally.

No problems, will resend,  I wasn't so sure that I could do that safely
with the flowi getting passed into IPv6 rather than created as it is in
IPv4.  Did some extra testing,  looks good so patch to follow,

Thanks,
Davidm

-- 
David McCullough,      david_mccullough@mcafee.com,  Ph:+61 734352815
McAfee - SnapGear      http://www.mcafee.com         http://www.uCdot.org
