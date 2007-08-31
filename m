From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Thu, 30 Aug 2007 18:07:13 -0700
Message-ID: <46D769C1.8090808@hp.com>
References: <200708310009.RAA04175@tardy.cup.hp.com> <20070830.173912.79067694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:39639 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753656AbXHaBHb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Aug 2007 21:07:31 -0400
In-Reply-To: <20070830.173912.79067694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 30 Aug 2007 17:09:04 -0700 (PDT)
> 
> 
>>Enable configuration of the minimum TCP Retransmission Timeout via
>>a new sysctl "tcp_rto_min" to help those who's networks (eg cellular)
>>have quite variable RTTs avoid spurrious RTOs.
>>
>>Signed-off-by: Rick Jones <rick.jones2@hp.com>
>>Signed-off-by: Lamont Jones <lamont@hp.com>
> 
> 
> Thanks for doing this work Rick.
> 
> But as John Heffner and I both mentioned, it's pretty clear we should
> do this as a routing metric.  Both for handling realistic scenerios
> where the sysctl doesn't work, and to help prevent misuse (example:
> someone decides that it would be _totally_ _awesome_ for "Carrier
> Grade Linux" to set this to 3 seconds by default in /etc/sysctl.conf
> and crap like that).

If nothing else it was worth the practice :)  I'll be happy with either 
mechanism, just wasn't sure if the jury was still out on whether making 
it a routing metric was really necessary.  I can see where it would be 
goodness if one had separate paths out of a system, one with the highly 
variable RTT and one with non-trivial loss rates, just that thusfar I've 
not come across any :)  I've only seen one path with high RTT 
variability and the other path with trivial loss rates.

Also, not surprisingly, the folks for whom I'm doing this are a triffle 
"anxious" so I figured that simplicity was worthwhile.  Particularly if 
it was going to be the case those folks were going to be asking for 
back-ports.

Anyhow, I'll try grubbing around the source code (already doing that to 
see about writing a pet tcp cong module) but if pointers to the likely 
relevant files were available I could try to help thrash-out the routing 
metric version.  Like I said the consumers of this are a triffle well, 
"anxious" :)

rick
