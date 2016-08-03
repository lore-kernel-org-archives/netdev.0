From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net 1/2] tg3: Fix for diasllow rx coalescing time to be 0
Date: Wed, 3 Aug 2016 15:15:35 -0700
Message-ID: <CACKFLikoKktanhxgaMeSA0NGmA6RiaBnxnCXUYfcssYWefdMVg@mail.gmail.com>
References: <1470197640-13587-1-git-send-email-siva.kallam@broadcom.com>
 <1470197640-13587-2-git-send-email-siva.kallam@broadcom.com> <7d591d9f-463b-cedd-5590-c4ff8260ffa0@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: skallam <siva.kallam@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Satish Baddipadige <satish.baddipadige@broadcom.com>
To: Rick Jones <rick.jones2@hpe.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:33459 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758464AbcHCWPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 18:15:39 -0400
Received: by mail-oi0-f53.google.com with SMTP id j185so299766020oih.0
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 15:15:36 -0700 (PDT)
In-Reply-To: <7d591d9f-463b-cedd-5590-c4ff8260ffa0@hpe.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 3, 2016 at 9:04 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>
> Should anything then happen with:
>
>         /* No rx interrupts will be generated if both are zero */
>         if ((ec->rx_coalesce_usecs == 0) &&
>             (ec->rx_max_coalesced_frames == 0))
>                 return -EINVAL;
>
>
> which is the next block of code?  The logic there seems to suggest that it
> was intended to be able to have an rx_coalesce_usecs of 0 and rely on packet
> arrival to trigger an interrupt.  Presumably setting rx_max_coalesced_frames
> to 1 to disable interrupt coalescing.
>

I remember writing this block of code over 10 years ago for early
generations of the chip.  Newer chips seem to behave differently and
rx_coalesce_usecs can never be zero.  So this block can be removed now
that the condition can never be true.  We should probably leave a
comment there for future reference.
