From: Siva Reddy Kallam <siva.kallam@broadcom.com>
Subject: Re: [PATCH net 1/2] tg3: Fix for diasllow rx coalescing time to be 0
Date: Fri, 5 Aug 2016 11:14:55 +0530
Message-ID: <CAMet4B47ueZVdOYBiC03Ppc8f3WNLJn24nuBfYrMkrNB9Tu44Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Rick Jones <rick.jones2@hpe.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Satish Baddipadige <satish.baddipadige@broadcom.com>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35502 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbcHEFo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 01:44:57 -0400
Received: by mail-qk0-f170.google.com with SMTP id x185so61251997qkc.2
        for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 22:44:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2016 at 3:45 AM, Michael Chan <michael.chan@broadcom.com> wrote:
> On Wed, Aug 3, 2016 at 9:04 AM, Rick Jones <rick.jones2@hpe.com> wrote:
>>
>> Should anything then happen with:
>>
>>         /* No rx interrupts will be generated if both are zero */
>>         if ((ec->rx_coalesce_usecs == 0) &&
>>             (ec->rx_max_coalesced_frames == 0))
>>                 return -EINVAL;
>>
>>
>> which is the next block of code?  The logic there seems to suggest that it
>> was intended to be able to have an rx_coalesce_usecs of 0 and rely on packet
>> arrival to trigger an interrupt.  Presumably setting rx_max_coalesced_frames
>> to 1 to disable interrupt coalescing.
>>
>
> I remember writing this block of code over 10 years ago for early
> generations of the chip.  Newer chips seem to behave differently and
> rx_coalesce_usecs can never be zero.  So this block can be removed now
> that the condition can never be true.  We should probably leave a
> comment there for future reference.
Thanks Rick for identifying this.
Thanks Michael for your inputs. I will submit a patch with removal of
this block of code and add a comment for future reference.
