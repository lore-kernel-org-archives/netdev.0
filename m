From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 5/6] net-timestamp: TCP timestamping
Date: Wed, 6 Aug 2014 15:20:39 -0400
Message-ID: <CA+FuTSdnuBw4ex7Hj=ko_r0P7SqPs5gA2qcTX1tHMbo3YndMJQ@mail.gmail.com>
References: <1407204710-21778-1-git-send-email-willemb@google.com>
 <1407204710-21778-6-git-send-email-willemb@google.com> <1407308749.14097.13.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+FuTSf96KH=JkO4Va4pfbvYHngHjxtTc33ipbif_xC9kdgaLQ@mail.gmail.com> <1407335823.11943.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Richard Cochran <richardcochran@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f53.google.com ([209.85.216.53]:53588 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932246AbaHFTVK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 15:21:10 -0400
Received: by mail-qa0-f53.google.com with SMTP id v10so2893914qac.40
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 12:21:09 -0700 (PDT)
In-Reply-To: <1407335823.11943.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 6, 2014 at 10:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-08-06 at 10:23 -0400, Willem de Bruijn wrote:
>> > I believe you missed fact that a GSO packet can be split into 2 or many
>> > skbs, when tcp_write_xmit() has to send a lower amount.
>> >
>> > This is done in tso_fragment()
>>
>> Thanks, I missed that case. I'll look into it.
>>
>> > Also, I am a bit worried about retransmits ?
>>
>> For the same reason, i.e., possibly calling tcp_fragment?
>
> Yes,

Good catch, thanks. Both cases only affect the correctness of this
feature, not existing code, so I will work on a separate fix for net
later.

> but also that we're going to send multiple reports back to error
> queue.

I see. The optimization patch to queue timestamps without payload will
mitigate that somewhat. I dropped that from the initial patchset, but
will fix it up for net-next. It may also be possible to squash
multiple timestamped packets on the errqueue together when they all
have the same payload, resulting in a single (possibly no-payload)
packet with repeating cmsgs IP_RECVERR and SCM_TIMESTAMPING. That
would give O(1) overhead regardless of number of retransmits.

I just sent the fix to the other issues.

>
