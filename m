From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/8] flow_keys: Record IP layer protocol in
 skb_flow_dissect()
Date: Wed, 11 Jun 2014 15:08:23 -0700 (PDT)
Message-ID: <20140611.150823.2146273068682655735.davem@davemloft.net>
References: <alpine.LNX.2.03.1406101923050.2499@ws.cisco>
	<1402410390.3645.429.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140611.150636.857251759787443666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: _govind@gmx.com, dborkman@redhat.com, netdev@vger.kernel.org,
	ssujith@cisco.com, gvaradar@cisco.com, benve@cisco.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbaFKWIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:08:24 -0400
In-Reply-To: <20140611.150636.857251759787443666.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 11 Jun 2014 15:06:36 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 10 Jun 2014 07:26:30 -0700
> 
>> On Tue, 2014-06-10 at 19:38 +0530, Govindarajulu Varadarajan wrote:
>>> 
>> 
>>> determining IPv4/IPv6 is important because this can be used in dissecting flow
>>> in Accelerated RFS. Adaptor does not support IPv6 filters. Since Accelerated
>>> RFS is supported for IPV6, using skb_flow_dissect will return true with non-zero
>>> values in src/dst for IPv6.
>>> 
>>> If I am going to write separate function for getting IP address and port
>>> numbers, its definition is going to be somewhat same as skb_flow_dissect.
>>> Why not improve whats already written and reuse it?
>>> 
>>> Is there any significant downside of adding u16 n_proto and increasing
>>> size of qdisc_skb_cb by 4 bytes?
>> 
>> You can avoid this increase (might be bad for IB, hard to tell), by
>> changing sch_choke.c to only store a part of the struct flow_keys.
> 
> I think this is fine, IPOIB's control block will need still just 44
> bytes after these changes, so there will still be 4 bytes to spare.
> 
> I'm going to apply this series.

Actually, I change my mind, Govindarajulu can you address Sergei's feedback
in your other changes and repost this series?

Thanks.
