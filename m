From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net 1/3] inet_diag: fix oops for IPv4 AF_INET6 TCP
 SYN-RECV state
Date: Sun, 9 Dec 2012 22:40:34 -0500
Message-ID: <CADVnQykj8NN16ku2h3_RYDFJ_kUgp5amgw1F=N8CPwF8qVVdow@mail.gmail.com>
References: <1355031803-14547-1-git-send-email-ncardwell@google.com>
	<20121209.190129.2104270281417362831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <edumazet@google.com>, Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:53136 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503Ab2LJDke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Dec 2012 22:40:34 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so7119019ieb.33
        for <netdev@vger.kernel.org>; Sun, 09 Dec 2012 19:40:34 -0800 (PST)
In-Reply-To: <20121209.190129.2104270281417362831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 9, 2012 at 7:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Neal Cardwell <ncardwell@google.com>
> Date: Sun,  9 Dec 2012 00:43:21 -0500
>
>> Fix inet_diag to be aware of the fact that AF_INET6 TCP connections
>> instantiated for IPv4 traffic and in the SYN-RECV state were actually
>> created with inet_reqsk_alloc(), instead of inet6_reqsk_alloc(). This
>> means that for such connections inet6_rsk(req) returns a pointer to a
>> random spot in memory up to roughly 64KB beyond the end of the
>> request_sock.
>>
>> With this bug, for a server using AF_INET6 TCP sockets and serving
>> IPv4 traffic, an inet_diag user like `ss state SYN-RECV` would lead to
>> inet_diag_fill_req() causing an oops or the export to user space of 16
>> bytes of kernel memory as a garbage IPv6 address, depending on where
>> the garbage inet6_rsk(req) pointed.
>>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>
> Applied.

Thanks, David.

neal
