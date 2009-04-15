From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] Multicast: Avoid useless duplication of multicast
 messages
Date: Wed, 15 Apr 2009 15:21:27 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904151517540.18317@qirst.com>
References: <20090414204445.GB17196@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904141740280.3973@qirst.com> <20090415110714.GA21448@hmsreliant.think-freely.org> <alpine.DEB.1.10.0904150841550.10217@qirst.com> <20090415142208.GB21448@hmsreliant.think-freely.org>
 <49E5F1FF.1000801@hp.com> <20090415155702.GC21448@hmsreliant.think-freely.org> <49E6063B.3040107@hp.com> <20090415163812.GD21448@hmsreliant.think-freely.org> <49E6172D.8080201@hp.com> <20090415175329.GE21448@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	David Stevens <dlstevens@us.ibm.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:33084 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbZDOT22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 15:28:28 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6EDC182C24C
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:38:15 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id wfZV43G--dsv for <netdev@vger.kernel.org>;
	Wed, 15 Apr 2009 15:38:15 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 58A1082C24E
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2009 15:38:03 -0400 (EDT)
In-Reply-To: <20090415175329.GE21448@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Apr 2009, Neil Horman wrote:

> I can easily envision on application which expects to get multicast traffic that
> doesn't join a group within the context of its own process, specifically relying
> on the behavior as its documented today.  Consider a data processing
> application whos group management is segmented into a different utility.  This
> is really the problem here though isn't it?  A proposal to change the 20 year
> old behavior of multicast reception with no way to know how strongly
> applications rely on this behavior and no documentation to support the assertion
> that the current behavior is broken.

The "utility" must be a daemon that keeps the socket open. You are
talking about a sheperding process that first opens a socket and
then performs multicast groups. It then keeps the socket open
(otherwise would be unsubscribed) and starts other processes that then
open their own sockets and expect the subscriptions to work.

That does not look convincing. Can you cite a case of an
application actually depending on this behavior?

> I'll refer you again to this exact conversation months ago, when I was on the
> opposite end of this, and shown to be wrong:
> http://kerneltrap.org/mailarchive/linux-netdev/2008/7/11/2430904

Just you backing down does not mean that this is wrong. We have many
more factiods here now.

