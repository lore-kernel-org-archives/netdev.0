From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Fri, 12 Apr 2013 12:13:56 +0200
Message-ID: <87txncawez.fsf@nemi.mork.no>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1484183.xQu1D8fy8A@linux-5eaq.site>
	<CACVXFVNyRYzk1Le+QaJr-nnbDCsGqWtx-VJ5X-K6np1+gLzRpA@mail.gmail.com>
	<1819986.PZkH8CJNCQ@linux-5eaq.site>
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
Received: from canardo.mork.no ([148.122.252.1]:54705 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751215Ab3DLKOd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 06:14:33 -0400
In-Reply-To: <1819986.PZkH8CJNCQ@linux-5eaq.site> (Oliver Neukum's message of
	"Fri, 12 Apr 2013 12:02:55 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Neukum <oliver@neukum.org> writes:
> On Friday 12 April 2013 17:42:46 Ming Lei wrote:
>
>> Wrt. the usbnet_status_start() API, looks no good reason to call
>> it in another queue context, it should be enough to call it in probe=
() or
>> bind() if init_status() can be put before info->bind() in usbnet_pro=
be().
>
> We are talking about a generic helper. And the fix is really simple.
> We just pass mem_flags and all is well. If the API can be made better
> at next to no cost, we do it.

I absolutely agree with this.

>> Then looks the mem_flags isn't needed in both cases, and we should
>> always take GFP_NOIO inside the API?
>
> We cannot. GFP_ATOMIC may be needed. And no, we atre not going to
> unconditionally use GFP_ATOMIC :-;

But I don't think we ever will need GFP_ATOMIC as long as we take a
mutex lock anyway.


Bj=C3=B8rn
