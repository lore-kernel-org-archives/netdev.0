From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Sat, 17 Nov 2007 14:18:46 +0100
Message-ID: <p73bq9tau2x.fsf@bingen.suse.de>
References: <E1IssYb-0000KG-00@gondolin.me.apana.org.au>
	<473D19EC.6030903@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:50674 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928AbXKQNSs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2007 08:18:48 -0500
In-Reply-To: <473D19EC.6030903@cn.fujitsu.com> (Wang Chen's message of "Fri\, 16 Nov 2007 12\:17\:48 +0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wang Chen <wangchen@cn.fujitsu.com> writes:

> Herbert Xu said the following on 2007-11-16 12:11:
>> Wang Chen <wangchen@cn.fujitsu.com> wrote:
>>> So, I think the checksum in udp_queue_rcv_skb() actually does
>>> the work, not that in udp_recvmsg() and udp_poll().
>>>
>>> If I am wrong, please point out.
>> 
>> We may have a bug in the accounting area.  Check the recent
>> patch made to UDP/IPv6 which is probably needed here as well.
>> 
>
> Like dave said, decrementing the InDataGrams in this case is an
> option.
> I will check the same place of UDP/IPv6.

And like Benny pointed out it's probably a bad idea because
decrementing counters will be an unexpected ABI change for monitoring 
programs who have no other way to detect overflow.

-Andi
