From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Tue, 08 Sep 2009 11:18:44 -0400
Message-ID: <4AA675D4.8030406@hp.com>
References: <4AA1C0FF.4030109@hp.com> <1252418247.5827.8.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: david Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jens Rosenboom <jens@mcbone.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:38638 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbZIHPSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 11:18:46 -0400
In-Reply-To: <1252418247.5827.8.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jens Rosenboom wrote:
>> --- a/net/ipv6/addrconf.c
>> +++ b/net/ipv6/addrconf.c
>> @@ -1376,7 +1376,7 @@ static void addrconf_dad_stop(struct inet6_ifaddr *ifp)
>>  	if (ifp->flags&IFA_F_PERMANENT) {
>>  		spin_lock_bh(&ifp->lock);
>>  		addrconf_del_timer(ifp);
>> -		ifp->flags |= IFA_F_TENTATIVE;
>> +		ifp->flags |= IFA_F_DADFAILED;
> 
> I think you still have to set IFA_F_TENTATIVE here, too, otherwise
> ipv6_dev_get_saddr() will use this address. 		

The tentative bit is still set from when this address was added back
in ipv6_add_addr() from what I can tell, re-setting it here is actually
unnecessary.  At least /sbin/ip was still showing it set during my
testing.

-Brian

