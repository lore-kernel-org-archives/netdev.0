From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netlink: fix broadcasting to the wrong group.
Date: Tue, 18 Apr 2006 09:18:48 +0400
Message-ID: <20060418051846.GA833@2ka.mipt.ru>
References: <20060417093632.GA29057@2ka.mipt.ru> <4443B5A8.9010604@trash.net> <20060417194904.GA5237@2ka.mipt.ru> <4443F742.9020508@trash.net> <20060417202150.GA10764@2ka.mipt.ru> <4444211F.3030000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:60830 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932230AbWDRFS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 01:18:58 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4444211F.3030000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2006 at 01:13:35AM +0200, Patrick McHardy (kaber@trash.net) wrote:
> I went over your mails again, but I don't understand the problem you're
> seeing. Please just make a simple example showing the operation +
> the arguments you're using to bind to group 5 which would result in
> bit 0 beeing set or the kernel deciding to send to group 1 for some
> other reason.

Example:
at bind time group 5 was selected and then socket was subscribed to that
group. This end up in 0b10101 bitmask, which allows to multicast to
group 16 which has nothing in common with either group number 5 or
bitmask 5.

I think that if socket uses bitmask at bind time, then it should not be
allowed to subscribe.
So for above example at bind time (1<<4) should be used and this is what
happens with subscription. We discussed already that itmask
functionality was never used, and current behaviour introduces big
ambiguity.
Well, if you forces this to not be changed, I will update documentation
about this behaviour.

-- 
	Evgeniy Polyakov
