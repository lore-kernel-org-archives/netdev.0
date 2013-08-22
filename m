From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] net: tcp_probe: add IPv6 support
Date: Thu, 22 Aug 2013 14:50:24 -0700 (PDT)
Message-ID: <20130822.145024.1805333381344408345.davem@davemloft.net>
References: <1377107280-31091-4-git-send-email-dborkman@redhat.com>
	<20130822.134309.2073296501906078763.davem@davemloft.net>
	<52168097.7050200@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53216 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab3HVVu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 17:50:28 -0400
In-Reply-To: <52168097.7050200@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 22 Aug 2013 23:20:23 +0200

> On 08/22/2013 10:43 PM, David Miller wrote:
>> From: Daniel Borkmann <dborkman@redhat.com>
>> Date: Wed, 21 Aug 2013 19:48:00 +0200
>>
>>> +	union {
>>> +		struct sockaddr		raw;
>>> +		struct sockaddr_in	v4;
>>> +		struct sockaddr_in6	v6;
>>> +	}	src, dst;
>>
>> This bloats up the tcp_log structure unnecessarily.  You have
>> absolutely no use for the port member, for example.
>>
>> I know you want to use this so that you can be lazy and only
>> use the single printf format specifier.  Here, keeping the
>> tcp_log compact is more important.
> 
> Well, the port is being filled out *and* used in both IPv4 and IPv6
> cases. That is why %pISpc is being used, hence IP + port that is being
> printed. The port was of course also printed to the log before in
> IPv4 only case, so nothing would change there.

Good point, ok I'll reconsider this series.
