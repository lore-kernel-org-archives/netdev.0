From: Oliver Neukum <oneukum@suse.com>
Subject: Re: Several races in "usbnet" module (kernel 4.1.x)
Date: Mon, 27 Jul 2015 12:00:39 +0200
Message-ID: <1437991239.32457.9.camel@suse.com>
References: <55AD3A41.2040100@rosalab.ru>
	 <1437488529.3823.16.camel@suse.com> <55AFE210.7030104@rosalab.ru>
	 <1437642952.4377.10.camel@suse.com> <55B24EB6.5090907@rosalab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Eugene Shatokhin <eugene.shatokhin@rosalab.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B24EB6.5090907@rosalab.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-07-24 at 17:41 +0300, Eugene Shatokhin wrote:
> 23.07.2015 12:15, Oliver Neukum =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

>  From what I see now in Documentation/atomic_ops.txt, stores to the=20
> properly aligned memory locations are in fact atomic.

They are, but again only with respect to each other.

> So, I think, the situation you described above cannot happen for=20
> dev->flags, which is good. No need to address that in the patch. The=20
> race might be harmless after all.
>=20
> If I understand the code correctly now, dev->flags is set to 0 in=20
> usbnet_stop() so that the worker function (usbnet_deferred_kevent) wo=
uld

Yes, particularly not reschedule itself.

> do nothing, should it start later. If so, how about adding memory=20
> barriers for all CPUs to see dev->flags is 0 before other things?

Taking a lock, as del_timer_sync() does, implies a memory barrier,
as does a work.

	Regards
		Oliver
