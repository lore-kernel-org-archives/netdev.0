From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Add compat ioctl support for the ipv4 multicast
 ioctl SIOCGETSGCNT
Date: Sun, 30 Jan 2011 01:14:58 -0800 (PST)
Message-ID: <20110130.011458.183048917.davem@davemloft.net>
References: <m18vy3uof7.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, kaber@trash.net
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37250
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751776Ab1A3JOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jan 2011 04:14:23 -0500
In-Reply-To: <m18vy3uof7.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 29 Jan 2011 18:15:56 -0800

> 
> SIOCGETSGCNT is not a unique ioctl value as it it maps tio SIOCPROTOPRIVATE +1,
> which unfortunately means the existing infrastructure for compat networking
> ioctls is insufficient.  A trivial compact ioctl implementation would conflict
> with:
> 
> SIOCAX25ADDUID
> SIOCAIPXPRISLT
> SIOCGETSGCNT_IN6
> SIOCGETSGCNT
> SIOCRSSCAUSE
> SIOCX25SSUBSCRIP
> SIOCX25SDTEFACILITIES
> 
> To make this work I have updated the compat_ioctl decode path to mirror the
> the normal ioctl decode path.  I have added an ipv4 inet_compat_ioctl function
> so that I can have ipv4 specific compat ioctls.   I have added a compat_ioctl
> function into struct proto so I can break out ioctls by which kind of ip socket
> I am using.  I have added a compat_raw_ioctl function because SIOCGETSGCNT only
> works on raw sockets.  I have added a ipmr_compat_ioctl that mirrors the normal
> ipmr_ioctl.
> 
> This was necessary because unfortunately the struct layout for the SIOCGETSGCNT
> has unsigned longs in it so changes between 32bit and 64bit kernels.
> 
> This change was sufficient to run a 32bit ip multicast routing daemon on a
> 64bit kernel.
> 
> Reported-by: Bill Fenner <fenner@aristanetworks.com>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Thanks a lot for doing this work Eric, applied to net-2.6.
