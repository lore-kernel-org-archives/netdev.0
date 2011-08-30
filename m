From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: IP_TRANSPARENT requires CAP_NET_ADMIN - why?
Date: Tue, 30 Aug 2011 14:45:54 -0700
Message-ID: <CAHo-Ooz-0wt4-3oXZBeEmLTSom5qUxhXhP4MDUrSz322OTGa9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:53081 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365Ab1H3Vpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 17:45:55 -0400
Received: by gwaa12 with SMTP id a12so49611gwa.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:45:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm curious why transparent sockets [setsockopt(IP{,V6}_TRANSPARENT),
ie. inet_sk(sk)->transparent bit] require CAP_NET_ADMIN privileges.

Wouldn't CAP_NET_RAW be more appropriate?

Looks to me like CAP_NET_RAW is all about raw sockets.
Transparent sockets are dangerous because they effectively allow spoofing.
But this seems to be the same sort of thing that CAP_NET_RAW protects
against.

Is there something I'm missing?
Is there any reason why having CAP_NET_RAW privs shouldn't allow one
to set the transparent bit on a socket?

Would people be opposed to relaxing the check on setting sk->transparent
to be either CAP_NET_ADMIN or CAP_NET_RAW?

Thanks,
Maciej
