From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ppp: add 64 bit stats
Date: Tue, 24 Jul 2012 08:22:34 +0200
Message-ID: <1343110954.2626.11040.camel@edumazet-glaptop>
References: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
	 <1343020585.2626.10054.camel@edumazet-glaptop>
	 <CABF+-6WHqzXhvv9etdAqsamZirbWxWJEsnU-CQ1H8tvynCTOZA@mail.gmail.com>
	 <1343059184.2626.11027.camel@edumazet-glaptop>
	 <CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Kevin Groeneveld <kgroeneveld@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:53168 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363Ab2GXGWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 02:22:39 -0400
Received: by bkwj10 with SMTP id j10so5952590bkw.19
        for <netdev@vger.kernel.org>; Mon, 23 Jul 2012 23:22:38 -0700 (PDT)
In-Reply-To: <CABF+-6Vko_T2RCsk1KVouB8a+8Ms_aLEoA-Xet1nxB8bnZAxMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-07-23 at 21:53 -0400, Kevin Groeneveld wrote:
> On Mon, Jul 23, 2012 at 11:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> Would proper synchronization in this case just be wrapping the updates
> >> in a spin_lock/spin_unlock?
> >
> > Would be fine (if the proper BH safe variant is used), or you could also
> > use atomic64_t.
> 
> Which would you recommend, spin locks or atomic64_t?
> 
> atomic64_t seems like it would be simpler.

Simpler but a bit more expensive when two counters are changed at the
same time.

(two atomic ops instead of a single one for the spinlock)
