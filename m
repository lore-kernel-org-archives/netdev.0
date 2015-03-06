From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: I can tell no FIB
Date: Thu, 5 Mar 2015 16:07:01 -0800
Message-ID: <CAE4R7bB1Z_gBbaUQLXz2FRS3SSVZp__n-PNnGfX16-Apscf=YA@mail.gmail.com>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>
	<54F8C802.1010706@gmail.com>
	<20150305.162711.545663291988773902.davem@davemloft.net>
	<54F8D249.4080404@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:33236 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805AbbCFAHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 19:07:02 -0500
Received: by qcxm20 with SMTP id m20so46918734qcx.0
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 16:07:01 -0800 (PST)
In-Reply-To: <54F8D249.4080404@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 2:01 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On 03/05/2015 01:27 PM, David Miller wrote:
>> From: Alexander Duyck <alexander.duyck@gmail.com>
>> Date: Thu, 05 Mar 2015 13:17:54 -0800
>>
>>> On 03/05/2015 12:49 PM, Scott Feldman wrote:
>>>> Hi Alex, turns out you're required to take a mandatory week-long
>>>> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
>>>> week!  Take lots of pictures.
>>>>
>>>> -scott
>>> Well I have one more set of 9 and then I will stop for a while.  I was
>>> planning to send it later tonight.  Then I can probably take that
>>> week-long vacation..
>>>
>>> I'm going to drop the portion of the patches I had where I was
>>> up-levelling the key vector since I still don't have a solution for the
>>> extra costs of insertion/deletion from the trie.  Also I don't think it
>>> would work well with the merge of the main and local tries if that is
>>> the route we are planning to take.
>> Ok, where do you want to place the main/local tree patch then?
>>
>> Scott's L3 work logically depends upon that, and actually I think
>> Scott is sending you on vacation so that he doesn't have to rebase so
>> much :-)
>
> Yeah, I kind of figured that might be the case.  If needed I can hold
> off for a day or so while Scott gets the FIB offloading stuff in and I
> could just submit the remaining 9 plus the main/local merge patch as an
> RFC so that it can be reviewed while the offload stuff is accepted.

Holding off for a day or two would help; I think my next v4 set I'm
testing now and sending later today will stick.

I think I've had to rebase my FIB changes 3 times so far, and it's
getting harder each time because more is moving around as you peel the
onion.  But your work is awesome, so don't take it the wrong way.

I'll need you to review my v4 changes in fib_trie.c.  I had to clone
your new fib_table_flush() to make one to clear out external FIB
entries (those FIB entries that where offloaded externally).  I'm not
happy with the duplication of code, but I wasn't seeing a clean way to
break it apart.  You have a goto jumping back into the middle of a
while loop, and my tiny brain can't deal with that.  :)  I'm hoping
you can look at it and see a way to minimize duplicate code.

Thanks Alex.

-scott
