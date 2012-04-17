From: James Chapman <jchapman@katalix.com>
Subject: Re: [RFC PATCH 2/2] l2tp: Introduce L2TPv3 IP encapsulation support
 for IPv6
Date: Tue, 17 Apr 2012 15:01:54 +0100
Message-ID: <4F8D77D2.3010505@katalix.com>
References: <y>  <1334665766-11461-3-git-send-email-jchapman@katalix.com> <1334666934.2472.36.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:50207 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932218Ab2DQOCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 10:02:04 -0400
In-Reply-To: <1334666934.2472.36.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/04/12 13:48, Eric Dumazet wrote:
> On Tue, 2012-04-17 at 13:29 +0100, James Chapman wrote:
>> L2TPv3 defines an IP encapsulation packet format where data is carried
>> directly over IP (no UDP). The kernel already has support for L2TP IP
>> encapsulation over IPv4 (l2tp_ip). This patch introduces support for L2TP
>> IP encapsulation over IPv6.
> 
> ...
>
>> +	/* Update stats */
>> +	if (err < 0) {
>> +		lsk->tx_errors++;
>> +	} else {
>> +		lsk->tx_packets++;
> 
> This is not SMP (especially on 32bit) safe, you dont own any lock

Thanks for catching this. This should be updating the stats in the l2tp
tunnel, not private data of the socket. We have the same SMP issues in
the l2tp tunnel/session stats code though. I'll submit a separate patch
to fix it.

Thanks for reviewing.


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development
