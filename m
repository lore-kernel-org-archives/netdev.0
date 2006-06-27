From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH Round 2 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 13:14:43 -0700 (PDT)
Message-ID: <20060627.131443.104035750.davem@davemloft.net>
References: <20060626203638.19083.71231.stgit@stevo-desktop>
	<20060627.030920.108743110.davem@davemloft.net>
	<1151420539.3207.29.camel@stevo-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:35791
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161267AbWF0UOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:14:44 -0400
To: swise@opengridcomputing.com
In-Reply-To: <1151420539.3207.29.camel@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steve Wise <swise@opengridcomputing.com>
Date: Tue, 27 Jun 2006 10:02:19 -0500

> For the RDMA kernel subsystem, however, we still need a specific event.
> We need both the old and new dst_entry struct ptrs to figure out which
> active connections were using the old dst_entry and should be updated to
> use the new dst_entry.

This change isn't truly atomic from a kernel standpoint either.

The new dst won't be selected by the socket until later,
when the socket tries to send something, notices the old dst
is obsolete, and looks up a new one.

Your code could do the same thing.
