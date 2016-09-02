From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] af_unix: split 'u->readlock' into two: 'iolock' and
 'bindlock'
Date: Fri, 2 Sep 2016 22:23:07 +0200
Message-ID: <15b63b3b-7e58-016a-2566-ccd2d55418c4@stressinduktion.org>
References: <alpine.LFD.2.20.1609021109340.4072@i7>
 <CA+55aFyFEhaOaDN9kuphgRV8sDKpV_2xB9X-kpWqMLUtX9JBtQ@mail.gmail.com>
 <20160902.121534.1390430589343316053.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: rweikusat@mobileactivedefense.com, edumazet@google.com, w@1wt.eu,
        netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58063 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751190AbcIBUXM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 16:23:12 -0400
In-Reply-To: <20160902.121534.1390430589343316053.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.09.2016 21:15, David Miller wrote:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Fri, 2 Sep 2016 11:17:18 -0700
> 
>> Oh, this was missing a
>>
>>   Reported-and-tested-by: CAI Qian <caiqian@redhat.com>
>>
>> who found the new deadlock.
>>
>> There's now *another* lockdep deadlock report by him, but that one has
>> nothing to do with networking.
>>
>> (And neither of these deadlocks will actually deadlock the machine in
>> practice, but you can trigger the lockdep reports with some odd splice
>> patterns and overlayfs use)
> 
> I read over this and can't find any problems.
> 
> The main thing I was concerned about was an I/O path that really
> expects the socket's hash not to change for whatever reason, but even
> all of the unix_find_other() calls are done outside of the mutex
> already.

Furthermore we don't allow rehashing, if the socket is "published" once,
it can only be destroyed but can't change identity during its lifetime.
IIRC this was another bug we had a while ago.
