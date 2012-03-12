From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH v6] Netfilter ring buffer support
Date: Mon, 12 Mar 2012 15:12:30 +0100
Message-ID: <20120312141230.GA32616@1984>
References: <1330989588-26833-1-git-send-email-richard@nod.at>
 <20120308012849.GA9164@1984>
 <4F5875B5.1090802@nod.at>
 <20120312130803.GA31865@1984>
 <4F5DF9B1.6050703@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jengelh@medozas.de, eric.dumazet@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, rostedt@goodmis.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55153 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684Ab2CLOMh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 10:12:37 -0400
Content-Disposition: inline
In-Reply-To: <4F5DF9B1.6050703@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 12, 2012 at 02:27:13PM +0100, Richard Weinberger wrote:
[...]
> >Looking at the code, those are included if bridging is enabled.
> >Otherwise, I'll be happy to take a patch for this.
> 
> Doesn't NFLOG just pass the packet header to userspace?

It also passes several interesting metainformation regarding the
packet to user-space as well. And it can be easily extended to add
more metainformation without breaking backward compatibility.

> How can you derive meta-information like "PHYSIN" and "PHYSOUT" from
> the packet header?

See nflog_get_physindev and nflog_get_physoutdev in libnetfilter_log.

> Iff NFLOG is able to produce same log string like LOG does I'm fine.

This is a patch yet incomplete for libnetfilter_log:

http://1984.lsi.us.es/git/rlogd/tree/libnflog.patch

It allows you to print in LOG output format. It still need to add
support for UDP, UDPlite, and so on, but that shouldn't be hard to
make.

I'd be happy if someone takes it over and finish it.

> >>3. rlogd needs NFLOG which copies every packet (header) to userspace.
> >>What about performance...?
> >
> >Reliability is also important, running things in user-space means that
> >bugs will no crash your system. Instead, they may crash your logging
> >daemon.
> >
> >What I find hard to justify is that this feature can be implemented in
> >user-space with the existing netfilter logging interface.
> 
> I understand that I have no chance to fight against the "this can be
> done in userspace"-argument. :-)

Regarding Netfilter in general, I'd specifically would like to
move towards making as many things in user-space as we can (while
evaluting performance impact, of course). We're getting a nice set of
netlink interfaces that are allowing us this. Thus, the idea is to
follow hybrid architecture: provide generic infrastructure in
kernel-space (by means of netlink), then develop specific features in
user-space.

In that direction, I expect to come up with a user-space cthelper
infrastructure soon so we can also implement helpers in user-space.
