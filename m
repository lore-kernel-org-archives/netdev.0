From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH next] r8169: add support for Byte Queue Limits
Date: Tue, 30 Sep 2014 09:42:59 +0200
Message-ID: <20140930074259.GC11709@breakpoint.cc>
References: <1412024209-25468-1-git-send-email-fw@strlen.de>
 <CA+mtBx95KFr=3h_TZWBeM6e7EF4sKAmjRpz5vLxGwi8xC+qQuw@mail.gmail.com>
 <20140929211158.GA11633@breakpoint.cc>
 <CA+mtBx8rpELodiiez8LkKupKBr9ynbQhrmAq8tcD4QKXHNjyaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Hayes Wang <hayeswang@realtek.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33637 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751712AbaI3HnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 03:43:03 -0400
Content-Disposition: inline
In-Reply-To: <CA+mtBx8rpELodiiez8LkKupKBr9ynbQhrmAq8tcD4QKXHNjyaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <therbert@google.com> wrote:
> Watch inflight and limit in the byte_queue_limits for the queue.
> inflight must always go back to zero when link goes idle.

Yes, inflight goes to 0 when link is idle.

Output of
while true; do
    for n in inflight limit; do
      echo -n $n\ ; cat $n;
      done; sleep 1;
done

during netperf run, 100mbit peer:

inflight 0
limit 3028
inflight 6056
limit 4542
[ no changes during test ]
limit 4542
inflight 3028
limit 6122
inflight 0
limit 6122
[ changed cable to 1gbit peer, restart netperf ]
inflight 37850
limit 36336
inflight 33308
limit 31794
inflight 33308
limit 31794
inflight 27252
limit 25738
[ no changes during test ]
inflight 27252
limit 25738
inflight 0
limit 28766
[ change cable to 100mbit peer, restart netperf ]
limit 28766
inflight 27370
limit 28766
inflight 4542
limit 5990
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 6056
limit 4542
inflight 0

[ end of test ]

I think thats what its supposed to look like :-)
