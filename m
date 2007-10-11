From: Satoshi OSHIMA <satoshi.oshima.fk@hitachi.com>
Subject: Re: [RFC/PATCH 4/4] UDP memory usage accounting (take 4): memory
 limitation
Date: Thu, 11 Oct 2007 21:51:14 +0900
Message-ID: <470E1C42.1050901@hitachi.com>
References: <47065139.5030402@hitachi.com>	<47065217.5050004@hitachi.com> <20071005085257.24b2e5cc@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>, ?? ?? <yoshfuji@linux-ipv6.org>,
	Yumiko SUGITA <yumiko.sugita.yf@hitachi.com>,
	"??@RedHat" <haoki@redhat.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail9.hitachi.co.jp ([133.145.228.44]:55614 "EHLO
	mail9.hitachi.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361AbXJKMvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 08:51:22 -0400
Received: from mlsv13.hitachi.co.jp (unknown [133.144.234.166])
	by mail9.hitachi.co.jp (Postfix) with ESMTP id CC9F437C86
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 21:51:20 +0900 (JST)
In-Reply-To: <20071005085257.24b2e5cc@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

Thank you for your comment.

>>  	{
>> +		.ctl_name	= NET_UDP_MEM,
>> +		.procname	= "udp_mem",
>> +		.data		= &sysctl_udp_mem,
>> +		.maxlen		= sizeof(sysctl_udp_mem),
>> +		.mode		= 0644,
>> +		.proc_handler	= &proc_dointvec
>> +	},
>> +	{
>>  		.ctl_name	= NET_TCP_APP_WIN,
>>  		.procname	= "tcp_app_win",
>>  		.data		= &sysctl_tcp_app_win,
> 
> if you use &proc_dointvec_minmax, then you could inforce min/max
> values for udp_mem for the sysctl

udp_mem has two meanings:
* turn off this limitation function (currently udp_mem<=4096)
* limit udp memory (currently udp_mem>4096)

To realize this,  udp_mem is evaluated whether udp_mem equals
4096 or smaller in UDP and IP layers.

If udp_mem has proc_dointvec_minmax or dedicated proc handler,
turn off check must be done in UDP and IP layers. This means
there is no reduction of the check in UDP and IP layers.


If you pointed out that minus value of udp_mem is strange,
I agree. I'll fix it.

How about this?
min=4096     (and turn off limitation)
udp_mem>4096 (and turn on limitation)


Satoshi Oshima

