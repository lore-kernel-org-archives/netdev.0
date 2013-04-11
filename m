From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 12:04:01 +0200
Message-ID: <87ppy1wfhq.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1365625850.22411.1.camel@dcbw.foobar.com>
	<CACVXFVNKSszw+3VnM3hwepbTHh3gvjC+pG2SL_OsVm+1SqrNzQ@mail.gmail.com>
	<2552222.23e5DWG2Z9@linux-5eaq.site> <87txndwkx1.fsf@nemi.mork.no>
	<CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oliver@neukum.org>, Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36828 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751736Ab3DKKEg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 06:04:36 -0400
In-Reply-To: <CACVXFVMW2Dosr0FAKCvxgUFQKmwbduiC+HqmzS1tsvAHu=G8Kg@mail.gmail.com>
	(Ming Lei's message of "Thu, 11 Apr 2013 16:37:53 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <tom.leiming@gmail.com> writes:

> On Thu, Apr 11, 2013 at 4:06 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrot=
e:
>> Oliver Neukum <oliver@neukum.org> writes:
>>
>> My immediate thought was that someone also might want to use this ne=
w
>> API from atomic context, e.g. calling it directly from an URB callba=
ck.
>
> I am wondering it is a valid use case, and if there is one URB submit=
ted,
> the interrupt URB for status has been submitted already, hasn't it?

It might not be valid.

>> But that is of course not possible taking a mutex.  Could the lock
>> preventing interrupt_count maybe be a spinlock instead?  Or am I on =
the
>> completely wrong track here?
>
> Also it is a bit odd that the 'start' API is allowed in atomic contex=
t, but
> the 'stop' API isn't allowed, and it is very easy to cause unbalanced=
 counter.

Yes, that's a valid point.  Just a random thought popping out :)

=46or the record: I believe the v5 patch as posted really is fine witho=
ut
any changes.

>> In any case, I don't see the point unnecessarily limiting the API by
>> dropping the memflags.  What possible problem would that solve?
>
> If you think 'start' API should be called in atomic context, the memf=
lags
> should be always 'GFP_ATOMIC'. I let Oliver explain why GFP_NOIO
> is needed in other cases.

Again: What problem are you attempting to solve by removing the
mem_flags from the API?

I think you are turning this the wrong way around. Please explain why
there are no use cases where different flags are needed.  You seem to b=
e
only concerned about the resume case. This API is not limited to
resuming. We pass mem_flags around all the time. It's the common thing
to do in any API where allocations may be required.


Bj=C3=B8rn
