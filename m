From: Patrick McHardy <kaber@trash.net>
Subject: Re: Refactor Netlink connector?
Date: Sat, 27 May 2006 01:06:55 +0200
Message-ID: <44778A0F.1030800@trash.net>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39092 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750962AbWEZXG6
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 19:06:58 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605261552570.4856@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> I've been looking through the kernel for new subsytems which might need 
> LSM hooks, and we've got a proliferation of Netlink abstractions: generic 
> Netlink, nfnetlink, connector and kobject_uevent.
> 
> I think we should look at consolidating some of these schemes, and if 
> possible, into a unififed Netlink API.
> 
> As a first step, what would it take to adapt the single user of 
> connector (the w1 driver) to use generic Netlink?
> 
> I suspect that some of the nfnetlink infrastructure can be used more 
> generically, and that a simple API for the common case of kernel->user 
> event notifications could be also be provided.
> 
> Thoughts?


No great thoughts at this point, but I agree 100%. In my
opinion netlink subsystems should be usable in a uniform way
(at least netlink specific parts like dump/query/set, ACKs,
attribute encoding and similar low-level stuff) without
implementation specific details. I guess from a SELinux point
of view having a single spot to place hooks with well defined
semantics is what counts, but it comes down to the same, there
is too much diversion among netlink users. I'll look into the
nfnetlink bits for a start, but I fear because of use of
network byteorder in lots of places it will not be able to
fully convert to generic netlink.

