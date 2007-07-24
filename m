From: "Dan Williams" <dan.j.williams@intel.com>
Subject: Re: 2.6.23-rc1: BUG_ON in kmap_atomic_prot()
Date: Tue, 24 Jul 2007 06:55:36 -0700
Message-ID: <e9c3a7c20707240655j533f0882xe067903e5f0ac9b7@mail.gmail.com>
References: <alpine.LFD.0.999.0707221351030.3607@woody.linux-foundation.org>
	 <20070723190152.GA5755@martell.zuzino.mipt.ru>
	 <20070723132431.42afbae8.akpm@linux-foundation.org>
	 <20070723204045.GD5755@martell.zuzino.mipt.ru>
	 <20070723210153.GA5753@martell.zuzino.mipt.ru>
	 <20070723141137.171e4ac1.akpm@linux-foundation.org>
	 <20070723220446.GA5822@martell.zuzino.mipt.ru>
	 <20070723152712.02ded067.akpm@linux-foundation.org>
	 <20070724081750.GM3287@kernel.dk> <20070724082207.GN3287@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	"Alexey Dobriyan" <adobriyan@gmail.com>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mark.fasheh@oracle.com
To: "Jens Axboe" <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:26861 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407AbXGXNzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 09:55:37 -0400
Received: by an-out-0708.google.com with SMTP id d31so377673and
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 06:55:36 -0700 (PDT)
In-Reply-To: <20070724082207.GN3287@kernel.dk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/24/07, Jens Axboe <jens.axboe@oracle.com> wrote:
> What about the new async crypto stuff? I've been looking, but is it
> guarenteed that async_memcpy() runs in process context with interrupts
> enabled always? If not, there's a km type bug there.
>

Currently the only user is the MD raid456 driver, and yes, it only
performs copies from the handle_stripe routine which is always run in
process context with interrupts enabled.  However this is not
documented.  Would it be advisable to add a WARN_ON for this
condition?

> In general, I think the highmem stuff could do with more safety checks:
>
> - People ALWAYS get the atomic unmaps wrong, passing in the page instead
>   of the address. I've seen tons of these. And since kunmap_atomic()
>   takes a void pointer, nobody notices until it goes boom.
> - People easily get the km type wrong - they use KM_USERx in interrupt
>   context, or one of the irq variants without disabling interrupts.
>
> If we could just catch these two types of bugs, we've got a lot of these
> problems covered.
>
>
> --
> Jens Axboe
>
--
Dan
