From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Fri, 12 Apr 2013 17:42:46 +0800
Message-ID: <CACVXFVNyRYzk1Le+QaJr-nnbDCsGqWtx-VJ5X-K6np1+gLzRpA@mail.gmail.com>
References: <20110727141246.GC29616@orbit.nwl.cc>
	<1735684.e8eeVoUkuq@linux-5eaq.site>
	<CACVXFVPPzva+EwjNdxWsg4FufCc0zzzzvhGH_nLv479vT8VcxQ@mail.gmail.com>
	<1484183.xQu1D8fy8A@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f52.google.com ([209.85.212.52]:54594 "EHLO
	mail-vb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3DLJmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 05:42:47 -0400
In-Reply-To: <1484183.xQu1D8fy8A@linux-5eaq.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 12, 2013 at 2:37 PM, Oliver Neukum <oliver@neukum.org> wrote:
>> The work will complete when memory is reclaimed, and the rx/tx path is
>> still working, so memory reclaim can continue and the deadlock may not
>> be caused, may it?
>
> Only if the memory allocation goes to the same interface. If the blocking interface
> is storage, something bad happens (data loss not deadlock)

OK, got it, it should be both since reset can't move on, so
memory reclaim can't complete to satisfy the allocation.

But I am wondering if it is a case which is worth the consideration.

Almost all USB probe() allocate memory with GFP_KERNEL, then
the similar scenario(data loss only this time) might happen too. Do we
need to fix all USB drivers?

Wrt. the usbnet_status_start() API, looks no good reason to call
it in another queue context, it should be enough to call it in probe() or
bind() if init_status() can be put before info->bind() in usbnet_probe().

Then looks the mem_flags isn't needed in both cases, and we should
always take GFP_NOIO inside the API?

Thanks,
-- 
Ming Lei
