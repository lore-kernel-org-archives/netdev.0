From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Thu, 14 Oct 2010 08:41:45 +0200
Message-ID: <201010140841.45736.hans.schillstrom@ericsson.com>
References: <20101012.130520.48517464.davem@davemloft.net> <20101013111946.GA9529@ff.dom.local> <20101013.145856.112590240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "jarkao2@gmail.com" <jarkao2@gmail.com>,
	"ebiederm@xmission.com" <ebiederm@xmission.com>,
	"daniel.lezcano@free.fr" <daniel.lezcano@free.fr>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:49185 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756Ab0JNGlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 02:41:49 -0400
In-Reply-To: <20101013.145856.112590240.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 13 October 2010 23:58:56 David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 13 Oct 2010 11:19:47 +0000
>
> >> -static void rt_do_flush(int process_context)
> >> +static void rt_do_flush(struct net *net, int process_context)
> >>  {
> >>  	unsigned int i;
> >>  	struct rtable *rth, *next;
> >> -	struct rtable * tail;
> >>
> >>  	for (i = 0; i <= rt_hash_mask; i++) {
> >> +		struct rtable *list, **pprev;
> >
> > Isn't "list = NULL" needed here?
>
> Yes it is, thanks for catching that.
>
It solves the crach but....

 #
Slab corruption: size-4096 start=ffff88000f950000, len=4096
010: 00 00 00 00 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b
unregister_netdevice: waiting for lo to become free. Usage count = 4
Slab corruption: size-4096 start=ffff88000f9af000, len=4096
010: 00 00 00 00 00 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b
unregister_netdevice: waiting for lo to become free. Usage count = 4
unregister_netdevice: waiting for lo to become free. Usage count = 4
unregister_netdevice: waiting for lo to become free. Usage count = 4

Regards
Hans Schillstrom <hans.schillstrom@ericsson.com>
