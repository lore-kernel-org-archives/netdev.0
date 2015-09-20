From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v2] [net] af_unix: return data from multiple SKBs on recv() with MSG_PEEK flag
Date: Sun, 20 Sep 2015 15:38:38 -0400
Message-ID: <87d1xc7uf5.fsf@bytheb.org>
References: <1442740705-16452-1-git-send-email-aconole@bytheb.org>
	<1442767564.29850.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<87twqo7vub.fsf@bytheb.org>
	<1442776905.29850.37.camel@edumazet-glaptop2.roam.corp.google.com>
	<87h9mo7ui9.fsf@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain
To: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:36510 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755421AbbITTik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 15:38:40 -0400
Received: by qgx61 with SMTP id 61so75381499qgx.3
        for <netdev@vger.kernel.org>; Sun, 20 Sep 2015 12:38:39 -0700 (PDT)
In-Reply-To: <87h9mo7ui9.fsf@bytheb.org> (Aaron Conole's message of "Sun, 20
	Sep 2015 15:36:46 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Resending, I accidentally dropped the list.

> Eric Dumazet <eric.dumazet@gmail.com> writes:
>
>> On Sun, 2015-09-20 at 15:07 -0400, Aaron Conole wrote:
>>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>> 
>>> > On Sun, 2015-09-20 at 05:18 -0400, Aaron Conole wrote:
>>> >> From: Aaron Conole <aaron@bytheb.org>
>>> >> 
>>> >
>>> > I am wondering what this is expected to do, and how this code would
>>> > possibly not trigger a crash.
>>> Are you suspecting it should crash from a possible double-lock case?
>>> On line 2125, there is an unconditional unlock, which should be 
>>> guaranteeing that there is no longer a condition to 'double lock' the
>>> socket.
>>
>> Not at all.
>>
>> I am suggesting there is a big difference between
>>
>> unix_state_lock(&sk);
>>
>> and
>>
>> unix_state_lock(sk);
>>
>> Can you see it ?

Wow!

That's an excellent catch, thank you! I did test the originally
submitted patch, and got no oops, bug, panic, etc (I usually have
panic_on_oops set to 1 when first testing new code).

I guess I got very lucky, somehow. I'll change this, and make sure
to retest.

I will also try to enhance the python case attached to the bug to
include a filepointer as well, and will repost a v3 when I have done
this.

Thanks,
-Aaron
