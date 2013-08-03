From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH] net: check net.core.somaxconn sysctl values
Date: Sat, 03 Aug 2013 14:14:48 +0400
Message-ID: <51FCD818.8040304@yandex-team.ru>
References: <20130801.141836.1104130035137318887.davem@davemloft.net> <1375454200-21303-1-git-send-email-klamm@yandex-team.ru> <20130802.151915.1964036907997678424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, raise.sail@gmail.com,
	ebiederm@xmission.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1f.mail.yandex.net ([95.108.130.40]:41254 "EHLO
	forward-corp1f.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751390Ab3HCKO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 06:14:56 -0400
In-Reply-To: <20130802.151915.1964036907997678424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03.08.2013 02:19, David Miller wrote:
> From: Roman Gushchin <klamm@yandex-team.ru>
> Date: Fri,  2 Aug 2013 18:36:40 +0400
>
>> It's possible to assign an invalid value to the net.core.somaxconn
>> sysctl variable, because there is no checks at all.
>>
>> The sk_max_ack_backlog field of the sock structure is defined as
>> unsigned short. Therefore, the backlog argument in inet_listen()
>> shouldn't exceed USHRT_MAX. The backlog argument in the listen() syscall
>> is truncated to the somaxconn value. So, the somaxconn value shouldn't
>> exceed 65535 (USHRT_MAX).
>> Also, negative values of somaxconn are meaningless.
>>
>> before:
>> $ sysctl -w net.core.somaxconn=256
>> net.core.somaxconn = 256
>> $ sysctl -w net.core.somaxconn=65536
>> net.core.somaxconn = 65536
>> $ sysctl -w net.core.somaxconn=-100
>> net.core.somaxconn = -100
>>
>> after:
>> $ sysctl -w net.core.somaxconn=256
>> net.core.somaxconn = 256
>> $ sysctl -w net.core.somaxconn=65536
>> error: "Invalid argument" setting key "net.core.somaxconn"
>> $ sysctl -w net.core.somaxconn=-100
>> error: "Invalid argument" setting key "net.core.somaxconn"
>>
>> Based on a prior patch from Changli Gao.
>>
>> Signed-off-by: Roman Gushchin <klamm@yandex-team.ru>
>> Reported-by: Changli Gao <xiaosuo@gmail.com>
>> Suggested-by: Eric Dumazet <edumazet@google.com>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Applied, thanks.

Thank you!

Regards,
Roman

> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
