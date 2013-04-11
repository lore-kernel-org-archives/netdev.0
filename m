From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 16:37:53 +0800
Message-ID: <CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
	<87txndwkx1.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:36963 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab3DKIhy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 04:37:54 -0400
In-Reply-To: <87txndwkx1.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 4:06 PM, Bj=F8rn Mork <bjorn@mork.no> wrote:
> Oliver Neukum <oliver@neukum.org> writes:
>
> My immediate thought was that someone also might want to use this new
> API from atomic context, e.g. calling it directly from an URB callbac=
k.

I am wondering it is a valid use case, and if there is one URB submitte=
d,
the interrupt URB for status has been submitted already, hasn't it?

> But that is of course not possible taking a mutex.  Could the lock
> preventing interrupt_count maybe be a spinlock instead?  Or am I on t=
he
> completely wrong track here?

Also it is a bit odd that the 'start' API is allowed in atomic context,=
 but
the 'stop' API isn't allowed, and it is very easy to cause unbalanced c=
ounter.

>
> In any case, I don't see the point unnecessarily limiting the API by
> dropping the memflags.  What possible problem would that solve?

If you think 'start' API should be called in atomic context, the memfla=
gs
should be always 'GFP_ATOMIC'. I let Oliver explain why GFP_NOIO
is needed in other cases.

Thanks
--=20
Ming Lei
