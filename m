From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 9 Sep 2010 06:42:22 +0000
Message-ID: <20100909064222.GA6951@ff.dom.local>
References: <20100908.213059.98904271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:39103 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526Ab0IIGmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 02:42:32 -0400
Received: by bwz11 with SMTP id 11so850392bwz.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 23:42:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100908.213059.98904271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-09 06:30, David Miller wrote:
> From: Jesse Gross <jesse@nicira.com>
> Date: Wed, 8 Sep 2010 16:49:27 -0700
> 
>> On Wed, Sep 8, 2010 at 3:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> Use cmpxchg() to get rid of spinlocks in inet_add_protocol() and
>>> friends.
>>>
>>> inet_protos[] & inet6_protos[] are moved to read_mostly section
>>>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>
>> What's the benefit to this?  It's hard to imagine that add/deleting
>> protocols is highly contended.  On the other hand, a simple spinlock
>> is very easy to look at and verify correct, while this takes a little
>> more thought.
> 
> Smaller data section is the benefit, thus less cache pressure there.
> 
Of course, each case is different, but generally I understand Jesse's
concern. Smaller data section argument shouldn't be enough. There is
some reason we do it in C not asm, and there is some cost of
unreadable code too.

Jarek P.
