From: Cong Wang <cwang@twopensource.com>
Subject: Re: NULL pointer dereference at skb_queue_tail()
Date: Mon, 5 Jan 2015 11:03:24 -0800
Message-ID: <CAHA+R7Mq=vhSCqJsE5dn7PGg39R8Nh+m1RT0F-KcoBU99GdpWA@mail.gmail.com>
References: <201412252222.HIF57826.OQFSVFFOMHLOJt@I-love.SAKURA.ne.jp>
	<201501052150.CIG69242.FFVOLQOJFHtMSO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:64210 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754309AbbAETDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 14:03:25 -0500
Received: by mail-qa0-f53.google.com with SMTP id j7so15264975qaq.40
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 11:03:24 -0800 (PST)
In-Reply-To: <201501052150.CIG69242.FFVOLQOJFHtMSO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 5, 2015 at 4:50 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Tetsuo Handa wrote:
>> I can reproduce below oops when testing Linux 3.18 with memory allocation
>> failure injection module at https://lkml.org/lkml/2014/12/25/64 .
>
> I can reliably reproduce this oops with current linux.git using memory
> allocation failure injection module. There is a possibility of memory
> corruption since this oops always occurs immediately after memory
> allocation failure within GPU/DRM code. I want to check whether
> fields of structures have expected values or not.

Looks like the skb->prev and/or skb->next in the skb queue is corrupted,
but I don't see why. We do play some magic on these pointers recently,
but it should not be related with unix socket at all.

Is it possible for you to check if this is a regression of recent kernel?
We only have few changes in unix socket recently, and I don't see they
could cause this bug.

>
>> void skb_queue_tail(struct sk_buff_head *list, struct sk_buff *newsk)
>> {
>>         unsigned long flags;
>>
>
> Could you tell me what are expected values (i.e. what BUG_ON() test
> should I try) at this location?
>

Since skb queue has its own code to do list operations, we can't
use the existing list debugging to debug this list corruption. :(
