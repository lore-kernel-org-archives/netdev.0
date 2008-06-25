From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Patch to add support for multiple multicast routing tables.
Date: Tue, 24 Jun 2008 22:52:49 -0700
Message-ID: <4861DD31.3020203@candelatech.com>
References: <4861966B.5090208@candelatech.com> <20080624222807.3a9918d1@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:33892 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbYFYFwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 01:52:50 -0400
In-Reply-To: <20080624222807.3a9918d1@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Tue, 24 Jun 2008 17:50:51 -0700
> Ben Greear <greearb@candelatech.com> wrote:
>
>   
>> In order to run multiple Xorp instances and treat different groups of
>> interfaces as being in their own virtual router, I had to update the
>> ipv4/ipmr.c logic to support multiple routing tables.
>>
>> I will be attempting to push the cooresponding xorp changes to it's
>> maintainers if this is accepted into the kernel.  It should be fully
>> backwards compatible with existing xorp and other multicast
>> routing tools.  It does change the procfs output slightly, adding
>> a TableId column.
>>
>> The original patch was written by me, and then Patrick McHardy
>> fixed up my cruft and made it much smaller and with better locking.
>> I then fixed a few bugs I found while testing with my modified xorp.
>>
>> The attached patch is against 2.6.25.4 + hacks.  It has a few rejects 
>> against 2.6.26.rc7,
>> but I will fix those sooner rather than later if the patch is otherwise 
>> deemed
>> worthy.
>>
>> Please let me know if this stands a chance of inclusion.
>>
>> Thanks,
>> Ben
>>     
>
> Ben private ioctl's make it hard to handle 32bit/64bit compatiablity,
> and routing is better managed through rtnetlink. Doesn't XORP do
> netlink?
>   
It seemed the path of least resistance, less the patch become even larger.

Xorp does use netlink, but not for multicast (or, at least, not for the 
part of
multicast that talks to ipv4/ipmr.c).  The patch to xorp to support 
multiple routing tables is
not too large, and is backwards compat with older kernels (and bsd-ish 
systems
I suppose.)

For 32/64 compat, how about we make the structs passed in 'attribute 
packed' ?

We can also make the table-id 'u32' or similar to guarantee the size of the
member.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


