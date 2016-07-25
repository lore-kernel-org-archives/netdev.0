From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] net: neigh: disallow state transition DELAY->STALE in neigh_update()
Date: Mon, 25 Jul 2016 21:45:39 +0900
Message-ID: <CAPA1RqD4Zf5k0HAZNbQCBcb36v6Rhj3PiQkMO+Dm_NUB=2d8Gw@mail.gmail.com>
References: <alpine.LFD.2.11.1607220954060.1764@ja.home.ssi.bg>
 <20160722.124757.283248020246505940.hchunhui@mail.ustc.edu.cn>
 <e0d3e238-312e-a0e2-9501-29beb7e2ef27@miraclelinux.com> <20160725.081349.445701096084716570.hchunhui@mail.ustc.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ja@ssi.bg, David Miller <davem@davemloft.net>,
	dsa@cumulusnetworks.com, nicolas.dichtel@6wind.com,
	roopa@cumulusnetworks.com, rshearma@brocade.com,
	dbarroso@fastly.com, martinbj2008@gmail.com, rick.jones2@hp.com,
	koct9i@gmail.com, edumazet@google.com, tgraf@suug.ch,
	ebiederm@xmission.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	network dev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Chunhui He <hchunhui@mail.ustc.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35914 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbcGYMpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 08:45:40 -0400
Received: by mail-io0-f179.google.com with SMTP id b62so160004399iod.3
        for <netdev@vger.kernel.org>; Mon, 25 Jul 2016 05:45:40 -0700 (PDT)
In-Reply-To: <20160725.081349.445701096084716570.hchunhui@mail.ustc.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2016-07-25 17:13 GMT+09:00 Chunhui He <hchunhui@mail.ustc.edu.cn>:
>>> The NEIGH_UPDATE_F_WEAK_OVERRIDE is confusing to me, so I choose not to deal
>>> with the flag.
>>
>> IPv6 depends on WEAK_OVERRIDE.  Please do not change.
>>
>
> It seems like IPv6 always sets WEAK_OVERRIDE.
>

Yes.

> As Julian said, maybe there is no good reason to set NUD_STALE for any state
> that is NUD_VALID if address is not changed, even WEAK_OVERRIDE is not set.
> So we may eliminate WEAK_OVERRIDE in that branch.
>
> I think this change should not break IPv6.

OK, following blocks are "no-op" and we will get same result.

Well, please do not try changing several things at the same time and
you could say:

if (ladder == neigh->ha && new == NUD_STALE &&
    !(flags & NUD_UPDATE_F_ADMIN))
        new = old;

I think I tried to maintain our traditional IPv4 behavior (e.g. as of
2.2 era), BTW...

--yoshfuji
