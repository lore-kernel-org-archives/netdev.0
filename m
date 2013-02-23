From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH 1/2] sock_diag: Fix out-of-bounds access to sock_diag_handlers[]
Date: Sat, 23 Feb 2013 20:10:33 +0100
Message-ID: <CA+rthh88yDcHSO6bGa18=6ehO=2E50KpDka7LBo9MMPvV0+VSA@mail.gmail.com>
References: <1361618028-9024-1-git-send-email-minipli@googlemail.com>
	<1361618028-9024-2-git-send-email-minipli@googlemail.com>
	<1361640939.6781.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Dave Jones <davej@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:39436 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757580Ab3BWTKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 14:10:35 -0500
Received: by mail-la0-f50.google.com with SMTP id ec20so1529239lab.23
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2013 11:10:33 -0800 (PST)
In-Reply-To: <1361640939.6781.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 23, 2013 at 6:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2013-02-23 at 12:13 +0100, Mathias Krause wrote:
>> Userland can send a netlink message requesting SOCK_DIAG_BY_FAMILY
>> with a family greater or equal then AF_MAX -- the array size of
>> sock_diag_handlers[]. The current code does not test for this
>> condition therefore is vulnerable to an out-of-bound access opening
>> doors for a privilege escalation.
>>
>> Signed-off-by: Mathias Krause <minipli@googlemail.com>
>> ---
>>  net/core/sock_diag.c |    3 +++
>>  1 file changed, 3 insertions(+)
>
> Thanks for fixing this.
>
> It seems trinity didnt catch it !

For trinity to catch that one, trinity needs to generate a valid
netlink request on a PF_NETLINK socket with protocol
NETLINK_SOCK_DIAG. Very unlikely. Especially the sanity checks in
netlink_rcv_skb() will probably filter invalid messages before they
reach any interesting code. But if trinity would have support for
generating netlink messages, then, yes, it should probably have found
that bug easily. It's in there for ages, now ;)

>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
>

Thanks,
Mathias
