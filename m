From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net v2] net: sched: do not requeue a NULL skb
Date: Mon, 11 Apr 2016 16:19:15 -0700
Message-ID: <CAM_iQpVid8=LeO31p_ZiPQkhWtgCuioUzfCdgDPatFxkWrkbCg@mail.gmail.com>
References: <1460355869-13539-1-git-send-email-larper@axis.com>
 <1460380981.6473.544.camel@edumazet-glaptop3.roam.corp.google.com>
 <570BA8C7.1000905@axis.com> <1460384551.6473.551.camel@edumazet-glaptop3.roam.corp.google.com>
 <570BC024.1070504@axis.com> <1460389951.6473.555.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAM_iQpWM0cce9PtvkenywGpvh0MEMe_0qvkKC00kYFAdFG=BxQ@mail.gmail.com>
 <1460399171.6473.562.camel@edumazet-glaptop3.roam.corp.google.com> <1460399456.6473.566.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lars Persson <lars.persson@axis.com>,
	Lars Persson <larper@axis.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f181.google.com ([209.85.161.181]:34526 "EHLO
	mail-yw0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751615AbcDKXTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 19:19:35 -0400
In-Reply-To: <1460399456.6473.566.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 11, 2016 at 11:30 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-04-11 at 11:26 -0700, Eric Dumazet wrote:
>> On Mon, 2016-04-11 at 11:02 -0700, Cong Wang wrote:
>>
>> > I am fine with either way as long as the loop stops on failure.
>
>
> Note that skb that could not be validated is already freed.
>
> So I do not see any value from stopping the loop, since
> we need to schedule the queue to avoid tx hang.
>
> Just process following skb if there is one, fact that skb is sent or
> dropped does not matter.

My point is, for example, in OOM case, we don't know processing
more SKB would make it better or worse. Maybe we really need to
check the error code to decide to continue to exit?
