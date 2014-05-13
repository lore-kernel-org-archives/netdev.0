From: Carol Soto <clsoto@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/1] mlx4: mlx4_core failed to load
Date: Tue, 13 May 2014 13:14:08 -0500
Message-ID: <537260F0.7080306@linux.vnet.ibm.com>
References: <20140428183330.201681971@linux.vnet.ibm.com> <20140428.155900.1619506417111671946.davem@davemloft.net> <5372350E.7030100@linux.vnet.ibm.com> <20140513.123217.22616774554500768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:43182 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751943AbaEMSOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 14:14:04 -0400
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Tue, 13 May 2014 12:14:04 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 9478A1FF0075
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 12:14:01 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4DIE1xL64684076
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 20:14:01 +0200
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id s4DIHrEL028496
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 12:17:53 -0600
In-Reply-To: <20140513.123217.22616774554500768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 5/13/2014 11:32 AM, David Miller wrote:
> From: Carol Soto <clsoto@linux.vnet.ibm.com>
> Date: Tue, 13 May 2014 10:06:54 -0500
>
>> On 4/28/2014 2:59 PM, David Miller wrote:
>>> From: clsoto@linux.vnet.ibm.com
>>> Date: Mon, 28 Apr 2014 13:33:30 -0500
>>>
>>>> This is for a case where mlx4_core fails to load.
>>> You cannot just will-nilly delete module parameters that you decide
>>> you don't want to support any more.
>>>
>>> Once you add a module parameter, you are stuck with it forever once
>>> it makes it into a released kernel.  It is a user visible interface.
>>>
>>> I'm not applying this patch, you have to actually fix the bug rather
>>> then wholesale remove the facility altogether.
>> The problem here is that when use_prio argument is used then the
>> number of reserved qps increase from 0x20000 to 0x90000. So when it
>> goes to mlx4_bitmap_init the argument reserved_top becomes a lot
>> bigger than argument num, because of this then the math to get the
>> size for the kzalloc is very big. The argument num is the num of qps
>> that the adapter supports so then this sounds to me like a bug that if
>> we use the use_prio we can not have more qps reserved than the num qps
>> that adapter supports. That is why I went to the path of removing the
>> argument in this patch. Any other suggestion?
> It is not my job to fix bugs in your driver.
>
> But it is my job to make sure you do not break things that are
> user visible, and that means you cannot delete module parameters
> that are "too difficult to fix".
>
> You should have considered more carefully the semantics of this
> module option when it was added.
This is not my driver. I do not know how this argument make it upstream 
in the first place. It maybe was functional at some point but I do not 
have that information. That maybe a question for Mellanox. Now by 
debugging the code in my system I do not see how this argument is useful 
based in my previous comment. Maybe we need Mellanox to confirm here 
what is the use of this argument and if it is needed.
