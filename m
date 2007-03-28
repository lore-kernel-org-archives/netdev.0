From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET: Add TCP connection abort IOCTL
Date: Tue, 27 Mar 2007 23:35:49 -0700 (PDT)
Message-ID: <20070327.233549.30185448.davem@davemloft.net>
References: <4609A42A.4040304@mvista.com>
	<20070327.163620.54190045.davem@davemloft.net>
	<460A04ED.5050203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhuth@mvista.com, dagriego@gmail.com, davem@davemloft.ne,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43966
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751322AbXC1Gft (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 02:35:49 -0400
In-Reply-To: <460A04ED.5050203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 28 Mar 2007 08:02:21 +0200

> This is what I thought too at the begining.
> 
> But after some thinking I recalled having to reboot machines just because 
> netfilter was not in (because of noticeable performance hit), and I could find 
>   the tree to compile netfilter as modules..
> 
> When I saw revoke() work in progess, I did react like you : This is coming 
> from hell...

Another option, similar in vain to what Herbert suggested (the gdb
hack) is to provide a way for root to open file descriptors of other
processes and handle it like that.

Then you could just set the linger socket option properly and close it
up.

Unfortunately we prevent openning of /proc/${PID}/fd/${FD} objects
when they are sockets for well documented reasons.

Using an ioctl with a socket demux key is just beyond disgusting, it's
as simple as that.  We have abstractions already for these objects so
let's use them.
