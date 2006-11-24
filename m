From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 14:01:44 +0300
Message-ID: <20061124110143.GF13600@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <4564E162.8040901@redhat.com> <20061123115240.GA20294@2ka.mipt.ru> <4565FA60.9000402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:1201 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1757608AbWKXLC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 06:02:56 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <4565FA60.9000402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 11:45:36AM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Evgeniy Polyakov wrote:
> >Kernel does not put there a new entry, it is only done inside
> >kevent_wait(). Entries are put into queue (in any context), where th=
ey can=20
> >be obtained
> >from only kevent_wait() or kevent_get_events().
>=20
> I know this is how it's done now.  But it is not where it has to end.=
=20
> IMO we have to get to a solution where new events are posted to the r=
ing=20
> buffer asynchronously, i.e., without a thread calling kevent_wait.  A=
nd=20
> then you need the extra parameter and verification.  Even if it's tod=
ay=20
> not needed we have to future-proof the interface since it cannot be=20
> changed once in use.

There is a special flag in kevent_user to wake it if there are no ready
events - kernel thread which has added new events will set it and thus
subsequent kevent_wait() will return with updated indexes - userspace
must check indexes after kevent_wait().

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
