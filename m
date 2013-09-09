From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: TSQ accounting skb->truesize degrades throughput for large packets
Date: Mon, 9 Sep 2013 22:41:20 +0100
Message-ID: <522E4080.2050802@citrix.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>  <1378472268.31445.15.camel@edumazet-glaptop> <522A049A.7000105@citrix.com>  <1378486840.31445.36.camel@edumazet-glaptop> <1378574494.26319.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	<netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:48573 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755905Ab3IIVlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Sep 2013 17:41:24 -0400
In-Reply-To: <1378574494.26319.14.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/13 18:21, Eric Dumazet wrote:
> On Fri, 2013-09-06 at 10:00 -0700, Eric Dumazet wrote:
>> On Fri, 2013-09-06 at 17:36 +0100, Zoltan Kiss wrote:
>>
>>> So I guess it would be good to revisit the default value of this
>>> setting.
>>
>> If ixgbe requires 3 TSO packets in TX ring to get line rate, you also
>> can tweak dev->gso_max_size from 65535 to 64000.
>
> Another idea would be to no longer use tcp_limit_output_bytes but
>
> max(sk_pacing_rate / 1000, 2*MSS)

I've tried this on a freshly updated upstream, and it solved my problem 
on ixgbe:

-               if (atomic_read(&sk->sk_wmem_alloc) >= 
sysctl_tcp_limit_output_bytes) {
+               if (atomic_read(&sk->sk_wmem_alloc) >= 
max(sk->sk_pacing_rate / 1000, 2 * mss_now) ){

Now I can get proper line rate. Btw. I've tried to decrease 
dev->gso_max_size to 60K or 32K, both was ineffective.

Regards,

Zoli
