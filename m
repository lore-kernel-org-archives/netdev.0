From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net] netns: avoid allocating idr when dumping info
Date: Fri, 27 Feb 2015 18:48:59 +0100
Message-ID: <54F0AE0B.5080101@6wind.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>	<1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>	<54F09A95.8000507@6wind.com> <CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:45937 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbbB0RtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:49:02 -0500
Received: by wgha1 with SMTP id a1so21833516wgh.12
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 09:49:01 -0800 (PST)
In-Reply-To: <CAM_iQpUPQVodJRGmf=GYOVK+R_84w-+yDtqyHCJGbCDH0hb44A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/02/2015 18:28, Cong Wang a =C3=A9crit :
> On Fri, Feb 27, 2015 at 8:25 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> Le 27/02/2015 09:01, Eric Dumazet a =C3=A9crit :
>>
>>> On Thu, 2015-02-26 at 22:32 -0800, Cong Wang wrote:
[snip]
>>>
>>> BTW, (void)peernet2id(dev_net(dev), src_net) can fail, and your fix=
 is
>>> not complete anyway.
>>
>> That's true. The patch does not cover the following case:
>> ip link add foo type bar
>> ip link set foo netns netns1
>>
>> In this case, the second command will call dev_change_net_namespace(=
) and
>> the
>> id will not be allocated.
>
> Then call it in do_setlink(). This is not a reason we _have to_
> allocate it in dumping.
Sure, but that just shows the 'over engineering' side ;-)
The reason to allocate it in dumping is that you need it in dumping, no=
t before ;-)
