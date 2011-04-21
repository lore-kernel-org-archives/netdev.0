From: Patrick McHardy <kaber@trash.net>
Subject: Re: ipqueue allocation failure.
Date: Thu, 21 Apr 2011 17:13:57 +0200
Message-ID: <4DB049B5.4070705@trash.net>
References: <20110420014221.GC26949@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47775 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754448Ab1DUPOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 11:14:01 -0400
In-Reply-To: <20110420014221.GC26949@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.04.2011 03:42, schrieb Dave Jones:
> Not catastrophic, but ipqueue seems to be too trusting of what it gets
> passed from userspace, and passes it on down to the page allocator,
> where it will spew warnings if the page order is too high.
> 
> __ipq_rcv_skb has several checks for lengths too small, but doesn't
> seem to have any for oversized ones.   I'm not sure what the maximum
> we should check for is. I'll code up a diff if anyone has any ideas
> on a sane maximum.

A sane maximum seems to be 2^16 - 1, the maximum size of an IPv4 packet.
Please also update ip6queue and nfnetlink_queue.
