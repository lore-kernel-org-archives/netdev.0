From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 4.9-rc7: (forcedeth?) BUG: sleeping function called from invalid
 context at kernel/irq/manage.c:110
Date: Tue, 29 Nov 2016 11:50:36 -0800
Message-ID: <CA+55aFyX0o9GpZfvk5UGptR6iYL0eSnHNXJBP50PByZ3qNHHzw@mail.gmail.com>
References: <alpine.LRH.2.20.1611292222200.31348@math.ut.ee>
 <CAADWXX8GM5Xdf1Of09ABXEB8eb=eVqPjHTaT7ZzcStnX8=cO_A@mail.gmail.com> <alpine.LRH.2.20.1611292309490.31348@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel list <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35179 "EHLO
        mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbcK2Tuh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:50:37 -0500
In-Reply-To: <alpine.LRH.2.20.1611292309490.31348@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 1:16 PM, Meelis Roos <mroos@linux.ee> wrote:
> [...]
>> But none of this looks new. I don't see _anything_ in any of these
>> areas that has changed since 4.8.
>>
>> Which is why I suspect you changed something in your setup wrt
>> netconsole or your kernel config?
>
> No changes that I could see. Only answered oldconfig questions, diff
> below. /etc/default/grub is from May so not changed recently. Just
> verified that 4.8.0 dmesg did not contain these warnings.

Hmm. I wonder if it might just be timing (the netpoll_poll_dev() thing
is only called conditionally, and it depends on magic details and I
guess you might just have gotten unlucky).

But it would be good if you can bisect it...

           Linus
