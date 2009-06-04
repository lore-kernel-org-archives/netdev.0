From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/4] net: skb_orphan on dev_hard_start_xmit
Date: Thu, 4 Jun 2009 13:24:57 +0930
Message-ID: <200906041324.59118.rusty@rustcorp.com.au>
References: <200905292344.56814.rusty@rustcorp.com.au> <200906012157.29465.rusty@rustcorp.com.au> <4A26E4FD.5010405@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Divy Le Ray <divy@chelsio.com>,
	Roland Dreier <rolandd@cisco.com>,
	Pavel Emelianov <xemul@openvz.org>,
	Dan Williams <dcbw@redhat.com>,
	libertas-dev@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33028 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517AbZFDDzI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 23:55:08 -0400
In-Reply-To: <4A26E4FD.5010405@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 4 Jun 2009 06:32:53 am Eric Dumazet wrote:
> Rusty Russell a =E9crit :
> > On Sat, 30 May 2009 12:41:00 am Eric Dumazet wrote:
> >> For TCP, I agree your patch is a huge benefit, since its paced by =
remote
> >> ACKS and window control
> >
> > I doubt that.  There'll be some cache friendliness, but I'm not sur=
e
> > it'll be measurable, let alone "huge".
=2E..
> We can see sock_wfree() being number 2 on the profile, because it tou=
ches
> three cache lines per socket and transmited packet in TX completion
> handler.

Interesting, I take it back: got some "after" stats as well?

> Also, taking a reference on socket for each xmit packet in flight is =
very
> expensive, since it slows down receiver in __udp4_lib_lookup(). Sever=
al
> cpus are fighting for sk->refcnt cache line.

Now we have decent dynamic per-cpu, we can finally implement bigrefs.  =
More=20
obvious for device counts than sockets, but perhaps applicable here as =
well?

Rusty.
