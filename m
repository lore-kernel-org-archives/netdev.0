From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH] tcp_cubic: fix the range of delayed_ack
Date: Wed, 30 Apr 2014 10:53:42 -0400
Message-ID: <CADVnQympVcHaFjKrHOpEjDvaXZ0ieonEmxcD1Tqxew4dM4FJDg@mail.gmail.com>
References: <5360C391.2040202@gmail.com>
	<1398867498.29914.151.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Liu Yu <allanliuyu@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:50708 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758768AbaD3Oxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 10:53:44 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so1791654wgh.2
        for <netdev@vger.kernel.org>; Wed, 30 Apr 2014 07:53:43 -0700 (PDT)
In-Reply-To: <1398867498.29914.151.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2014 at 10:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-04-30 at 17:34 +0800, Liu Yu wrote:
>> From: Liu Yu <allanyuliu@tencent.com>
>>
>> commit b9f47a3aaeab (tcp_cubic: limit delayed_ack ratio to prevent
>> divide error) try to prevent divide error, but there is still a little
>> chance that delayed_ack can reach zero. In case the param cnt get
>> negative value, then ratio+cnt would overflow and may happen to be zero.
>> As a result, min(ratio, ACK_RATIO_LIMIT) will calculate to be zero.
>>
>> In some old kernels, such as 2.6.32, there is a bug that would
>> pass negative param, which then ultimately leads to this divide error.
>>
>> commit 5b35e1e6e9c (tcp: fix tcp_trim_head() to adjust segment count
>> with skb MSS) fixed the negative param issue. However,
>> it's safe that we fix the range of delayed_ack as well,
>> to make sure we do not hit a divide by zero.
>>
>> CC: Stephen Hemminger <shemminger@vyatta.com>
>> Signed-off-by: Liu Yu <allanyuliu@tencent.com>
>> ---
>>  net/ipv4/tcp_cubic.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

Indeed, thanks!

neal
