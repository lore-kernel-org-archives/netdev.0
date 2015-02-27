From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 09:28:22 -0800
Message-ID: <CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	<1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<54F09A95.8000507@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34213 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751334AbbB0R2X convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:28:23 -0500
Received: by pabrd3 with SMTP id rd3so24236589pab.1
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 09:28:23 -0800 (PST)
In-Reply-To: <54F09A95.8000507@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2015 at 8:25 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 27/02/2015 09:01, Eric Dumazet a =C3=A9crit :
>
>> On Thu, 2015-02-26 at 22:32 -0800, Cong Wang wrote:
>>>
>>> We can allocate the peer netns id when creating the link
>>> instead of when dumping the link.
>>>
>>> This fixes the following kernel warning:
>>>
>>>   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>   [ INFO: suspicious RCU usage. ]
>>>   3.19.0+ #805 Tainted: G        W
>>>   -------------------------------
>>>   include/linux/rcupdate.h:538 Illegal context switch in RCU read-s=
ide
>>> critical section!
>>>
>>>   other info that might help us debug this:
>>
>>
>> This looks very complicated, why even bother ?
>>
>> I gave an obvious patch fixing root cause, I have no idea why you pr=
efer
>> over engineering this.
>>
>> If you believe allocating peer netns id is required at link creation
>> time, you should explain why.


I don't understand why you think this is over engineering,
clearly it is normal to allocate resources in newlink rather than
dumping. Look at other resources we allocate in newlink.


>>
>> BTW, (void)peernet2id(dev_net(dev), src_net) can fail, and your fix =
is
>> not complete anyway.
>
> That's true. The patch does not cover the following case:
> ip link add foo type bar
> ip link set foo netns netns1
>
> In this case, the second command will call dev_change_net_namespace()=
 and
> the
> id will not be allocated.

Then call it in do_setlink(). This is not a reason we _have to_
allocate it in dumping.

>
> I think Eric's patch is simpler and less error-prone.
>

Sure, he introduced this rcu read lock from the very beginning.
