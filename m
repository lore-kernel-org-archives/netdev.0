From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH next] r8169: add support for Byte Queue Limits
Date: Tue, 30 Sep 2014 21:57:01 -0700
Message-ID: <CA+mtBx8QuNYwrGQRmnEaj80+W6S2n4VXR-Jiis9e-yAv3aHHJw@mail.gmail.com>
References: <1412024209-25468-1-git-send-email-fw@strlen.de>
	<CA+mtBx95KFr=3h_TZWBeM6e7EF4sKAmjRpz5vLxGwi8xC+qQuw@mail.gmail.com>
	<20140929211158.GA11633@breakpoint.cc>
	<CA+mtBx8rpELodiiez8LkKupKBr9ynbQhrmAq8tcD4QKXHNjyaw@mail.gmail.com>
	<20140930074259.GC11709@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:39598 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859AbaJAE5C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 00:57:02 -0400
Received: by mail-ie0-f174.google.com with SMTP id tr6so51683ieb.33
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 21:57:01 -0700 (PDT)
In-Reply-To: <20140930074259.GC11709@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 30, 2014 at 12:42 AM, Florian Westphal <fw@strlen.de> wrote:
> Tom Herbert <therbert@google.com> wrote:
>> Watch inflight and limit in the byte_queue_limits for the queue.
>> inflight must always go back to zero when link goes idle.
>
> Yes, inflight goes to 0 when link is idle.
>
> Output of
> while true; do
>     for n in inflight limit; do
>       echo -n $n\ ; cat $n;
>       done; sleep 1;
> done
>
> during netperf run, 100mbit peer:
>
> inflight 0
> limit 3028
> inflight 6056
> limit 4542
> [ no changes during test ]
> limit 4542
> inflight 3028
> limit 6122
> inflight 0
> limit 6122
> [ changed cable to 1gbit peer, restart netperf ]
> inflight 37850
> limit 36336
> inflight 33308
> limit 31794
> inflight 33308
> limit 31794
> inflight 27252
> limit 25738
> [ no changes during test ]
> inflight 27252
> limit 25738
> inflight 0
> limit 28766
> [ change cable to 100mbit peer, restart netperf ]
> limit 28766
> inflight 27370
> limit 28766
> inflight 4542
> limit 5990
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 6056
> limit 4542
> inflight 0
>
> [ end of test ]
>
> I think thats what its supposed to look like :-)

Looks good!

Acked-by: Tom Herbert <therbert@google.com>
