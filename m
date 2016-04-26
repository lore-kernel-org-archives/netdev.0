From: Mike Manning <mmanning@brocade.com>
Subject: Re: [PATCH] net: ipv6: Delete host routes on an ifdown
Date: Tue, 26 Apr 2016 01:57:20 +0100
Message-ID: <571EBCF0.8030609@brocade.com>
References: <1461297372-18796-1-git-send-email-dsa@cumulusnetworks.com>
 <20160425.152611.583503438886577374.davem@davemloft.net>
 <571E72AA.4030100@cumulusnetworks.com>
 <20160425.164227.1599148827995063295.davem@davemloft.net>
 <571E943C.9010504@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:4766 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751060AbcDZA5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 20:57:35 -0400
In-Reply-To: <571E943C.9010504@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2016 11:03 PM, David Ahern wrote:
> On 4/25/16 2:42 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Mon, 25 Apr 2016 13:40:26 -0600
>>
>>> It's unfortunate you want to take that action. Last week I came across
>>> a prior attempt by Stephen to do this same thing -- keep IPv6
>>> addresses. That prior attempt was reverted by commit
>>> 73a8bd74e261. Cumulus, Brocade, and others clearly want this
>>> capability.
>>
>> But nobody has implemented it correctly, it doesn't matter who wants
>> the feature.  That's why it keeps getting reverted.
>>
>> Also, this testing you are talking about should have happened long
>> before you submitted that first patch that introduced all of these
>> regressions.  My observations tell me that the bulk of the testing
>> happened afterwards and that's why all the regressions are popping up
>> now.
>>
> 
> My testing when submitting the patch was host level: Add an address, while(1) (link up, link down), delete an address, etc.
> 
> Once it was committed to our kernel it started getting hit with a range of L3 deployment scenarios with many nodes and networking config files are uploaded and jumped between on real switch hardware - no reboot but 'networking reload' on the fly. Jumping between different deployments with different sets addresses, routes, vrf devices, bridges, bonds, etc.
> 
> Your objection seems to be 'all these regressions' but beyond the ref count from Andrey all of the bug reports have come from me with 1 from Mike, another invested party wanting this to happen. I am the one who spent the hours dealing with the kernel panics. My patch, my bug, my time wasted coming up with the delta patch. Rather than focusing on my mistakes, why not see the commitment on following through with this change?

It would be great if this could be reconsidered, also bearing in mind that any potential regressions do not have any impact with the default setting of keep_addr_on_down disabled. Or if not, to at least identify what the shortcomings of this solution are for future reference.

I confirm we have been using David's original patch for not flushing IPv6 addresses since it was submitted last year, as for routers it is unacceptable to have IPv6 addresses disappear on link down (although we can work around this to some extent).

When the revised patch and the immediate follow-up fix by David were recently merged for the 4.6 kernel, the only regression I found for ethernet interfaces by changing to the new fix was that local addresses were being retained on link down. This bug was only introduced as a result of a review comment, and David's subsequent fix avoided keeping local addrs (I suggested a complementary fix to avoid fixing them up, as a crash was observed without this in some cases).

Now with David's fix for a vulnerability with loopback interfaces in place and testing looking fine, it seems a shame to give up.
