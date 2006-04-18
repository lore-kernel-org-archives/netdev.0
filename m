From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Tue, 18 Apr 2006 08:00:25 +0200
Message-ID: <44448079.6030305@trash.net>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru> <4443F742.9020508@trash.net> <20060417202150.GA10764@2ka.mipt.ru> <4444211F.3030000@trash.net> <20060418051846.GA833@2ka.mipt.ru> <44447AF4.5060907@trash.net> <20060418055351.GB833@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56571 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932239AbWDRGAc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 02:00:32 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060418055351.GB833@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Apr 18, 2006 at 07:36:52AM +0200, Patrick McHardy (kaber@trash.net) wrote:
> 
>>Again, bind() takes a bitmask of the groups to subscribe to, not the
>>numerical value 5. To subscribe to group 5 using bind, you use 1<<(5-1)
>>as nladdr, which is 0x10000. Check out the difference between
>>RTMGRP_NOTIFY (backwards compatibility for bind()) and RTNLGRP_NOTIFY
>>(used internally and for NETLINK_ADD_MEMBERSHIP).
> 
> 
> I.e. bind nladdr is an optimisation for several calls of
> NETLINK_ADD_MEMBERSHIP, as long as socket setup in netlink table?

No, its not an optimization, its there for backwards compatibility.
Otherwise the cleanest solution would have been to remove group
subscription from bind().

> And thus bind(5) is equal to subscribe(1); subscribe(3).

Yes, except that it will also unsubscribe from all other groups <= 32.

Easiest way to avoid problems is to first call bind() with a group mask
of 0, then use setsockopt() to subscribe to groups.
