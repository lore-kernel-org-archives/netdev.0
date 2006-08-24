From: Brice Goglin <brice@myri.com>
Subject: myri10ge conversion to non-contiguous skb
Date: Thu, 24 Aug 2006 18:26:25 -0400
Message-ID: <44EE2791.50101@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:6299 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1422768AbWHXW02 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 18:26:28 -0400
Received: from [172.31.3.180] (dhcp180.myri-dhcp.com [172.31.3.180])
	by myri.com (8.12.9+Sun/8.12.9) with ESMTP id k7OMQQmc020728
	for <netdev@vger.kernel.org>; Thu, 24 Aug 2006 15:26:26 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

During the submission of the myri10ge driver, some people raised the
question of using pages (or any kind of non-contiguous skb) instead of
our current 16kB contiguous skb. We are looking at this right now and it
is not clear what solution is the best. From what we understand, Linux
provides two mostly redundant mechanisms to handle discontinuous skb,
the skb->frags and the skb->frag_list, s2io using the latter while e1000
uses the former. Is one or the other recommended? What is the purpose of
having them both in the net core?

Thank you
Brice Goglin

>>> Imho you will want to work directly with pages shortly.  
>>>       
>> We had thought about doing this, but were a little nervous since we did
>> not know of any other drivers that worked directly with pages.  If this
>> is an official direction to work directly with pages, we will. 
>>     
> s2io does. e1000 does it with skb frags.
> If your hardware allows header split and driver can put headers into
> skb->data and real data into frag_list, that allows to create various
> interesting things like receiving zero-copy support and netchannels
> support. It is work in progress, not official direction currently,
> but this definitely will help your driver to support future high 
> performance extensions.
>   
