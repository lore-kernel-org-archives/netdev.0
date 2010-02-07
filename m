From: Mike McCormack <mikem@ring3k.org>
Subject: Re: [PATCH 2/2] sky2: Allocate initial skbs in sky2_alloc_buffers
Date: Sun, 7 Feb 2010 18:56:44 +0900
Message-ID: <392fb48f1002070156r7a1d615j460506b9441e128c@mail.gmail.com>
References: <4B6CC473.4090008@ring3k.org> <20100205181045.42908795@nehalam>
	 <20100205221246.6fdb3632@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f224.google.com ([209.85.217.224]:55370 "EHLO
	mail-gx0-f224.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab0BGJ4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2010 04:56:45 -0500
Received: by gxk24 with SMTP id 24so5824458gxk.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2010 01:56:44 -0800 (PST)
In-Reply-To: <20100205221246.6fdb3632@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 February 2010 15:12, Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Fri, 5 Feb 2010 18:10:45 -0800
> Stephen Hemminger <shemminger@vyatta.com> wrote:
>
>> On Sat, 06 Feb 2010 10:22:59 +0900
>> Mike McCormack <mikem@ring3k.org> wrote:
>>
>> > Allocating everything in one place means there's a single point
>> > of failure in sky2_up, and sky2_rx_start can no longer fail.
>>
>> If ring is never allocated, how then it must fail in up.
>> Plus if the initial ring allocation is partial it should fail.
>
> Let me put that clearer...
> When dev_open is called, the system might be very short of memory
> and unable to allocate the number of receive buffers; in that case,
> I would prefer that an error was returned to the application.
> Yes, this is a corner case; but it is better to fail with a noisy
> error than limp along with a dead device.

Hi Stephen,

I think you've misread my patch.  I have not attempted to change the
way allocation failure is handled, just to move all allocations to the
same place.

The end goal is to refactor sky2_up into a piece that initializes
hardware following memory allocation (say sky2_start) so we can do
sky2_reset() without free'ing and allocating memory, or detaching the
device.

thanks,

Mike
