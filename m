From: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 12:33:37 -0400 (EDT)
Message-ID: <133859123.129202.1432830817627.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com> <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com> <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com> <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net> <5567382E.4010706@gmail.com> <1432830406.7456.19.camel@edumazet-glaptop2.roam.corp.google.com>
Reply-To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.196]:49944 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754137AbbE1Qdi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 12:33:38 -0400
In-Reply-To: <1432830406.7456.19.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On May 28, 2015 at 12:26 PM Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>
> On Thu, 2015-05-28 at 08:45 -0700, John Fastabend wrote:
> > If your experimenting one thing you could do is create many
> > ifb devices and load balance across them from tc. I'm not
> > sure if this would be practical in your setup or not but might
> > be worth trying.
> >
> > One thing I've been debating adding is the ability to match
> > on current cpu_id in tc which would allow you to load balance by
> > cpu. I could send you a patch if you wanted to test it. I would
> > expect this to help somewhat with 'single queue' issue but sorry
> > haven't had time yet to test it out myself.
>
> It seems John uses a single 1Gbps flow, so only one cpu would receive
> NIC interrupts.
>
> The only way he could get better results would be to schedule IFB work
> on another core.
>
> (Assuming one cpu is 100% busy servicing NIC + IFB, but I really doubt
> it...)
>
>
>
Our initial testing has been single flow but the ultimate purpose is processing
real time video in a complex application which ingests associated meta data,
post to consumer facing cloud, does reporting back - so lots of different
traffics with very different demands - a perfect tc environment.

CPU utilization is remarkably light.  Every once in a while, we see a single CPU
about 50% utilized with si.  Thanks, all - John
