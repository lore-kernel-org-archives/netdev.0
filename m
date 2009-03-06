From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] macvlan: Support creating macvlans from macvlans
Date: Fri, 06 Mar 2009 16:56:23 +0100
Message-ID: <49B147A7.7010006@trash.net>
References: <m1ocwfsgw7.fsf@fess.ebiederm.org> <49B12B20.7000602@trash.net>	<m1sklqohw2.fsf@fess.ebiederm.org> <49B13259.9040701@trash.net>	<m14oy6n15y.fsf@fess.ebiederm.org> <49B13C7D.10308@trash.net>	<m1bpsellmv.fsf@fess.ebiederm.org> <49B14234.5030206@trash.net> <m1wsb2k5vg.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33452 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775AbZCFP42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 10:56:28 -0500
In-Reply-To: <m1wsb2k5vg.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Patrick McHardy <kaber@trash.net> writes:
> 
>> Eric W. Biederman wrote:
>>> Patrick McHardy <kaber@trash.net> writes:
>>>
>>>>> Hmm.  Actually that appears to be a macvlan bug.  It looks like if I
>>>>> change the macaddress on a macvlan we don't update the hash chains.
>>>>> So unless we have the same low byte we will be on the wrong hash chain
>>>>> and not receive the packets for the mac we specified.  Ouch!
>>>> The address can only be changed while the device is down and unhashed.
>>> Point.  The dev_unicast/dev_unicast_delete in macvlan_set_mac_address
>>> appears to be completely unnecessary then.
>> I think thats correct.
> 
> Actually it is really weird.  We can change the mac address while
> the devices is running but the code is broken because it does
> not update the hash table.

Thats strange. I know the assumption was that this can't be done.
But I can't find anything preventing it, not even in older versions.

>> Refusing duplicate MACs (on one underlying device) makes sense, the
>> results are undefined currently.
> 
> Then I will do that just for consistency.

Thanks.
