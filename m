From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next 1/4] soreuseport: define reuseport groups
Date: Tue, 22 Dec 2015 16:58:11 -0500
Message-ID: <CAEfhGiyG8Y_amDZ2C8dQoQqjZJMHjTY76b=KBkTKcBtA=dhdGQ@mail.gmail.com>
References: <1450814710-17850-1-git-send-email-kraigatgoog@gmail.com>
	<1450814710-17850-2-git-send-email-kraigatgoog@gmail.com>
	<20151222.164024.1894169450945188344.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f194.google.com ([209.85.217.194]:34513 "EHLO
	mail-lb0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933296AbbLVV6O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 16:58:14 -0500
Received: by mail-lb0-f194.google.com with SMTP id jk7so241373lbc.1
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 13:58:13 -0800 (PST)
Received: from mail-lf0-f51.google.com (mail-lf0-f51.google.com. [209.85.215.51])
        by smtp.gmail.com with ESMTPSA id r199sm4131374lfg.21.2015.12.22.13.58.11
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 13:58:12 -0800 (PST)
Received: by mail-lf0-f51.google.com with SMTP id z124so132290585lfa.3
        for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 13:58:11 -0800 (PST)
In-Reply-To: <20151222.164024.1894169450945188344.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 22, 2015 at 4:40 PM, David Miller <davem@davemloft.net> wrote:
> From: Craig Gallek <kraigatgoog@gmail.com>
> Date: Tue, 22 Dec 2015 15:05:07 -0500
>
>> +     for (i = 0; i < reuse->num_socks; i++) {
>> +             if (reuse->socks[i] == sk) {
>> +                     reuse->socks[i] = reuse->socks[reuse->num_socks - 1];
>> +                     reuse->num_socks--;
>> +                     if (reuse->num_socks == 0)
>> +                             kfree_rcu(reuse, rcu);
>> +                     break;
>> +             }
>> +     }
>
> Don't you need to memmove() the entire rest of the array down one slot
> when you hit the matching 'sk' in there?  I can't see how it can work
> to only move one entry down.
It moves the last element in the list into the slot that was just
emptied.  You could argue that this may cause unexpected changes in
the index -> socket mapping observed by the user, but I'm not sure
making many socket indexes change (by sliding everything down one)
when one is removed is a desirable behavior either.  I don't have a
strong opinion either way though...
