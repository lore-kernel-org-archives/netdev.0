From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Fri, 20 Dec 2013 16:12:59 -0800
Message-ID: <CAM_iQpXcK26T1zrg0bOMfay4PP2HU3cuuRi9JyKBTZG8XY4fZg@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<CAM_iQpXgRzPLp=qyD2pYC=J-=xRqDqVRAxm=grZJDF2ZuCsSfw@mail.gmail.com>
	<1387583967.19078.476.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:61948 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab3LUAM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 19:12:59 -0500
Received: by mail-ob0-f172.google.com with SMTP id gq1so3443300obb.17
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 16:12:59 -0800 (PST)
In-Reply-To: <1387583967.19078.476.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 3:59 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2013-12-20 at 15:49 -0800, Cong Wang wrote:
>> On Thu, Dec 19, 2013 at 5:34 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > tcf_match_indev() is called in fast path, it is not wise to
>> > search for a netdev by ifindex and then compare by its name,
>> > just compare the ifindex.
>> >
>> > This will also save some bytes from the core struct of u32.
>> >
>> > Cc: Jamal Hadi Salim <jhs@mojatatu.com>
>> > Cc: David S. Miller <davem@davemloft.net>
>> > Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>
>>
>> Jamal, any comments on this patch itself?
>
> How device renaming (dev_change_name()) is handled ?
>
>

Good point.

Before my patch, when the dev name gets changes, indev will not
be matched any more. After my patch, it can still be matched
and will be displayed with the new name (ifindex doesn't change).

So, I think we probably need the latter behavior, otherwise we
have to rename the indev manually too in order to match its new
name.
