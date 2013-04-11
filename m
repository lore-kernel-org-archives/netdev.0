From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 10:06:50 +0200
Message-ID: <87txndwkx1.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ming Lei <tom.leiming@gmail.com>, Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35699 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754577Ab3DKIHa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 04:07:30 -0400
In-Reply-To: <2552222.23e5DWG2Z9@linux-5eaq.site> (Oliver Neukum's message of
	"Thu, 11 Apr 2013 08:50:30 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:
> On Thursday 11 April 2013 10:31:31 Ming Lei wrote:
> =20
>> 'mem_flags' isn't needed any more since we can apply allocation
>> of GFP_NOIO automatically in resume path now, and you can always
>> use GFP_KERNEL safely. Considered that it is a API, please don't
>> introduce it.
>
> The automatic system goes a long way, but there are corner cases, for=
 example
> work queues, which still need mem_flags.


My immediate thought was that someone also might want to use this new
API from atomic context, e.g. calling it directly from an URB callback.
But that is of course not possible taking a mutex.  Could the lock
preventing interrupt_count maybe be a spinlock instead?  Or am I on the
completely wrong track here?

In any case, I don't see the point unnecessarily limiting the API by
dropping the memflags.  What possible problem would that solve?


Bj=C3=B8rn
