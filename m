From: David Miller <davem@davemloft.net>
Subject: Re: ipqueue allocation failure.
Date: Tue, 19 Apr 2011 20:41:05 -0700 (PDT)
Message-ID: <20110419.204105.68144653.davem@davemloft.net>
References: <20110420014221.GC26949@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33360
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751111Ab1DTDlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 23:41:40 -0400
In-Reply-To: <20110420014221.GC26949@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Tue, 19 Apr 2011 21:42:22 -0400

> Not catastrophic, but ipqueue seems to be too trusting of what it gets
> passed from userspace, and passes it on down to the page allocator,
> where it will spew warnings if the page order is too high.
> 
> __ipq_rcv_skb has several checks for lengths too small, but doesn't
> seem to have any for oversized ones.   I'm not sure what the maximum
> we should check for is. I'll code up a diff if anyone has any ideas
> on a sane maximum.

Maybe the thing to do is to simply pass __GFP_NOWARN to nlmsg_new()
in netlink_ack()?

Anyone else have a better idea?
