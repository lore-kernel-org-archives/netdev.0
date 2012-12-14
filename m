From: Ang Way Chuang <wcang@sfc.wide.ad.jp>
Subject: Re: [PATCH] bridge: Bug fix for incorrect interpretation of MLDv2
 maximum response code
Date: Fri, 14 Dec 2012 08:19:04 +0800
Message-ID: <50CA7078.8070204@sfc.wide.ad.jp>
References: <50CA6DA5.1020101@sfc.wide.ad.jp> <20121213161201.6d2da433@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:34801 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753579Ab2LNATJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 19:19:09 -0500
In-Reply-To: <20121213161201.6d2da433@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/12/2012 08:12, Stephen Hemminger wrote:
> On Fri, 14 Dec 2012 08:07:01 +0800
> Ang Way Chuang <wcang@sfc.wide.ad.jp> wrote:
>
>> This patch fixes the incorrect interpretation of endianness of MLDv2 maximum response
>> code within bridge's multicast snooping code.
>>
>> Signed-off-by: Ang Way Chuang <wcang@sfc.wide.ad.jp>
>> ---
>> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
>> index 977c3ee..29c6283 100644
>> --- a/net/bridge/br_multicast.c
>> +++ b/net/bridge/br_multicast.c
>> @@ -1172,7 +1172,7 @@ static int br_ip6_multicast_query(struct net_bridge *br,
>>  		mld2q = (struct mld2_query *)icmp6_hdr(skb);
>>  		if (!mld2q->mld2q_nsrcs)
>>  			group = &mld2q->mld2q_mca;
>> -		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
>> +		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : 1;
>>  	}
>>  
>>  	if (!group)
> Already fixed as part of my patch to fix sparse warnings.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
aye, aye.
