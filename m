From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: Re: [PATCH net-next-2.6 v2 3/3] sctp: Add a valid address list in association local
Date: Thu, 14 Apr 2011 11:01:25 +0900
Message-ID: <EB560391-3EE8-43BB-83A4-DD55352CFEAF@sfc.wide.ad.jp>
References: <115A4380-6E63-4014-BD24-04A29472ACCD@sfc.wide.ad.jp> <4DA64EF0.30506@cn.fujitsu.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:35750 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752837Ab1DNCB2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 22:01:28 -0400
In-Reply-To: <4DA64EF0.30506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, 

I implemented that functionality for following situations.  
1. Suppose two associations A and B directed to different destination that belong to the same endpoint.  (one-to-many socket).  
2. After the address addition event, A and B will send an ASCONF.  
3. Suppose only A receives ASCONF-ACK, and B has not received one yet.  
4. In this moment, A can use the new address as the source address for regular chunk, but B can't.  
5. But I think both A and B use the new address even after only A receives ASCONF-ACK  in current SCTP implementation,
This patch achieves that only A uses that new address in this moment.  

Am I missing something?

Thanks,
- Michio

On Apr 14, 2011, at 10:33 , Wei Yongjun wrote:

> 
> 
>> When the SCTP association transmits an ASCONF with ADD_IP_ADDRESS, that association cannot use the adding address until it receives ASCONF-ACK.  
>> This patch prevents that associations that do not receive ASCONF-ACK use the adding address.
> 
> The new adding address is marked SCTP_ADDR_NEW, and cannot use
> in LKSCTP until received ASCONF-ACK and marked as SCTP_ADDR_SRC.
> So, add this valid address list is unnecessary.
> 
> I guess you want to fix the route lookup issue?
> 
> If it is, the only thing we need to fix is the lookup of route. If we can not
> found a valid dst for transport, we can try address marked with SCTP_ADDR_NEW.
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

