From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2 1/8] net-timestamp: explicit SO_TIMESTAMPING
 ancillary data struct
Date: Mon, 7 Jul 2014 11:34:05 -0400
Message-ID: <CA+FuTSeSOBUzDLahLBNoW4i-UZe-VOXZr4LgA2bXBfjWxe10Fw@mail.gmail.com>
References: <1404416380-3545-1-git-send-email-willemb@google.com>
 <1404416380-3545-2-git-send-email-willemb@google.com> <20140705201851.GE3869@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	richardcochran@gomail.com,
	Stephen Hemminger <stephen@networkplumber.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:63171 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbaGGPeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 11:34:36 -0400
Received: by mail-qa0-f50.google.com with SMTP id m5so3678497qaj.23
        for <netdev@vger.kernel.org>; Mon, 07 Jul 2014 08:34:35 -0700 (PDT)
In-Reply-To: <20140705201851.GE3869@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 5, 2014 at 4:18 PM, Richard Cochran
<richardcochran@gmail.com> wrote:
> On Thu, Jul 03, 2014 at 03:39:33PM -0400, Willem de Bruijn wrote:
>
>> +#define SCM_TSTAMP_SND               0x1     /* driver passed skb to NIC */
>> +#define SCM_TSTAMP_ACK               0x2     /* transport layer saw ACK */
>> +#define SCM_TSTAMP_ENQ               0x4     /* stack passed skb to TC layer */
>> +#define SCM_TSTAMP_RCV               0x8     /* stack received skb */
>> +#define SCM_TSTAMP_HWSYS     0x10    /* NIC tstamp in system format */
>
> We don't need this flag. Better to omit it, because we are not going
> to allow this kind of time stamp ever again.

The hardware timestamp converted to system time is deprecated? I did
not know that. Because it is largely unused, or for a more fundamental
reason?

If so, the documentation could indeed use an explicit comment. The
definition of skb_shared_hwtstamps.syststamp too. I can write a small
patch independent of this patchset.

Better, that field in could be removed completely if there are no
users.That would be self documenting, would simplify plumbing
boilerplate and shrink sbk_shared_info.

Unfortunately, a cursory inspection shows one, octeon. While that user
exists and generates such timestamps, I think that the above new flag
should be passed, as well, for API consistency.

>> +#define SCM_TSTAMP_HWRAW     0x20    /* NIC tstamp in native format */
>
> Thanks,
> Richard
