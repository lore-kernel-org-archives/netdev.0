From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Tue, 18 Apr 2006 09:53:51 +0400
Message-ID: <20060418055351.GB833@2ka.mipt.ru>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru> <4443F742.9020508@trash.net> <20060417202150.GA10764@2ka.mipt.ru> <4444211F.3030000@trash.net> <20060418051846.GA833@2ka.mipt.ru> <44447AF4.5060907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59587 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751396AbWDRFyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 01:54:05 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44447AF4.5060907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2006 at 07:36:52AM +0200, Patrick McHardy (kaber@trash.net) wrote:
> Again, bind() takes a bitmask of the groups to subscribe to, not the
> numerical value 5. To subscribe to group 5 using bind, you use 1<<(5-1)
> as nladdr, which is 0x10000. Check out the difference between
> RTMGRP_NOTIFY (backwards compatibility for bind()) and RTNLGRP_NOTIFY
> (used internally and for NETLINK_ADD_MEMBERSHIP).

I.e. bind nladdr is an optimisation for several calls of
NETLINK_ADD_MEMBERSHIP, as long as socket setup in netlink table?
And thus bind(5) is equal to subscribe(1); subscribe(3).

-- 
	Evgeniy Polyakov
