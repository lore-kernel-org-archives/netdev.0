From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next] xen-netfront: try linearizing SKB if it occupies
 too many slots
Date: Fri, 16 May 2014 17:51:46 +0100
Message-ID: <53764222.6070705@citrix.com>
References: <1400238496-2471-1-git-send-email-wei.liu2@citrix.com>	 <1400245474.7973.154.camel@edumazet-glaptop2.roam.corp.google.com>	 <20140516131145.GK18551@zion.uk.xensource.com>	 <1400250068.7973.171.camel@edumazet-glaptop2.roam.corp.google.com>	 <20140516143653.GL18551@zion.uk.xensource.com>	 <1400253739.7973.183.camel@edumazet-glaptop2.roam.corp.google.com>	 <20140516153452.GM18551@zion.uk.xensource.com>	 <53763CD1.6060500@citrix.com> <1400258829.7973.209.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, David Vrabel <david.vrabel@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Stefan Bader <stefan.bader@canonical.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39639 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbaEPQvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 12:51:49 -0400
In-Reply-To: <1400258829.7973.209.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/05/14 17:47, Eric Dumazet wrote:
> On Fri, 2014-05-16 at 17:29 +0100, Zoltan Kiss wrote:
>> On 16/05/14 16:34, Wei Liu wrote:
>>>
>>> It works, at least in this Redis testcase. Could you explain a bit where
>>> this 56000 magic number comes from? :-)
>>>
>>> Presumably I can derive it from some constant in core network code?
>>
>> I guess it just makes more unlikely to have packets with problematic layout. But the following packet would still fail:
>> linear buffer : 80 bytes, on 2 pages
>> 17 frags, 80 bytes each, each spanning over page boundary.
>
> How would you build such skbs ? Its _very_ difficult, you have to be
> very very smart to hit this.
I wouldn't build such skbs, I would expect the network stack to create 
such weird things sometimes :)
The goal here is to prepare and handle the worst case scenarios as well.
>
> Also reducing gso_max_size made sure order-5 allocations would not be
> attempted in this unlikely case.
But reducing the gso_max_size would have a bad impact on the general 
network throughput, right?
