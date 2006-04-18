From: Patrick McHardy <kaber@trash.net>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Tue, 18 Apr 2006 07:36:52 +0200
Message-ID: <44447AF4.5060907@trash.net>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru> <4443F742.9020508@trash.net> <20060417202150.GA10764@2ka.mipt.ru> <4444211F.3030000@trash.net> <20060418051846.GA833@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:11002 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932232AbWDRFgy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 01:36:54 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060418051846.GA833@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Apr 18, 2006 at 01:13:35AM +0200, Patrick McHardy (kaber@trash.net) wrote:
> 
>>I went over your mails again, but I don't understand the problem you're
>>seeing. Please just make a simple example showing the operation +
>>the arguments you're using to bind to group 5 which would result in
>>bit 0 beeing set or the kernel deciding to send to group 1 for some
>>other reason.
> 
> 
> Example:
> at bind time group 5 was selected and then socket was subscribed to that
> group. This end up in 0b10101 bitmask, which allows to multicast to
> group 16 which has nothing in common with either group number 5 or
> bitmask 5.

Again, bind() takes a bitmask of the groups to subscribe to, not the
numerical value 5. To subscribe to group 5 using bind, you use 1<<(5-1)
as nladdr, which is 0x10000. Check out the difference between
RTMGRP_NOTIFY (backwards compatibility for bind()) and RTNLGRP_NOTIFY
(used internally and for NETLINK_ADD_MEMBERSHIP).

> I think that if socket uses bitmask at bind time, then it should not be
> allowed to subscribe.
> So for above example at bind time (1<<4) should be used and this is what
> happens with subscription. We discussed already that itmask
> functionality was never used, and current behaviour introduces big
> ambiguity.
> Well, if you forces this to not be changed, I will update documentation
> about this behaviour.

See above. Does this clear things up?

