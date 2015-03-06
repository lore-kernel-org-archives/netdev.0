From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: I can tell no FIB
Date: Thu, 05 Mar 2015 16:20:43 -0800
Message-ID: <54F8F2DB.5070901@gmail.com>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>	<54F8C802.1010706@gmail.com>	<20150305.162711.545663291988773902.davem@davemloft.net>	<54F8D249.4080404@gmail.com> <CAE4R7bB1Z_gBbaUQLXz2FRS3SSVZp__n-PNnGfX16-Apscf=YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:37107 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbbCFAUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 19:20:46 -0500
Received: by paceu11 with SMTP id eu11so32857166pac.4
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 16:20:45 -0800 (PST)
In-Reply-To: <CAE4R7bB1Z_gBbaUQLXz2FRS3SSVZp__n-PNnGfX16-Apscf=YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2015 04:07 PM, Scott Feldman wrote:
> On Thu, Mar 5, 2015 at 2:01 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 03/05/2015 01:27 PM, David Miller wrote:
>>> From: Alexander Duyck <alexander.duyck@gmail.com>
>>> Date: Thu, 05 Mar 2015 13:17:54 -0800
>>>
>>>> On 03/05/2015 12:49 PM, Scott Feldman wrote:
>>>>> Hi Alex, turns out you're required to take a mandatory week-long
>>>>> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
>>>>> week!  Take lots of pictures.
>>>>>
>>>>> -scott
>>>> Well I have one more set of 9 and then I will stop for a while.  I was
>>>> planning to send it later tonight.  Then I can probably take that
>>>> week-long vacation..
>>>>
>>>> I'm going to drop the portion of the patches I had where I was
>>>> up-levelling the key vector since I still don't have a solution for the
>>>> extra costs of insertion/deletion from the trie.  Also I don't think it
>>>> would work well with the merge of the main and local tries if that is
>>>> the route we are planning to take.
>>> Ok, where do you want to place the main/local tree patch then?
>>>
>>> Scott's L3 work logically depends upon that, and actually I think
>>> Scott is sending you on vacation so that he doesn't have to rebase so
>>> much :-)
>> Yeah, I kind of figured that might be the case.  If needed I can hold
>> off for a day or so while Scott gets the FIB offloading stuff in and I
>> could just submit the remaining 9 plus the main/local merge patch as an
>> RFC so that it can be reviewed while the offload stuff is accepted.
> Holding off for a day or two would help; I think my next v4 set I'm
> testing now and sending later today will stick.

Well the last batch of patches are out there, but there isn't any rush
on them.  If need be Dave can just leave them in review until we get the
thumbs up or down on the v4 changes since I think you and I are probably
the only two patching that region for now.  I suspect the changes
shouldn't be as bad as the past patches have been since most of it is
just reworking structures and updating the resize code.

> I think I've had to rebase my FIB changes 3 times so far, and it's
> getting harder each time because more is moving around as you peel the
> onion.  But your work is awesome, so don't take it the wrong way.

Yeah, a lot of it was pretty messy since I was having to untangle some
messed up code.

> I'll need you to review my v4 changes in fib_trie.c.  I had to clone
> your new fib_table_flush() to make one to clear out external FIB
> entries (those FIB entries that where offloaded externally).  I'm not
> happy with the duplication of code, but I wasn't seeing a clean way to
> break it apart.  You have a goto jumping back into the middle of a
> while loop, and my tiny brain can't deal with that.  :)  I'm hoping
> you can look at it and see a way to minimize duplicate code.

Just CC me on the patches and I will look them over when you submit
them.  You may want to consider just adding a flag field to
fib_table_flush call since the determining factor for dropping a
fib_alias is based on if the fib_info has the RTNH_F_DEAD flag set, you
could pass that flag to the legacy callers for fib_table_flush and pass
RTNH_F_EXTERNAL for your new call.

> Thanks Alex.
>
> -scott

No problem, as is things for me are winding down in terms of the FIB. 
I'm just flushing my backlog at this point so as long as I can get the
last 9 flushed out before net-next closes I'll be good.

- Alex
