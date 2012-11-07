From: Rob Herring <rob.herring@calxeda.com>
Subject: Re: [PATCH v3 5/6] net: calxedaxgmac: rework transmit ring handling
Date: Tue, 06 Nov 2012 18:29:11 -0600
Message-ID: <5099AB57.7000805@calxeda.com>
References: <1352132544-15809-1-git-send-email-robherring2@gmail.com> <1352132544-15809-6-git-send-email-robherring2@gmail.com> <20121106.185704.1212469675670236955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp171.dfw.emailsrvr.com ([67.192.241.171]:39291 "EHLO
	smtp171.dfw.emailsrvr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab2KGA3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 19:29:13 -0500
In-Reply-To: <20121106.185704.1212469675670236955.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On 11/06/2012 05:57 PM, David Miller wrote:
> From: Rob Herring <robherring2@gmail.com>
> Date: Mon,  5 Nov 2012 10:22:23 -0600
> 
>> Only generate tx interrupts on every ring size / 4 descriptors.
> 
> I thought we told you that you cannot do this.
> 
> With this change if we get a few packets, then stop generating any
> traffic, there will be SKBs that just sit dead in your TX queue.

And as I previously mentioned, we do get a tx complete interrupt in
addition. The h/w will interrupt when all packets are transmitted and
there is not another descriptor ready. That is the only tx interrupt we
get without this patch. With this patch, we will get interrupts for
every N descriptors in addition to a tx complete/idle interrupt. This
patch is to avoid the transmitter from going idle and only refilling the
tx ring after finishing sending all frames. I can repost this patch and
make the commit message more clear, but I don't think there is any
functional change needed. This one is not so important compared to the
rest of the series, so you can just drop it if you still don't agree.

Rob

> 
> This cannot ever happen.  All TX SKBs must be freed up in a short,
> finite, amount of time.  Under all conditions, and in every situation.
> 
> Otherwise memory accounted to sockets is not liberated, and such
> sockets cannot be destroyed or closed.
> 
> SKBs also hold onto other kinds of resources, for which it is critical
> to liberate in a finite amount of time.
> 
> I'm not applying this series, it still needs more work.
> 
