From: roopa <roopa@cumulusnetworks.com>
Subject: Re: IFLA_INET6_[ICMP6]STATS
Date: Thu, 10 Sep 2015 08:43:58 -0700
Message-ID: <55F1A53E.1010908@cumulusnetworks.com>
References: <20150909213444.GD20544@oracle.com> <20150909.144308.360246374222280540.davem@davemloft.net> <20150909214528.GE20544@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	raghavendra.kt@linux.vnet.ibm.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36781 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbbIJPoB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 11:44:01 -0400
Received: by padhk3 with SMTP id hk3so46202571pad.3
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 08:44:00 -0700 (PDT)
In-Reply-To: <20150909214528.GE20544@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/9/15, 2:45 PM, Sowmini Varadhan wrote:
> On (09/09/15 14:43), David Miller wrote:
>> But what we could do is add a flag in the netlink request which
>> elides the stats.  GLIBC et al. could then start setting the flag.
>>
> Yes, interestingly that's what I was experimenting with myself
> (though I was using a setsockopt in my version). I'll send out
> a patch rfc later this week for this.
>
If you decide to use a flag, there is IFLA_EXT_MASK which is used to 
specify such filters from userspace today.

/* New extended info filters for IFLA_EXT_MASK */
#define RTEXT_FILTER_VF         (1 << 0)
#define RTEXT_FILTER_BRVLAN     (1 << 1)
#define RTEXT_FILTER_BRVLAN_COMPRESSED  (1 << 2)

ideally long term, it would be nice for RTM_GETLINK request msg to 
contain the attributes it is interested in (This would  again be 
optional with the default being get all attributes).
