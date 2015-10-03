From: Andrey Vagin <avagin@openvz.org>
Subject: Re: [PATCH] net/unix: fix logic about sk_peek_offset
Date: Sat, 3 Oct 2015 22:48:05 +0300
Message-ID: <CANaxB-wPU7Kq3qvD4OUd=Dmk010JMNYOSsT1KR7y0Pmxpayhnw@mail.gmail.com>
References: <1443733536-992-1-git-send-email-avagin@gmail.com>
	<CANaxB-zvEL6WRNk2Ho7uJUVO8L=t_Nutp9Zxz=Do+Xp1JibHKw@mail.gmail.com>
	<87r3ldmplo.fsf@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f195.google.com ([209.85.217.195]:33285 "EHLO
	mail-lb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbJCTsH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Oct 2015 15:48:07 -0400
Received: by lbbpc3 with SMTP id pc3so3771077lbb.0
        for <netdev@vger.kernel.org>; Sat, 03 Oct 2015 12:48:06 -0700 (PDT)
In-Reply-To: <87r3ldmplo.fsf@bytheb.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-10-02 15:17 GMT+03:00 Aaron Conole <aconole@bytheb.org>:
> Andrey Vagin <avagin@openvz.org> writes:
>
>> 2015-10-02 0:05 GMT+03:00 Andrey Vagin <avagin@gmail.com>:
>>> From: Andrey Vagin <avagin@openvz.org>
>>>
>>> Now send with MSG_PEEK can return data from multiple SKBs.
>>>
>>> Unfortunately we take into account the peek offset for each skb,
>>> that is wrong. We need to apply the peek offset only once.
>>>
>>> In addition, the peek offset should be used only if MSG_PEEK is set=
=2E
> <<snip>>
> Agreed here, the behavior is off in the peek offset case.
>
> I was unable to apply your patch, for some reason, but will manually
> try to apply it and test.

It's strange. I've checked that this patch can be applied to
davem/net.git and next/linux-next.git,

[avagin@laptop linux-next]$ git checkout net/master
HEAD is now at 36f8daf... Merge tag 'mmc-v4.3-rc3' of
git://git.linaro.org/people/ulf.hansson/mmc
[avagin@laptop linux-next]$ wget https://patchwork.ozlabs.org/patch/525=
310/mbox/
--2015-10-03 22:46:44--  https://patchwork.ozlabs.org/patch/525310/mbox=
/
Resolving patchwork.ozlabs.org (patchwork.ozlabs.org)...
103.22.144.67, 2401:3900:2:1::2
Connecting to patchwork.ozlabs.org
(patchwork.ozlabs.org)|103.22.144.67|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/plain]
Saving to: =E2=80=98index.html=E2=80=99

index.html                                  [ <=3D>
                                                      ]   2.06K
--.-KB/s   in 0s

2015-10-03 22:46:47 (122 MB/s) - =E2=80=98index.html=E2=80=99 saved [21=
06]

[avagin@laptop linux-next]$ git am index.html
Applying: net/unix: fix logic about sk_peek_offset

>
> Thanks very much!
