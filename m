From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Wed, 22 Nov 2006 15:52:11 -0800
Message-ID: <4564E2AB.1020202@redhat.com>
References: <11641265982190@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:6070 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757197AbWKVXzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Nov 2006 18:55:52 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <11641265982190@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> + struct kevent_ring
> + {
> +   unsigned int ring_kidx, ring_uidx, ring_over;
> +   struct ukevent event[0];
> + }
> + [...]
> +ring_uidx - index of the first entry userspace can start reading fro=
m

Do we need this value in the structure?  Userlevel cannot and should no=
t=20
be able to modify it.  So, userland has in any case to track the tail=20
pointer itself.  Why then have this value at all?

After kevent_init() the tail pointer is implicitly assumed to be 0.=20
Since the front pointer (well index) is also zero nothing is available=20
for reading.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
