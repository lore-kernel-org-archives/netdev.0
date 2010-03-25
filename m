From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 2/2] ipv4: Restart rt_intern_hash after emergency rebuild
Date: Thu, 25 Mar 2010 10:44:13 +0300
Message-ID: <4BAB144D.3070403@openvz.org>
References: <4BAA4F3F.70703@openvz.org> <20100324195725.GC29364@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12472 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab0CYHok (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Mar 2010 03:44:40 -0400
In-Reply-To: <20100324195725.GC29364@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> @@ -1217,6 +1217,12 @@ restart:
>>  					rt->u.dst.dev->name, num);
>>  			}
>>  			rt_emergency_hash_rebuild(net);
>> +			spin_unlock_bh(rt_hash_lock_addr(hash));
>> +
>> +			hash = rt_hash(rt->fl.fl4_dst, rt->fl.fl4_src,
>> +					in ? rt->fl.iif : rt->fl.oif,
>> +					rt_genid(net));
>> +			goto restart;
>>  		}
>>  	}
> Why pass in a flag here?  Perhaps it would be easier just to pass in the ifindex
> that was origionally used by the caller of rt_intern_hash so that the hash could
> be redone without needing to toggle on the value of the flag.  

That's perfectly fine with me. I'll resend the patch shortly.

> Regards
> Neil
> 
>>
> 

