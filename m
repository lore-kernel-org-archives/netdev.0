From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next] myri10ge: fix truesize underestimation
Date: Thu, 20 Oct 2011 16:45:14 -0400
Message-ID: <4EA0885A.9010009@myri.com>
References: <1319141403.2854.17.camel@edumazet-laptop>  <CAMaF-rN8K3hDiwwqh_eGQ0nrxskn+7r9Rn_yDJ46aesKR77nbg@mail.gmail.com> <1319143442.2854.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jon Mason <mason@myri.com>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41006 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752471Ab1JTUpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 16:45:16 -0400
Received: by vws1 with SMTP id 1so2449704vws.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 13:45:15 -0700 (PDT)
In-Reply-To: <1319143442.2854.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/11 16:44, Eric Dumazet wrote:
> Le jeudi 20 octobre 2011 =C3=A0 15:33 -0500, Jon Mason a =C3=A9crit :
>> On Thu, Oct 20, 2011 at 3:10 PM, Eric Dumazet<eric.dumazet@gmail.com=
>  wrote:
>>> skb->truesize must account for allocated memory, not the used part =
of
>>> it. Doing this work is important to avoid unexpected OOM situations=
=2E
>>>
>>> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
>>
>> Acked-by: Jon Mason<mason@myri.com>
>
> Thanks for reviewing Jon !
>
>

Please wait a second..  I think the patch is incorrect.

There is already code in myri10ge_rx_skb_build() which
attempts to set the truesize.  However, it sets it to
the used, rather than the allocated size so it is apparently
incorrect.

I'd prefer we fix that code.

Thanks,

Drew
