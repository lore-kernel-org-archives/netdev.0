From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v3] af_mpls: fix undefined reference to ip6_route_output
Date: Mon, 27 Jul 2015 21:30:31 -0700
Message-ID: <55B70567.6090402@cumulusnetworks.com>
References: <1438044077-1910-1-git-send-email-roopa@cumulusnetworks.com> <20150727.212041.2269026145203619118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:34691 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753551AbbG1Eac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 00:30:32 -0400
Received: by pdbbh15 with SMTP id bh15so63528832pdb.1
        for <netdev@vger.kernel.org>; Mon, 27 Jul 2015 21:30:32 -0700 (PDT)
In-Reply-To: <20150727.212041.2269026145203619118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/27/15, 9:20 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Mon, 27 Jul 2015 17:41:17 -0700
>
>> @@ -33,4 +33,11 @@ config MPLS_IPTUNNEL
>>   	---help---
>>   	 mpls ip tunnel support.
>>   
>> +config MPLS_NEXTHOP_DEVLOOKUP
>> +	bool "MPLS: nexthop oif dev lookup"
>> +	depends on MPLS_ROUTING && INET && (IPV6 || IPV6=n)
>> +	---help---
>> +	 This enables mpls route nexthop dev lookup when oif is not
>> +	 specified by user
>
> This still allows the illegal combination, how did you test this?
>
> CONFIG_IPV6=m
> CONFIG_MPLS=y
> CONFIG_NET_MPLS_GSO=y
> CONFIG_MPLS_ROUTING=y
> CONFIG_MPLS_IPTUNNEL=y
> CONFIG_MPLS_NEXTHOP_DEVLOOKUP=y
>
> net/built-in.o: In function `find_outdev':
> af_mpls.c:(.text+0x17df41): undefined reference to `ip6_route_output'
>
> The situation that must be prevented is MPLS_ROUTING=y + IPV6=m,
> but that's exactly what is being allowed even after your patch.
>
> Again, how did you test this?  Did you try the case that causes
> problems as indicated in the failure reports?
yes, I did test exactly the combination above. And also CONFIG_IPV6=m + 
CONFIG_MPLS_ROUTING=m and others with CONFIG_IPV6=n. Am not sure how I 
missed the error.... I will look again. Sorry about the iteration.
