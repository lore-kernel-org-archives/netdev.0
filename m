From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/4] soreuseport: define reuseport groups
Date: Tue, 22 Dec 2015 17:03:59 -0500 (EST)
Message-ID: <20151222.170359.2059237872922157454.davem@davemloft.net>
References: <1450814710-17850-2-git-send-email-kraigatgoog@gmail.com>
	<20151222.164024.1894169450945188344.davem@davemloft.net>
	<CAEfhGiyG8Y_amDZ2C8dQoQqjZJMHjTY76b=KBkTKcBtA=dhdGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kraigatgoog@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933960AbbLVWEA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 17:04:00 -0500
In-Reply-To: <CAEfhGiyG8Y_amDZ2C8dQoQqjZJMHjTY76b=KBkTKcBtA=dhdGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraigatgoog@gmail.com>
Date: Tue, 22 Dec 2015 16:58:11 -0500

> On Tue, Dec 22, 2015 at 4:40 PM, David Miller <davem@davemloft.net> wrote:
>> From: Craig Gallek <kraigatgoog@gmail.com>
>> Date: Tue, 22 Dec 2015 15:05:07 -0500
>>
>>> +     for (i = 0; i < reuse->num_socks; i++) {
>>> +             if (reuse->socks[i] == sk) {
>>> +                     reuse->socks[i] = reuse->socks[reuse->num_socks - 1];
>>> +                     reuse->num_socks--;
>>> +                     if (reuse->num_socks == 0)
>>> +                             kfree_rcu(reuse, rcu);
>>> +                     break;
>>> +             }
>>> +     }
>>
>> Don't you need to memmove() the entire rest of the array down one slot
>> when you hit the matching 'sk' in there?  I can't see how it can work
>> to only move one entry down.
> It moves the last element in the list into the slot that was just
> emptied.  You could argue that this may cause unexpected changes in
> the index -> socket mapping observed by the user, but I'm not sure
> making many socket indexes change (by sliding everything down one)
> when one is removed is a desirable behavior either.  I don't have a
> strong opinion either way though...

Thanks for explaining, I misered the code.
