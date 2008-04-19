From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on
 latest -git
Date: Sat, 19 Apr 2008 12:44:53 +0200 (CEST)
Message-ID: <alpine.LNX.1.10.0804191243170.26385@fbirervta.pbzchgretzou.qr>
References: <20080419100034.GA9475@elte.hu> <20080419.030736.168169087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: mingo@elte.hu, linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:34790 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757470AbYDSKoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 06:44:54 -0400
In-Reply-To: <20080419.030736.168169087.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Saturday 2008-04-19 12:07, David Miller wrote:
>> randconfig testing found a netfilter build failure in latest -git:
>> 
>>   net/netfilter/nf_conntrack_sip.c: In function 'set_expected_rtp_rtcp':
>>   net/netfilter/nf_conntrack_sip.c:786: error: 'struct nf_conntrack_expect' has no member named 'saved_ip'
>> 
>>   http://redhat.com/~mingo/misc/config-Sat_Apr_19_11_37_02_CEST_2008.bad
>> 
>> disabling CONFIG_NF_CONNTRACK_SIP works it around.
>
>I think this will fix it.
>
>Patrick, is this how we should do it?
>
> config NF_CONNTRACK_SIP
> 	tristate "SIP protocol support"
>-	depends on NF_CONNTRACK
>+	depends on NF_CONNTRACK && NF_NAT
> 	default m if NETFILTER_ADVANCED=n

Not really. One may want to run a system without NAT,
but still with connection tracking (for firewalling) -- think IPv6.
