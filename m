From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: abort orphan sockets stalling on zero
 window probes
Date: Mon, 29 Sep 2014 12:17:52 -0700
Message-ID: <CAK6E8=ee8=hjQrYZNAKgs2YkCGEMSfzrLpu_Mr5joo987Y6M8Q@mail.gmail.com>
References: <1411444333-6013-1-git-send-email-ycheng@google.com> <20140926.155611.954320324745536887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Andrey Dmitrov <andrey.dmitrov@oktetlabs.ru>,
	Neal Cardwell <ncardwell@google.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:49909 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754122AbaI2TSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 15:18:33 -0400
Received: by mail-ie0-f174.google.com with SMTP id tr6so2217161ieb.33
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 12:18:32 -0700 (PDT)
In-Reply-To: <20140926.155611.954320324745536887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 12:56 PM, David Miller <davem@davemloft.net> wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Mon, 22 Sep 2014 20:52:13 -0700
>
>> -
>> +             if (!alive && icsk->icsk_backoff >= max_probes)
>> +                     goto abort;
>>               if (tcp_out_of_resources(sk, alive || icsk->icsk_probes_out <= max_probes))
>>                       return;
>
> This new logic means that the second argument to tcp_out_of_resources()
> will always be 'true'.
>
> Please make that explicit, because the code is confusing otherwise.
>
> Also perhaps target this for the 'net' tree?
Sure I'll clear up the patch.

Net-next is probably a better target b/c it's more of a feature patch.
It also changes TCP_USER_TIMEOUT semantics slightly.

Thanks!

>
> Thanks.
