From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 11:59:30 +0200
Message-ID: <5814124.riuyD8fLGG@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <87txndwkx1.fsf@nemi.mork.no> <CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:40997 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753080Ab3DKJ6o convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 05:58:44 -0400
In-Reply-To: <CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 16:37:53 Ming Lei wrote:
> On Thu, Apr 11, 2013 at 4:06 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> > Oliver Neukum <oliver@neukum.org> writes:
> >
> > My immediate thought was that someone also might want to use this n=
ew
> > API from atomic context, e.g. calling it directly from an URB callb=
ack.
>=20
> I am wondering it is a valid use case, and if there is one URB submit=
ted,
> the interrupt URB for status has been submitted already, hasn't it?

That is the point of this patch. There are multiple reasons to keep
the status urb submitted. The generic layer has to count them and
react to the count.

> > But that is of course not possible taking a mutex.  Could the lock
> > preventing interrupt_count maybe be a spinlock instead?  Or am I on=
 the
> > completely wrong track here?
>=20
> Also it is a bit odd that the 'start' API is allowed in atomic contex=
t, but
> the 'stop' API isn't allowed, and it is very easy to cause unbalanced=
 counter.

It simply is easier to submit an URB in an atomic context than to kill =
it.
The code allowing doing it under a spinlock would be complex.

> > In any case, I don't see the point unnecessarily limiting the API b=
y
> > dropping the memflags.  What possible problem would that solve?
>=20
> If you think 'start' API should be called in atomic context, the memf=
lags

It may be called. It doesn't have to be. usbnet needs a certain amount
of genericness in the API. Passing a flag does that and is simple.

	Regards
		Oliver
