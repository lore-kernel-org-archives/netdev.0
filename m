From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 15:24:05 -0700 (PDT)
Message-ID: <20120718.152405.1083396282134539674.davem@davemloft.net>
References: <20120718.132840.1571938255177607234.davem@davemloft.net>
	<20120718214422.GA18207@electric-eye.fr.zoreil.com>
	<1342649136.2626.3757.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, hayeswang@realtek.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751822Ab2GRWYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 18:24:08 -0400
In-Reply-To: <1342649136.2626.3757.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 19 Jul 2012 00:05:36 +0200

> On Wed, 2012-07-18 at 23:44 +0200, Francois Romieu wrote:
>> David Miller <davem@davemloft.net> :
>> [...]
>> > A NETDEV_TX_OK return means we accepted the SKB, it doesn't look like
>> > that's what you are doing in the skb_padto() failure path.
>> 
>> ?
>> 
>> - skb_padto fails
>>   (original skb is implicitely freed)
>> - skb_padto returns error status (!= 0)
>> - rtl8169_tso_csum returns false
>> - start_xmit returns NETDEV_TX_OK. 
>> 
>> I'll search the missing "!" after some sleep if that's what you are talking
>> about. Otherwise than that, I don't get it.
>> 
> 
> 
> Yes, I believe your patch is fine.
> 
> In fact many drivers dont account the error in their stats.

My bad, I forgot that skb_padto() frees the SKB on failure.
