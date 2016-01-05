From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] skbuff: Fix skb checksum flag on skb pull
Date: Mon, 04 Jan 2016 23:08:04 -0500 (EST)
Message-ID: <20160104.230804.2220774053197810472.davem@davemloft.net>
References: <1442951873-4803-1-git-send-email-pshelar@nicira.com>
	<20150924.140931.1967362456389755405.davem@davemloft.net>
	<1451498745.8255.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, netdev@vger.kernel.org,
	willemdebruijn.kernel@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51442 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbcAEEIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 23:08:07 -0500
In-Reply-To: <1451498745.8255.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 13:05:45 -0500

> On Thu, 2015-09-24 at 14:09 -0700, David Miller wrote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Tue, 22 Sep 2015 12:57:53 -0700
>> 
>> > VXLAN device can receive skb with checksum partial. But the checksum
>> > offset could be in outer header which is pulled on receive. This results
>> > in negative checksum offset for the skb. Such skb can cause the assert
>> > failure in skb_checksum_help(). Following patch fixes the bug by setting
>> > checksum-none while pulling outer header.
>> > 
>> > Following is the kernel panic msg from old kernel hitting the bug.
>>  ...
>> > Reported-by: Anupam Chanda <achanda@vmware.com>
>> > Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>> 
>> Applied, thanks.
> 
> 
> It looks like we also should clear skb->csum ?
> 
> __skb_checksum_complete() definitely would be confused by garbage in
> skb->csum

Pravin, please take a look at this.
