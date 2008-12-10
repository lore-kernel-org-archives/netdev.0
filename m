From: Yang Hongyang <yanghy@cn.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3]ipv6:fix the outgoing interface selection order
 in udpv6_sendmsg()
Date: Wed, 10 Dec 2008 14:38:25 +0800
Message-ID: <493F63E1.3030800@cn.fujitsu.com>
References: <493E1A7B.9070208@cn.fujitsu.com>	<200812090932.56865.remi.denis-courmont@nokia.com>	<493F106C.8030803@cn.fujitsu.com> <20081209.221611.26561529.davem@davemloft.net> <493F62D7.3080000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57902 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbYLJGgw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 01:36:52 -0500
In-Reply-To: <493F62D7.3080000@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> David Miller wrote:
>> From: Yang Hongyang <yanghy@cn.fujitsu.com>
>> Date: Wed, 10 Dec 2008 08:42:20 +0800
>>
>>> If outgoing interface is set with SO_BINDTODEVICE and also sticky pktinfo
>>> the outgoing interface is exactly what SO_BINDTODEVICE set,because in my
>>> first patch,when set sticy pktinfo,outgoing interface set by SO_BINDTODEVICE
>>> is checked:
>>>
>>> +		if(sk->sk_bound_dev_if && pkt.ipi6_ifindex != sk->sk_bound_dev_if)
>>> +			goto e_inval;
>>>
>> You may be checking this, but these two values can become out of sync
>> if the application next makes a SO_BINDTODEVICE setsockopt() call to
>> change the index setting.
>>
>> Nothing makes sure the sticky ipv6 socket information is updated
>> if that happens.  And the most obvious ways to handle that are
>> very ugly, doing some kind of call into ipv6 from the generic
>> socket SO_BINDTODEVICE setsockopt() handler.
>>
>>
> 
> Hum..can we just ignore the sync of the sticky option and the SO_BINDTODEVICE,
> when send a message,first check sk_bound_dev_if,If it is specified,use it,otherwise
> use sticky option?This was what i ment. and in my patch ,the outgoing interface 
> specified by sticky options will be overrided by the interface specified by 
> SO_BINDTODEVICE.

If this is the solution, i'll post a updated patch.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

