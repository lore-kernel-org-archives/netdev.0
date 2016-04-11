From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 11:02:59 -0700
Message-ID: <CAM_iQpWM0cce9PtvkenywGpvh0MEMe_0qvkKC00kYFAdFG=BxQ@mail.gmail.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
 <570BA8C7.1000905@axis.com> <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
 <570BC024.1070504@axis.com> <1460389951.6473.555.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lars Persson <lars.persson@axis.com>,
	Lars Persson <larper@axis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:36821 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbcDKSDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 14:03:20 -0400
In-Reply-To: <1460389951.6473.555.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2016 at 8:52 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-04-11 at 17:17 +0200, Lars Persson wrote:
>>
>> On 04/11/2016 04:22 PM, Eric Dumazet wrote:
>> > On Mon, 2016-04-11 at 15:38 +0200, Lars Persson wrote:
>> >
>> >> I though it would be prudent because the queue can be non-empty even for
>> >> the case of skb=NULL. So should it be there in this patch, another patch
>> >> or not at all ?
>> >
>> > Then maybe change return code ?
>> >
>> > It seems strange that a validate_xmit_skb_list() failure stops the
>> > __qdisc_run() loop but schedules another round.
>> >
>> >
>>
>> It was suggested by Cong Wang to return 0 in order to stop the loop. Do
>> you guys agree that the loop should be stopped for such failures ? Then
>> I will put the schedule call inside the if as you proposed earlier.
>
> What are the causes of validate_xmit_skb_list() failures ?
>
> If gso segmentations fail because of memory pressure, better free more
> skbs right now.
>
> In any case, having a single test " if (skb)  " sounds better to me,
> to have a fast path.
>
> So your first patch was probably a better idea.
>
> v2 has two tests instead of one.

I am fine with either way as long as the loop stops on failure.
Folding the test "if (skb)" into one also requires to retake the spinlock.
