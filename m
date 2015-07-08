From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: gen_estimator: extend pps limit
Date: Wed, 08 Jul 2015 13:59:56 -0700 (PDT)
Message-ID: <20150708.135956.157230596810615593.davem@davemloft.net>
References: <1435845439.11970.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@plumgrid.com, jhs@mojatatu.com,
	john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37400 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbbGHU75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 16:59:57 -0400
In-Reply-To: <1435845439.11970.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Jul 2015 15:57:19 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> rate estimators are limited to 4 Mpps, which was fine years ago, but
> too small with current hardware generation.
> 
> Lets use 2^5 scaling instead of 2^10 to get 128 Mpps new limit.
> 
> On 64bit arch, use an "unsigned long" for temp storage and remove limit.
> (We do not expect 32bit arches to be able to reach this point)
> 
> Tested:
> 
> tc -s -d filter sh dev eth0 parent ffff:
> 
> filter protocol ip pref 1 u32 
> filter protocol ip pref 1 u32 fh 800: ht divisor 1 
> filter protocol ip pref 1 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:15 
>   match 07000000/ff000000 at 12
> 	action order 1: gact action drop
> 	 random type none pass val 0
> 	 index 1 ref 1 bind 1 installed 166 sec
>  	Action statistics:
> 	Sent 39734251496 bytes 863788076 pkt (dropped 863788117, overlimits 0 requeues 0) 
> 	rate 4067Mbit 11053596pps backlog 0b 0p requeues 0 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
