From: Christoph Lameter <cl@linux.com>
Subject: Re: Kernel sends multicast groups to sockets that did not subscribe
 to the MC group
Date: Tue, 14 Apr 2009 09:53:50 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904140946130.5712@qirst.com>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:41182 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbZDNOBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 10:01:53 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0888882C0CF
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 10:11:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mRwo73VRFF5j for <netdev@vger.kernel.org>;
	Tue, 14 Apr 2009 10:11:26 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3C51482C3CD
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 10:10:14 -0400 (EDT)
In-Reply-To: <20090414132551.GC14305@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Apr 2009, Neil Horman wrote:

> > If I send a multicast message to 239.0.0.50 then both receive it. Why is
> > the process listening to 239.0.0.51 receiving the multicast message send
> > to 239.0.0.50?
> Its correct behavior.  I had the same misunderstanding a few months back, but
> Dave stevens set me right:
> http://kerneltrap.org/index.php?q=mailarchive/linux-netdev/2008/7/11/2430904

Well its traditional behavior. The join operation occurs on a socket so
it is surprising that this means I join all multicast groups on an
interface. The reason given is that all unixes since BSD were as
braindead. Still crappy behavior since multiple applications that
subscribe to different groups but listen on the same port will get all
traffic of the other apps delivered to them.
Its trivial to fix as your patch shows since we already have per socket mc
lists required to support IGMPv3.

Maybe we can get this merged by adding a mc configuration variable
that switches between interface and socket based multicast subscriptions.

/proc/sys/net/mc_socket_based_join

Defaults to 0 and can be set to 1 to get sane behavior?
