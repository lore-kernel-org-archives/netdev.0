From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next v2] ipv6: log autoconfiguration failures
Date: Wed, 11 Dec 2013 22:09:51 +0100
Message-ID: <20131211210951.GC4675@order.stressinduktion.org>
References: <1386762314-5149-1-git-send-email-dvlasenk@redhat.com> <20131211192138.GB4675@order.stressinduktion.org> <20131211.155452.558417595732985707.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: dvlasenk@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131211.155452.558417595732985707.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 03:54:52PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Wed, 11 Dec 2013 20:21:38 +0100
> 
> > On Wed, Dec 11, 2013 at 12:45:14PM +0100, Denys Vlasenko wrote:
> >> If ipv6 auto-configuration does not work, currently it's hard
> >> to track what's going on. This change adds log messages
> >> (at debug level) on every code path where ipv6 autoconf fails.
> >> 
> >> v2: fixed indentation in multi-line log output statements.
> > 
> > Have you seen lots of those problems? Some of those seem like very
> > serious problems and maybe could also deserve a pr_warn or pr_err.
> > 
> > I hope these are one-time errors, so I don't think counters would
> > be helpful.
> 
> I still think that statitics would better serve this issue.
> 
> For one thing, the event would always be counted, whereas with
> pr_debug() someone has to turn on dynamic debugging in order
> to see the message.

I proposed switching some of these to pr_warn/err. pr_debugs get used very
seldomly, I agree.

> You can make them part of the per-inet6_dev MIB, and therefore
> implicitly letting the admin know what interface the events
> occurred on.

If such an error happens I would try to recreate the interface (in case of
virtual ones), thus erasing the statistics.

> I would even prefer an approach involving signalling netlink
> events in such circumstances with more detailed information.

That sounds good. But I would like to hear how often these problems
really occur first. Maybe Denys has some numbers? If that happens a lot
I would like to check if the notifier_chains are correctly setup so that
interfaces correclty notify ipv6 to retry link local address generation.

Greetings,

  Hannes
