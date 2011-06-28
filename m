From: Tomasz Chmielewski <mangoo@wpkg.org>
Subject: Re: what's causing "ip_rt_bug"?
Date: Tue, 28 Jun 2011 10:30:11 +0200
Message-ID: <4E099113.6000801@wpkg.org>
References: <alpine.LFD.2.00.1106180227400.1583@ja.ssi.bg>	<4DFC627F.7040007@wpkg.org>	<alpine.LFD.2.00.1106182036001.1425@ja.ssi.bg> <20110627.205544.111681152997205782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bazsi@balabit.hu, hidden@balabit.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.virtall.com ([178.63.195.102]:33718 "EHLO mail.virtall.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756053Ab1F1Iag (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2011 04:30:36 -0400
In-Reply-To: <20110627.205544.111681152997205782.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.06.2011 05:55, David Miller wrote:

>> 	The resulting handling should be:
>>
>> - REJECT TCP:
>> 	- in INPUT we can provide addr_type = RTN_LOCAL but
>> 	better allow rejecting traffic delivered with
>> 	local route (no IP address =>  use RTN_UNSPEC to
>> 	allow also RTN_UNICAST).
>> 	- FORWARD: RTN_UNSPEC =>  allow RTN_LOCAL/RTN_UNICAST
>> 	saddr, add fix to ignore RTN_BROADCAST and RTN_MULTICAST
>> 	- OUTPUT: RTN_UNSPEC
>>
>> - NAT, mangle, ip_queue, nf_ip_reroute: RTN_UNSPEC in LOCAL_OUT
>>
>> - IPVS:
>> 	- use RTN_LOCAL in LOCAL_OUT and FORWARD after SNAT
>> 	to restrict saddr to be local
>>
>> Signed-off-by: Julian Anastasov<ja@ssi.bg>
>
> Unless someone gives some negative feedback soon I'm going to
> apply this.

Can you tell me where it will be pushed?

I.e. 3.x kernels only, or does it have a chance to go into 2.6.39.x?


-- 
Tomasz Chmielewski
http://wpkg.org
