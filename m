From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: reset timer after any SYNACK retransmit
Date: Mon, 29 Apr 2013 15:13:34 -0700
Message-ID: <CAK6E8=fKRMUxPvvbdoWdG0HgsSFAM0rQZFbP=EtSg2QM=qecsA@mail.gmail.com>
References: <1367261091-28052-1-git-send-email-ycheng@google.com> <20130429.151748.2089724181218333468.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:40484 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757025Ab3D2WNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 18:13:55 -0400
Received: by mail-lb0-f172.google.com with SMTP id o10so1291299lbi.3
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 15:13:54 -0700 (PDT)
In-Reply-To: <20130429.151748.2089724181218333468.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 29, 2013 at 12:17 PM, David Miller <davem@davemloft.net> wrote:
> From: Yuchung Cheng <ycheng@google.com>
> Date: Mon, 29 Apr 2013 11:44:51 -0700
>
>> Linux immediately returns SYNACK on (spurious) SYN retransmits, but
>> keeps the SYNACK timer running independently. Thus the timer may
>> fire right after the SYNACK retransmit and causes a SYN-SYNACK
>> cross-fire burst.
>>
>> Adopt the fast retransmit/recovery idea in established state by
>> re-arming the SYNACK timer after the fast (SYNACK) retransmit. The
>> timer may fire late up to 500ms due to the current SYNACK timer wheel,
>> but it's OK to be conservative when network is congested. Eric's new
>> listener design should address this issue.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>
> Applied.
>
> Maybe -stable material?
Should be fine for -stable too. Thanks.
