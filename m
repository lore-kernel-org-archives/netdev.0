From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: use igb_adapter->io_addr instead
 of e1000_hw->hw_addr
Date: Tue, 8 Nov 2016 10:32:10 -0800 (PST)
Message-ID: <alpine.NEB.2.20.17.1611081030000.6177@chris.i8u.org>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com> <20161108164214.GF31855@calimero.vinschen.de> <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: Cao jin <caoj.fnst@cn.fujitsu.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, linux-kernel@vger.kernel.org,
        izumi.taku@jp.fujitsu.com
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.i8u.org ([75.148.87.25]:25984 "EHLO chris.i8u.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752046AbcKHScM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Nov 2016 13:32:12 -0500
In-Reply-To: <alpine.NEB.2.20.17.1611080910530.6177@chris.i8u.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Nov 2016, Hisashi T Fujinaka wrote:

>> Incidentally we're just looking for a solution to that problem too.
>> Do three patches to fix the same problem at rougly the same time already
>> qualify as freak accident?
>> 
>> FTR, I attached my current patch, which I was planning to submit after
>> some external testing.
>> 
>> However, all three patches have one thing in common:  They workaround
>> a somewhat dubious resetting of the hardware address to NULL in case
>> reading from a register failed.
>> 
>> That makes me wonder if setting the hardware address to NULL in
>> rd32/igb_rd32 is really such a good idea.  It's performed in a function
>> which return value is *never* tested for validity in the calling
>> functions and leads to subsequent crashes since no tests for hw_addr ==
>> NULL are performed.
>> 
>> Maybe commit 22a8b2915 should be reconsidered?  Isn't there some more
>> graceful way to handle the "surprise removal"?
>
> Answering this from my home account because, well, work is Outlook.
>
> "Reconsidering" would be great. In fact, revert if if you'd like. I'm
> uncertain that the surprise removal code actually works the way I
> thought previously and I think I took a lot of it out of my local code.
>
> Unfortuantely I don't have any equipment that I can use to reproduce
> surprise removal any longer so that means I wouldn't be able to test
> anything. I have to defer to you or Cao Jin.

Whoops. Never mind. I was just told that I had a bug that Alex Duyck and
Cao Jin just fixed. I'd stick to listening to Alex.

-- 
Hisashi T Fujinaka - htodd@twofifty.com
