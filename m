From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Fri, 02 Jan 2009 13:34:35 -0800 (PST)
Message-ID: <20090102.133435.105577950.davem@davemloft.net>
References: <20081231171016.GA1901@flint.arm.linux.org.uk>
	<Pine.LNX.4.64.0812312215590.3247@wrl-59.cs.helsinki.fi>
	<20090102142608.GC26093@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org,
	bhutchings@solarflare.com
To: rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36032
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756943AbZABVec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 16:34:32 -0500
In-Reply-To: <20090102142608.GC26093@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk@arm.linux.org.uk>
Date: Fri, 2 Jan 2009 14:26:09 +0000

> Remote end sequence number is still at 1190.
> 
> 19:47:32.285397 IP (tos 0x0, ttl  64, id 30055, offset 0, flags [DF], proto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701
> 19:47:32.320287 IP (tos 0x0, ttl 238, id 10, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701
> 19:47:32.320300 IP (tos 0x0, ttl  64, id 30056, offset 0, flags [DF], proto: TCP (6), length: 40) dyn-67.arm.linux.org.uk.38803 > 193.108.74.209.http: ., cksum 0x41e5 (correct), 3216:3216(0) ack 2215 win 10701
> 19:47:32.353016 IP (tos 0x0, ttl 238, id 12, offset 0, flags [none], proto: TCP (6), length: 40) 193.108.74.209.http > dyn-67.arm.linux.org.uk.38803: ., cksum 0x45e6 (correct), 1190:1190(0) ack 3216 win 10701
> ...
> 
> So it looks to me like the remote end doesn't like our ack of 2215 for
> some reason.

Let's make sure the checksum is OK.  That's a reason the ACK might
get dropped at the remote end.

