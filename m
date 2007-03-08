From: David Miller <davem@davemloft.net>
Subject: Re: IPV6: make ipv6_getsockopt_sticky honor user's buffer size
Date: Thu, 08 Mar 2007 14:38:04 -0800 (PST)
Message-ID: <20070308.143804.21927824.davem@davemloft.net>
References: <20070308071048.GD10574@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35379
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030815AbXCHWiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 17:38:06 -0500
In-Reply-To: <20070308071048.GD10574@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Wright <chrisw@sous-sol.org>
Date: Wed, 7 Mar 2007 23:10:48 -0800

> Make sure not to copy_to_user more than user's buffer can handle (we
> already checked the min, just use it) in ipv6_getsockopt_sticky.  And
> while there, minor whitespace cleanup now that ipv6_getsockopt_sticky
> call can nicely fit on one line.
> 
> Signed-off-by: Chris Wright <chrisw@sous-sol.org>

I wonder about this :-)

This gives the user now way to figure out that ipv6_optlen(hdr) is
larger than the len they supplied.

In other situations usually we validate the length and return -EINVAL
if it is too small.

That might be the thing to do in this case too.
