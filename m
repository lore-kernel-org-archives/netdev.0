From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: htb: do not mix 1ns and 64ns time units
Date: Tue, 04 Jun 2013 13:50:31 -0700
Message-ID: <1370379031.24311.226.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <20130604141342.00c8eb9f@redhat.com>
	 <1370359133.24311.208.camel@edumazet-glaptop>
	 <1370361306.24311.214.camel@edumazet-glaptop>
	 <1370361727.24311.215.camel@edumazet-glaptop>
	 <1370365908.24311.222.camel@edumazet-glaptop>
	 <20130604222135.67eedab8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Benc <jbenc@redhat.com>, David Miller <davem@redhat.com>,
	j.vimal@gmail.com, Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, bloat@lists.bufferbloat.net,
	Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f181.google.com ([209.85.214.181]:55416 "EHLO
	mail-ob0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab3FDUuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 16:50:35 -0400
Received: by mail-ob0-f181.google.com with SMTP id 16so1242097obc.40
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 13:50:34 -0700 (PDT)
In-Reply-To: <20130604222135.67eedab8@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 22:21 +0200, Jesper Dangaard Brouer wrote:

> But how is this 64-bit usage going to affect performance for smaller
> ARM/MIPS based home routers, where shaping at these low rates is more
> relevant?  (I'm just asking because I don't know, and just test this
> on a 24-CPU machine).

Well, by definition shaping at low rates is mostly using the timer
infra, and its already 64bit. You'll hardly spend time in HTB.

Note that psched_time_t is already 64bit wide.

Only psched_tdiff_t is 'unsigned long', and the change I made in this
patch will not change performance even on 32bit hosts.
