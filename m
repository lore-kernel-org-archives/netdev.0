From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: ipv4: add support for ECMP hash policy
 choice
Date: Mon, 6 Mar 2017 18:52:25 +0200
Message-ID: <1b2db5fe-2a36-2463-6821-cba393fc3d28@cumulusnetworks.com>
References: <1488812370-24800-1-git-send-email-nikolay@cumulusnetworks.com>
 <bbdd46d3-7981-9718-7a93-249eacbe1a3b@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, roopa@cumulusnetworks.com
To: David Ahern <dsa@cumulusnetworks.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:33569 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754049AbdCFQ6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 11:58:32 -0500
Received: by mail-wr0-f175.google.com with SMTP id u48so121201657wrc.0
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 08:58:30 -0800 (PST)
In-Reply-To: <bbdd46d3-7981-9718-7a93-249eacbe1a3b@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/17 18:24, David Ahern wrote:
> On 3/6/17 7:59 AM, Nikolay Aleksandrov wrote:
>> diff --git a/include/net/route.h b/include/net/route.h
>> index c0874c87c173..77a5c613a290 100644
>> --- a/include/net/route.h
>> +++ b/include/net/route.h
>> @@ -113,13 +113,12 @@ struct in_device;
>>  int ip_rt_init(void);
>>  void rt_cache_flush(struct net *net);
>>  void rt_flush_dev(struct net_device *dev);
>> -struct rtable *__ip_route_output_key_hash(struct net *, struct flowi4 *flp,
>> -					  int mp_hash);
>> +struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *flp);
>>  
>>  static inline struct rtable *__ip_route_output_key(struct net *net,
>>  						   struct flowi4 *flp)
>>  {
>> -	return __ip_route_output_key_hash(net, flp, -1);
>> +	return __ip_route_output_key_hash(net, flp);
>>  }
>>  
>>  struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp,
> 
> The "_hash" variant was added by 79a131592dbb8. If the mp_hash arg is
> removed, the "_hash" wrapper should be removed and go back to
> __ip_route_output_key.
> 

Ah yes, I've missed that. :-) Will remove the _hash variant when posting v2.

Thanks,
 Nik
