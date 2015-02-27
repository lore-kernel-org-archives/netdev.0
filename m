From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 17:25:57 +0100
Message-ID: <54F09A95.8000507@6wind.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com> <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:45605 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbB0Q0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 11:26:00 -0500
Received: by wgha1 with SMTP id a1so21401295wgh.12
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 08:25:59 -0800 (PST)
In-Reply-To: <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/02/2015 09:01, Eric Dumazet a =C3=A9crit :
> On Thu, 2015-02-26 at 22:32 -0800, Cong Wang wrote:
>> We can allocate the peer netns id when creating the link
>> instead of when dumping the link.
>>
>> This fixes the following kernel warning:
>>
>>   =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>   [ INFO: suspicious RCU usage. ]
>>   3.19.0+ #805 Tainted: G        W
>>   -------------------------------
>>   include/linux/rcupdate.h:538 Illegal context switch in RCU read-si=
de critical section!
>>
>>   other info that might help us debug this:
>
> This looks very complicated, why even bother ?
>
> I gave an obvious patch fixing root cause, I have no idea why you pre=
fer
> over engineering this.
>
> If you believe allocating peer netns id is required at link creation
> time, you should explain why.
>
> BTW, (void)peernet2id(dev_net(dev), src_net) can fail, and your fix i=
s
> not complete anyway.
That's true. The patch does not cover the following case:
ip link add foo type bar
ip link set foo netns netns1

In this case, the second command will call dev_change_net_namespace() a=
nd the
id will not be allocated.

I think Eric's patch is simpler and less error-prone.

=46WIW, I will be off for one week and probably without any internet ac=
cess ;-)

Regards,
Nicolas
