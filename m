From: Tolga Ceylan <tolga.ceylan@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Sat, 26 Sep 2015 19:02:14 -0700
Message-ID: <CALmu+Sx8L5mWf3Nnbz=x0qt7pC5n5oVPRJd7dnLATVpmmO+nrA@mail.gmail.com>
References: <1443313848-751-1-git-send-email-tolga.ceylan@gmail.com>
	<877fnc7i0i.fsf@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34177 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754721AbbI0CCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 22:02:14 -0400
Received: by igcpb10 with SMTP id pb10so34871149igc.1
        for <netdev@vger.kernel.org>; Sat, 26 Sep 2015 19:02:14 -0700 (PDT)
In-Reply-To: <877fnc7i0i.fsf@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 26, 2015 at 6:44 PM, Aaron Conole <aconole@bytheb.org> wrote:
> Greetings.
>
> Tolga Ceylan <tolga.ceylan@gmail.com> writes:
>> +#define SO_REUSEPORT_LISTEN_OFF 51
>> +
> For all of these, I think the space should be tab.
>
>>       unsigned char           skc_reuseport:1;
>>+      unsigned char       skc_reuseport_listen_off:1;
>>       unsigned char           skc_ipv6only:1;
> The spacing here is wrong.
>
>> @@ -224,10 +224,13 @@ begin:
>>                               phash = inet_ehashfn(net, daddr, hnum,
>>                                                    saddr, sport);
>>                               matches = 1;
>> +                             if (sk->sk_reuseport_listen_off)
>> +                                     result = NULL;
> I am concerned here. I think you need to reset hiscore and matches as
> well, not just result.

By keeping hiscore/matches as is, I'm trying to keep the hashing consistent.
Otherwise, this would behave similar to removing a listener which
drops connections.
