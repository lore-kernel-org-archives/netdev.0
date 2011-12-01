From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] netconsole: implement ipv4 tos support
Date: Thu, 1 Dec 2011 01:04:41 -0800
Message-ID: <CAHo-OoxXoZmrc0X04F0jh2ZLo5CoHTesoR7zqqLqsJ4vcNp_OQ@mail.gmail.com>
References: <1322702330-31325-1-git-send-email-zenczykowski@gmail.com>
	<20111130173435.5e63afda@nehalam.linuxnetplumber.net>
	<20111130.223703.259122584986536045.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:50585 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110Ab1LAJEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 04:04:42 -0500
Received: by ywa9 with SMTP id 9so1576128ywa.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 01:04:41 -0800 (PST)
In-Reply-To: <20111130.223703.259122584986536045.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Next they will ask for TTL as well.

Interesting suggestion, could certainly see the use, but not coming
from me... :-)

> Nope, sorry, we'll not be turning netconsole into a cluster-f*ck of
> every configuration option anyone can come up with.

More configurability is in general not a bad thing, provided that sane
defaults are provided.
Especially when the cost is small (which I'd say is the case here).

--

Side note:

The Linux kernel is in general very inconsistent in how it handles tos.
There are still tons of places where 'TOS & 0x1E' is used which has
very little meaning (long obsoleted RFC).

IPv4 TOS and IPv6 TCLASS are also not handled similarly - for example
setsockopt(SOL_IP, IP_TOS) will also update sk->sk_priority (according
to an obsolete mapping), but setsockopt(SOL_IPV6, IPV6_TCLASS) doesn't
touch sk->sk_priority.
