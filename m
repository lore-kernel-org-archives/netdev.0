From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
 messages
Date: Tue, 14 Apr 2009 17:45:58 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904141740280.3973@qirst.com>
References: <alpine.DEB.1.10.0904131704120.3517@qirst.com> <20090414132551.GC14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904140946130.5712@qirst.com> <20090414182731.GD14305@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141447310.30596@qirst.com>
 <20090414204445.GB17196@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:56770 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756189AbZDNVw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 17:52:56 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0B7E782C389
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 18:02:38 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id HUERnfWtTS-a for <netdev@vger.kernel.org>;
	Tue, 14 Apr 2009 18:02:31 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E4E3D82C350
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 18:02:27 -0400 (EDT)
In-Reply-To: <20090414204445.GB17196@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Apr 2009, Neil Horman wrote:

> That said, I still disagree with the addition of this switch, as its
> superfolous.  Programatically an application can do what you want without this
> change already .If you provide me with the test application that you've been working with, I can
> demonstrate exactly how.

Ok. First applications listens to multicast groups A and B. Second one
uses C and D. All use a port 4711 for communication which is the
standard for a certain application. Both applications are very latency
sensitive. You do not want the data to be duplicated into the user space
of both processes.

Both processes need to reply to messages on the
multicast groups. The receiver always needs the source IP address for
authentication otherwise messages are ignored

How are you going to do this? Its trivial to do with this patch and one
socket in each process listening to port 4711 that subscribes to the
necessary multicast groups. Plus one the problem is that some of the
applications here are only available in binary form and they were naively
coded assuming that the socket layer would not need exotic tricks to
convince it to do the right thing.
