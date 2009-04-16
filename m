From: Christoph Lameter <cl@linux.com>
Subject: Re: PATCH: Multicast: Filter multicast traffic per socket mc_list
Date: Thu, 16 Apr 2009 11:39:30 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904161137080.15629@qirst.com>
References: <alpine.DEB.1.10.0904161035390.19650@qirst.com> <49E74DAD.4020507@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nhorman@tuxdriver.com, dlstevens@us.ibm.com
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:57599 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754094AbZDPPqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 11:46:53 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 99DCB82C2B1
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:56:45 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7TW95uOcB0tw for <netdev@vger.kernel.org>;
	Thu, 16 Apr 2009 11:56:45 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AA4A582C183
	for <netdev@vger.kernel.org>; Thu, 16 Apr 2009 11:56:24 -0400 (EDT)
In-Reply-To: <49E74DAD.4020507@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, Vlad Yasevich wrote:

> > -	if (!ipv4_is_multicast(loc_addr))
> > +	if (ipv4_is_lbcast(loc_addr) || !ipv4_is_multicast(loc_addr))
> >  		return 1;
>
> I don't think this change is needed.  ipv4_is_lbcast() checks if the
> address is 255.255.255.255.  That address is already !ipv4_is_multicast().
>
> Subnet broadcasts are also !ipv4_is_multicast.

ok will drop this.

> >  	{
> >  		struct msghdr msg;
>
> You might need to set inet->mc_all to 1 in inet_create() since I am not sure if
> we want to change the default behavior.  The knowledge that some apps have
> a very "unique" way of doing multicast makes me a little hesitant.

Those "unique" applications would only be able to run on Linux.
Application mostly are written for multiple Unix variants. Since the
other Unix variants have changed their default behavior it is reasonable
to also change the default under Linux.

