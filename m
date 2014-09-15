From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Qdisc: Measuring Head-of-Line blocking with netperf-wrapper
Date: Mon, 15 Sep 2014 12:12:24 -0700
Message-ID: <54173A18.2010705@hp.com>
References: <20140915184517.6c5474e5@redhat.com> <CA+mtBx_EthN8G0oEUENmVhb8MJ2MrijhT+FRjJPomBLvJPoH_w@mail.gmail.com> <1410801863.7106.169.camel@edumazet-glaptop2.roam.corp.google.com> <CAA93jw7ZNbvwLtcFfwRVVF8asnxwp104g7iR-oZv3nj0mqKbOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Florian Westphal <fw@strlen.de>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Tim Shepard <shep@alum.mit.edu>,
	Avery Pennarun <apenwarr@google.com>
To: Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t1526.atlanta.hp.com ([15.193.200.69]:13768 "EHLO
	g6t1526.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbaIOTMa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 15:12:30 -0400
In-Reply-To: <CAA93jw7ZNbvwLtcFfwRVVF8asnxwp104g7iR-oZv3nj0mqKbOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2014 11:55 AM, Dave Taht wrote:
> Problems with TCP_RR and UDP_RR are that they are subject to a RTO on
> packet loss.

One possible way to work/kludge around that for TCP_RR would be to have 
a burst-mode test with say five or so transactions in flight at one 
time.  That then should allow for fast retrans on the occasional 
single-packet loss and it will be just an RTT rather than an RTO.  There 
would probably be some interactions with cwnd and bundling though upon 
that retransmission, even with -D set.

> It would be nice if netperf could sprout a "send a user specified
> packet size on this isochronous interval (with a resolution below a
> ms) over X transport" test. Or there was something simpler than owamp
> but as secure.

If you are willing to let netperf spin (ie burn local CPU on the system 
on which netperf is running) over the interval you can configure 
--enable-intervals --enable-spin  and then it will spin rather than rely 
on the resolution of setitimer().  Then the command line would be 
something along the lines of:

netperf -H <destination> -b 1 -w <waittime> -- -m <size>

and it will then make one send of <size> every <waittime>.

happy benchmarking,

rick
