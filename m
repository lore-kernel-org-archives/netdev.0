From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] infiniband: use %p6 for printing message ids
Date: Tue, 28 Oct 2008 16:22:08 -0700
Message-ID: <1225236128.5269.240.camel@localhost>
References: <1225229901.11483.58.camel@brick>
	 <1225234963.5269.228.camel@localhost>  <ada8ws8mi8x.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3270 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337AbYJ1XWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 19:22:18 -0400
In-Reply-To: <ada8ws8mi8x.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-28 at 16:07 -0700, Roland Dreier wrote:
> > I'm not sure any of these should be converted like this.
>  > Infiniband gids are not IPv6 addresses.
> 
> Actually, they are.  The IB specification section 4.1 says:
> 
>  "A GID is a valid 128-bit IPv6 address (per RFC 2373) with additional
>   properties / restrictions defined...."
> 
> and it makes sense to format an IB GID as an IPv6 address for display
> (that's what the IB spec does; eg it mentions the "Multicast GID
> FF02:0:0:0:0:0:0:1").

Perhaps the union in ib_verbs

union ib_gid {
	u8	raw[16];
	struct {
		__be64	subnet_prefix;
		__be64	interface_id;
	} global;
};

could/should include a struct in6_addr?


