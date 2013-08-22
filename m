From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 3/3] net: tcp_probe: add IPv6 support
Date: Thu, 22 Aug 2013 23:20:23 +0200
Message-ID: <52168097.7050200@redhat.com>
References: <1377107280-31091-1-git-send-email-dborkman@redhat.com> <1377107280-31091-4-git-send-email-dborkman@redhat.com> <20130822.134309.2073296501906078763.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5097 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754028Ab3HVVU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 17:20:28 -0400
In-Reply-To: <20130822.134309.2073296501906078763.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/22/2013 10:43 PM, David Miller wrote:
> From: Daniel Borkmann <dborkman@redhat.com>
> Date: Wed, 21 Aug 2013 19:48:00 +0200
>
>> +	union {
>> +		struct sockaddr		raw;
>> +		struct sockaddr_in	v4;
>> +		struct sockaddr_in6	v6;
>> +	}	src, dst;
>
> This bloats up the tcp_log structure unnecessarily.  You have
> absolutely no use for the port member, for example.
>
> I know you want to use this so that you can be lazy and only
> use the single printf format specifier.  Here, keeping the
> tcp_log compact is more important.

Well, the port is being filled out *and* used in both IPv4 and IPv6
cases. That is why %pISpc is being used, hence IP + port that is being
printed. The port was of course also printed to the log before in
IPv4 only case, so nothing would change there.
