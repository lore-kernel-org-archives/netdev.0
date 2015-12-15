From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Tue, 15 Dec 2015 10:21:52 -0800
Message-ID: <1450203712.8474.46.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1443320655.3273.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34PkfKS47_FxuqwDbqP9P0C5J7YRR5e_-BLjfkPwPRgXw@mail.gmail.com>
	 <1447222769.17135.92.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37FOq+JVs8LKh5ezR9JhATrz2=NhmbEYPUxUt8Cyb9xaw@mail.gmail.com>
	 <1447262610.17135.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S37B4mGqYe63JkLmPeQNuOX_WMK2NHaOe7Dtt79Nv9Mo4g@mail.gmail.com>
	 <1447267424.17135.115.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447290541.22599.11.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151215161456.GA3182@1wt.eu>
	 <1450199424.8474.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151215174346.GA3187@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35071 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933659AbbLOSVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 13:21:54 -0500
Received: by mail-pf0-f172.google.com with SMTP id 63so8963060pff.2
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 10:21:54 -0800 (PST)
In-Reply-To: <20151215174346.GA3187@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-15 at 18:43 +0100, Willy Tarreau wrote:

> Ah ? but what does it bring in this case ? I'm not seeing it used
> anywhere on a listening socket. The code took care of not breaking
> them though (ie they still accept if no other socket shows up with
> a higher score). Otherwise we'll have to switch to Tolga's patch,
> unless we find another socket option that can safely be combined
> and which makes sense (I often find it better not to make userland
> depend on new updates of includes when possible).

Socket options set on the listener before the accept() are inherited.

Applications wanting SO_LINGER special settings on all their sockets can
use a single system call right before listen().

Some servers having to deal with TIME_WAIT proliferation very often use
SO_LINGER with timeout 0
