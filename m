From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Wed, 25 Aug 2010 20:53:02 -0700 (PDT)
Message-ID: <20100825.205302.241913926.davem@davemloft.net>
References: <1282758634.2487.576.camel@edumazet-laptop>
	<20100825.165759.27789477.davem@davemloft.net>
	<20100826003834.GA17882@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, miltonm@bga.com
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41491
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752828Ab0HZDwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 23:52:47 -0400
In-Reply-To: <20100826003834.GA17882@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Thu, 26 Aug 2010 10:38:34 +1000

> # cat /proc/sys/net/ipv4/tcp_max_syn_backlog 
> 128
> 
> We probably want to use max():
> 
>> -	sysctl_max_syn_backlog = min(128, cnt / 256);
>> +	sysctl_max_syn_backlog = max(128, cnt / 256);
> 
> With that change:
 ...
> Tested-by: Anton Blanchard <anton@samba.org>

Thanks a lot Anton.

Did you test my percpu orphan fix yet?
