From: Dennis Chen <kernel.org.gnu@gmail.com>
Subject: Re: [Question] What's the noop_qdisc introduced for in the kernel?
Date: Wed, 31 Dec 2014 15:31:42 +0800
Message-ID: <CA+U0gVj3EGGR_FCG0sALB7tE4j=Mex6EEFctSx=BJvyfJ-MBOw@mail.gmail.com>
References: <CA+U0gVi=DTpz-Givbrs771+KYz8EE1ABdy2oO38q4LR9fG37YQ@mail.gmail.com>
 <CAHA+R7O_ypxh4DjQ1eeKZyGFpYbKQAgKkEjrmk400Ud+zLeEow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36987 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbaLaHcE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 02:32:04 -0500
Received: by mail-pd0-f172.google.com with SMTP id y13so20611081pdi.3
        for <netdev@vger.kernel.org>; Tue, 30 Dec 2014 23:32:03 -0800 (PST)
In-Reply-To: <CAHA+R7O_ypxh4DjQ1eeKZyGFpYbKQAgKkEjrmk400Ud+zLeEow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 4:15 AM, Cong Wang <cwang@twopensource.com> wrote:
> On Tue, Dec 30, 2014 at 1:23 AM, Dennis Chen <kernel.org.gnu@gmail.com> wrote:
>> After google and the code reading, seems this Qdisc instance is only
>> used for the initialization purpose, I can't find the reason that this
>> object introduced in the kernel. Does anybody know what the historical
>> reason is for this invention? the purpose or the benefit for this
>> Qdisc object?
>>
>
> Not just for initialization, it is kinda a null qdisc when
> the previous qdisc gets removed:
>
>         /* ... and graft new one */
>         if (qdisc == NULL)
>                 qdisc = &noop_qdisc;
>
> or the entire device is not activated yet. It guarantees no
> packets can be sent out via this qdisc.

Thanks Cong, got it. The device will use the noop_qdisc when it's not
activated yet...

BTW, do you have some methods to recommend if I want to find the
initial codes that introduce the noop_qdisc first in the kernel? I
tried to search the LKML archives and google, but seems it's not easy
to do that

-- 
Den
