From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.26] netlink: make socket filters work on netlink
Date: Wed, 02 Apr 2008 12:00:19 +0200
Message-ID: <47F35933.5080305@trash.net>
References: <47EAAFEC.6000805@trash.net>	<20080331123311.64e4ca37@extreme>	 <47F13E43.2040404@trash.net>	 <20080331.130757.199769025.davem@davemloft.net>	 <47F1467F.2080407@trash.net> <1207000143.4424.167.camel@localhost>	 <47F22211.5080100@trash.net> <1207058646.4424.218.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59915 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbYDBKAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 06:00:22 -0400
In-Reply-To: <1207058646.4424.218.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Tue, 2008-01-04 at 13:52 +0200, Patrick McHardy wrote:
> 
>> Isn't that what nlmsg_pid already contains?
> 
> would work only on the case of user<->user.
> On kernel->user it is supposed to be owned by the kernel and set to 0.


No, in the case of events its supposed to be set to the pid of the
socket that caused the event. Check out qdisc_notify() or rtmsg_ifa()
for example.

> OTOH, one could use the nlmsg seq as a "cookie" (since that is untouched
> by the kernel) with the hope that no other process will use that same
> cookie - then you can filter events based on the cookie. Note this is
> only useful if you can guarantee that all processes running on a system
> guarantee such uniqueness of such cookies amongst each other; which is
> typically a bad assumption for a generic solution but would work.


nlmsg_seq is already used by userspace to match responses to requests,
so that probably wouldn't work very well.
