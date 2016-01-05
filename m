From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH net-next] udp_diag: fix udp_dump_one() vs SO_REUSEPORT
Date: Tue, 5 Jan 2016 17:26:05 -0500
Message-ID: <CAEfhGiwM+KDGHztLKhpyKGbUizYSY8EkK5wG78or4bj9gSLyKg@mail.gmail.com>
References: <1452024487-2909-1-git-send-email-kraigatgoog@gmail.com>
	<1452031738.8255.127.camel@edumazet-glaptop2.roam.corp.google.com>
	<1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:34750 "EHLO
	mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbcAEW0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 17:26:07 -0500
Received: by mail-lf0-f51.google.com with SMTP id y184so302740358lfc.1
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:26:07 -0800 (PST)
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com. [209.85.217.170])
        by smtp.gmail.com with ESMTPSA id f197sm16496244lff.8.2016.01.05.14.26.05
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 14:26:05 -0800 (PST)
Received: by mail-lb0-f170.google.com with SMTP id oh2so182376427lbb.3
        for <netdev@vger.kernel.org>; Tue, 05 Jan 2016 14:26:05 -0800 (PST)
In-Reply-To: <1452032534.8255.137.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 5, 2016 at 5:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2016-01-05 at 14:08 -0800, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> udp_dump_one() uses __udp4_lib_lookup() & __udp6_lib_lookup()
>> which cannot properly handle the provided cookie when SO_REUSEPORT
>> is used, as many sockets share the same 4-tuple
>>
>> Instead, let's use the provided 64bit cookie to uniquely identify
>> the socket.
>>
>> This will allow us to remove a check against skb being NULL in
>> reuseport_select_sock(), as we no longer share __udp4_lib_lookup() &
>> __udp6_lib_lookup() with packet processing path.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> ---
>
> I'll send a v2, removing the EXPORT_SYMBOL(__udp4_lib_lookup) and add a
> static qualifier. (Same for v6)
>
> Also, INET_UDP_DIAG can depends on INET_DIAG instead of "depends on
> INET_DIAG && (IPV6 || IPV6=n)"

Thanks Eric! Still reading through this, but I noticed a couple other
paths as well.  Anything that comes through the exported
udp4_lib_lookup.  Currently xt_TPROXY.c and xt_socket.c.  Though,
these could probably be changed to pass through the skb.  That may be
worth addressing in a separate patch, though...
