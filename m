From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH] geneve: fix max_mtu setting
Date: Mon, 27 Jun 2016 09:10:56 -0700
Message-ID: <CAEh+42g1jFY8pOndJEO3eSSV_9G9nymL2WJ6a-atysJsOO90Uw@mail.gmail.com>
References: <1466915256-98925-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <CAD=hENenX+VThWkgWeqOw=kHoa2n5PePBO=WwR5uFFidAmWzfQ@mail.gmail.com> <E2E0946D-26C9-46E9-B01A-94595D9EEAF7@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zhuyj <zyjzyj2000@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: =?UTF-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50862 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbcF0QLN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 12:11:13 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 011A320222
	for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 16:11:12 +0000 (UTC)
Received: from mail-qt0-f170.google.com (mail-qt0-f170.google.com [209.85.216.170])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4EB4520109
	for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 16:11:11 +0000 (UTC)
Received: by mail-qt0-f170.google.com with SMTP id w59so24656524qtd.3
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 09:11:11 -0700 (PDT)
In-Reply-To: <E2E0946D-26C9-46E9-B01A-94595D9EEAF7@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 26, 2016 at 6:13 PM, =E4=B8=A5=E6=B5=B7=E5=8F=8C <yanhaishu=
ang@cmss.chinamobile.com> wrote:
>
>> On Jun 26, 2016, at 8:35 PM, zhuyj <zyjzyj2000@gmail.com> wrote:
>>
>> +       if (geneve->remote.sa.sa_family =3D=3D AF_INET)
>> +               max_mtu -=3D sizeof(struct iphdr);
>> +       else
>> +               max_mtu -=3D sizeof(struct ipv6hdr);
>>
>> Sorry, if sa_family is not AF_NET, it is AF_INET6?
>>
>> There is a lot of macros in include/linux/socket.h.
>>
>> Zhu Yanjun
>>
>
> There are only two enumerations AF_INET and AF_INET6 have been assign=
ed in geneve_newlink:

There's actually a third possibility: AF_UNSPEC, which is the default
if neither remote type is specified. This is used by lightweight
tunnels and should be able to work with either IPv4/v6. For the
purposes of the MTU calculation this means that the IPv4 header size
should be used to avoid disallowing potentially valid configurations.
