From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Thu, 29 Jun 2006 17:12:15 -0700 (PDT)
Message-ID: <20060629.171215.112621072.davem@davemloft.net>
References: <20060629233933.GB14627@postel.suug.ch>
	<20060629.164732.41636454.davem@davemloft.net>
	<1151626099.8922.64.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60085
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S933158AbWF3AMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 20:12:18 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151626099.8922.64.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Thu, 29 Jun 2006 20:08:19 -0400

> What am i missing?
> on 64bit machine, does it not save 32 bits to use an ifindex as opposed
> to the pointer?

The objects around it are pointers, which are 64-bit, and thus
the 32-bit object gets padded out to 64-bits in the layout of
the struct so that the next pointer member can be properly
aligned.

It does not change the size of sk_buff at all.

> Yes, it is a bug, but:
> dev_hold/put dont work anymore? why do you need an ifindex instead?

You sure you want to do that atomic operation on every single
input packet, regardless of whether egresss operations are
using it or not?

We should put the cost of features at the actual users, and not
impose it upon everyone.

