From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH net-next-2.6 v2 3/3] sctp: Add a valid address list in
 association local
Date: Thu, 14 Apr 2011 10:24:47 +0800
Message-ID: <4DA65AEF.70800@cn.fujitsu.com>
References: <115A4380-6E63-4014-BD24-04A29472ACCD@sfc.wide.ad.jp> <4DA64EF0.30506@cn.fujitsu.com> <EB560391-3EE8-43BB-83A4-DD55352CFEAF@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63696 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756184Ab1DNCYf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 22:24:35 -0400
In-Reply-To: <EB560391-3EE8-43BB-83A4-DD55352CFEAF@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Hi, 
>
> I implemented that functionality for following situations.  
> 1. Suppose two associations A and B directed to different destination that belong to the same endpoint.  (one-to-many socket).  

Yes, but the addr list of assoc A and B is independent, see
asoc->base.bind_addr, which is per asoc.

endpoint hold the bind list for new create assoc. when assoc
is created, the bind list will be copy from ep, by
sctp_assoc_set_bind_addr_from_ep().

> 2. After the address addition event, A and B will send an ASCONF.  
> 3. Suppose only A receives ASCONF-ACK, and B has not received one yet.  
> 4. In this moment, A can use the new address as the source address for regular chunk, but B can't.  
> 5. But I think both A and B use the new address even after only A receives ASCONF-ACK  in current SCTP implementation,
> This patch achieves that only A uses that new address in this moment.  
>
> Am I missing something?
>
> Thanks,
> - Michio
>
> On Apr 14, 2011, at 10:33 , Wei Yongjun wrote:
>
>>
>>> When the SCTP association transmits an ASCONF with ADD_IP_ADDRESS, that association cannot use the adding address until it receives ASCONF-ACK.  
>>> This patch prevents that associations that do not receive ASCONF-ACK use the adding address.
>> The new adding address is marked SCTP_ADDR_NEW, and cannot use
>> in LKSCTP until received ASCONF-ACK and marked as SCTP_ADDR_SRC.
>> So, add this valid address list is unnecessary.
>>
>> I guess you want to fix the route lookup issue?
>>
>> If it is, the only thing we need to fix is the lookup of route. If we can not
>> found a valid dst for transport, we can try address marked with SCTP_ADDR_NEW.
>>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
