From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH net-next 2/2] bonding: use the correct ether type for alb
Date: Fri, 14 Mar 2014 19:42:52 +0100
Message-ID: <20140314184251.GA30498@redhat.com>
References: <1394710918-29540-1-git-send-email-vfalico@redhat.com>
 <1394710918-29540-3-git-send-email-vfalico@redhat.com>
 <20140314.142935.1237930025090619830.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41145 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820AbaCNSnE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 14:43:04 -0400
Content-Disposition: inline
In-Reply-To: <20140314.142935.1237930025090619830.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 14, 2014 at 02:29:35PM -0400, David Miller wrote:
>From: Veaceslav Falico <vfalico@redhat.com>
>Date: Thu, 13 Mar 2014 12:41:58 +0100
>
>> @@ -1005,7 +1005,7 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
>>  	memset(&pkt, 0, size);
>>  	ether_addr_copy(pkt.mac_dst, mac_addr);
>>  	ether_addr_copy(pkt.mac_src, mac_addr);
>> -	pkt.type = cpu_to_be16(ETH_P_LOOP);
>> +	pkt.type = cpu_to_be16(ETH_P_LOOPBACK);
>
>Had this really never worked properly at all?

Yep, but only in cases where the hw/sw didn't filter out broken packets
*before* arp processing, as far as I can tell.

>
>It's been this way since the beginning of GIT history, and I imagine
>since the learning packet code even existed.
