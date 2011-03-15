From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Tue, 15 Mar 2011 10:47:20 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103151033260.1729@ja.ssi.bg>
References: <201102231243.23579.alexandre.sidorenko@hp.com> <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg> <alpine.LFD.2.00.1103100222080.2550@ja.ssi.bg> <201103101441.57105.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:54606 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754980Ab1COIm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 04:42:26 -0400
In-Reply-To: <201103101441.57105.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Thu, 10 Mar 2011, Alex Sidorenko wrote:

>> IP1: 192.168.140.31/22, primary
>> IP2: 192.168.142.109/23, primary
>> IP3: 192.168.142.109/22, secondary for primary IP1
>>
>>         It is the route for IP3 that is leaked, with prefsrc=IP1.
>> We create local route for secondary IPs with prefsrc=ItsPrimaryIP.
>> Both local routes for 109 differ in prefsrc (fa_info). But on
>> deletion only one route is deleted due to last_ip check - the first
>> because on deletion prefsrc is not matched, fib_table_delete
>> does not work in symmetric way. So, the local route created
>> for IP3 remains no matter the deletion order.
>> If we decide to create one unique local route for this case,
>> there is a risk device unregistration to remove
>> it (fib_sync_down_dev with force > 0).
>
> Yes, but do we _really_ need to be able to add the same IP multiple times
> (with different masks)? If not, we can just return an error when someine tries
> to add the same IP again with different mask.

 	Yes, it seems one IP can be part of different subnets,
even with different scope. We can create compatibility
problems for users that use it in this way. I found more
issues with the secondary address promotion and broadcast
address deletion, it will take 2-3 days to prepare some
patches and test script for all these problems.

Regards

--
Julian Anastasov <ja@ssi.bg>
