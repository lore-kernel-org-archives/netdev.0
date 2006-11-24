From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take25 1/6] kevent: Description.
Date: Fri, 24 Nov 2006 14:50:04 +0300
Message-ID: <20061124115004.GB32545@2ka.mipt.ru>
References: <11641265982190@2ka.mipt.ru> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com> <200611232249.56886.hhh@imada.sdu.dk> <45662206.1070104@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Henrik Happe <hhh@imada.sdu.dk>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54913 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S933879AbWKXLvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Nov 2006 06:51:37 -0500
To: Ulrich Drepper <drepper@redhat.com>
Content-Disposition: inline
In-Reply-To: <45662206.1070104@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 02:34:46PM -0800, Ulrich Drepper (drepper@redha=
t.com) wrote:
> Hans Henrik Happe wrote:
> >I don't know if this falls under the simplification, but wouldn't th=
ere be=20
> >a race when reading/copying the event data? I guess this could be so=
lved=20
> >with an extra user index.=20
>=20
> That's what I said, reading the value from the ring buffer structure'=
s=20
> head would be racy.  All this can only work for single threaded code.

Value in the userspace ring is updated each time it is changed in kerne=
l
(when userspace calls kevent_commit()), when userspace has read its old
value it is guaranteed that requested number of events _is_ there
(although it is possible that there are more than that value).

Ulrich, why didn't you comment on previous interface, which had exactly
_one_ index exported to userspace - it is only required to add implicit
uidx and (if you prefer that way) additional syscall, since in previous
interface both waiting and commit was handled by kevent_wait() with
different parameters.

> --=20
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View,=20
> CA =E2=9D=96

--=20
	Evgeniy Polyakov
