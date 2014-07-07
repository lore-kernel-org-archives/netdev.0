From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 7 Jul 2014 15:14:41 -0400
Message-ID: <CA+FuTSeqf=xgjjVreasKGZVPR1iXRKr68R7dj8n9w31-hUnznA@mail.gmail.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201851.GE3869@localhost.localdomain>
 <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com> <20140707184700.GA1610@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chad Reese <kreese@caviumnetworks.com>,
	David Daney <david.daney@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:57345 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751064AbaGGTPM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 15:15:12 -0400
Received: by mail-qa0-f54.google.com with SMTP id v10so3890398qac.41
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 12:15:11 -0700 (PDT)
In-Reply-To: <20140707184700.GA1610@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 7, 2014 at 2:47 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Mon, Jul 07, 2014 at 11:34:05AM -0400, Willem de Bruijn wrote:
>>
>> The hardware timestamp converted to system time is deprecated? I did
>> not know that. Because it is largely unused, or for a more fundamental
>> reason?
>
> It is for the fundamental reason that the idea behind it is just plain
> wrong. MAC drivers are not the place to put clock servos.
>
>> If so, the documentation could indeed use an explicit comment. The
>> definition of skb_shared_hwtstamps.syststamp too. I can write a small
>> patch independent of this patchset.
>
> Please do.

Ok. See below.

>
>> Unfortunately, a cursory inspection shows one, octeon. While that user
>> exists and generates such timestamps, I think that the above new flag
>> should be passed, as well, for API consistency.
>
> Ugh, how the heck did that turd get in? Its not like they bothered to
> include the maintainer on CC. That code must go.

I'm happy to unwind the syststamp part of 3d305850 ("netdev:
octeon_mgmt: Add hardware timestamp support"). Chad, let me know if
you object to that. Else, I'll send a patch to you both for review.

Once that is in, I'll follow up with a driver-independent stack patch
that removes the field in internal struct skb_shared_hwtstamps and
documents the legacy nature of the field in scm_timestamping. In
that case, we don't have to document the internal field in the interim.

>
> Thanks,
> Richard
