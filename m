From: Brian Haley <brian.haley@hp.com>
Subject: Re: sock_ioctl sleeping while atomic warning during boot.
Date: Thu, 20 Dec 2012 22:31:03 -0500
Message-ID: <50D3D7F7.2030200@hp.com>
References: <20121221022409.GA1927@redhat.com> <1356060308.21834.4455.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:27611 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516Ab2LUDbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 22:31:09 -0500
In-Reply-To: <1356060308.21834.4455.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2012 10:25 PM, Eric Dumazet wrote:
> OK, thanks for the report.
> 
> We need a seqcount, not a seqlock, as RTNL already protects multiple
> writers.
> 
> Please try following fix :
> 
> 
> [PATCH] net: devnet_rename_seq should be a seqcount
> 
> Using a seqlock for devnet_rename_seq is not a good idea,
> as device_rename() can sleep.
> 
> As we hold RTNL, we dont need a protection for writers,
> and only need a seqcount so that readers can catch a change done
> by a writer.
> 
> Bug added in commit c91f6df2db4972d3 (sockopt: Change getsockopt() of
> SO_BINDTODEVICE to return an interface name)
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Brian Haley <brian.haley@hp.com>

Sorry about that, thanks for the quick fix Eric.

-Brian
