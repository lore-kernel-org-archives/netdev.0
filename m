From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [net-next PATCH 0/4] fixup IFF_NO_QUEUE conversion
Date: Tue, 1 Sep 2015 09:52:41 +0200
Message-ID: <CAMuHMdWEoCrFuVmFUUWVv8dhV_WHtq9mzx_emKBUYwTYUhDniw@mail.gmail.com>
References: <1440703299-21243-1-git-send-email-phil@nwl.cc>
	<20150827.171510.531165980750627399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Phil Sutter <phil@nwl.cc>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:33524 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318AbbIAHwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 03:52:42 -0400
Received: by obcji4 with SMTP id ji4so17913313obc.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 00:52:41 -0700 (PDT)
In-Reply-To: <20150827.171510.531165980750627399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 2:15 AM, David Miller <davem@davemloft.net> wrote:
>> This series serves two purposes:
>>
>> On one hand it fixes a quite embarrassing bug around the warning I added for
>> drivers still setting tx_queue_len = 0 to achieve noqueue operation. It turned
>> out to be quite useless as due to using alloc_netdev(), many in-kernel drivers
>> fell into the trap by accident, as well. Instead this place serves pretty well
>> as a sanitizing point to set IFF_NO_QUEUE for drivers not initializing
>> tx_queue_len, which in turn allows to drop all special treatment of the latter
>> being zero since that can not happen anymore without IFF_NO_QUEUE being set.
>>
>> On the other hand, it provides a better solution for Eric Dumazet's concern
>> regarding how to assign noqueue to an interface which does not default to it
>> already. In order to make this possible, noqueue is being registered so users
>> can 'tc qd add dev eth0 root noqueue'. In addition, it resolves the ugly
>> situation of 'tc qd show' not showing noqueue. Finally, the former changes
>> allow for some code cleanup.
>
> Seems reasonable, series applied, thanks Phil.

Thanks, the warning is gone.

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
