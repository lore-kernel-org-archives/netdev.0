From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v2 6/6] packet: rollover statistics
Date: Tue, 12 May 2015 11:04:19 -0400
Message-ID: <CA+FuTSc5AJA7_p_mAT9DXqsBDd-D=HSZ=yJnofFnQLisFNom9Q@mail.gmail.com>
References: <1431206701-5019-1-git-send-email-willemb@google.com>
 <1431206701-5019-7-git-send-email-willemb@google.com> <20150511.130950.1321194163068727654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Laight <david.laight@aculab.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:33750 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933312AbbELPEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 11:04:50 -0400
Received: by oica37 with SMTP id a37so8247719oic.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 08:04:49 -0700 (PDT)
In-Reply-To: <20150511.130950.1321194163068727654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> +struct tpacket_rollover_stats {
>> +     unsigned long   tp_all;
>> +     unsigned long   tp_huge;
>> +     unsigned long   tp_failed;
>> +};
>
> Please do not use variably sized types, especially "long" for user exported
> interfaces.  Otherwise you will need to add a compat layer to translate
> the data into userspace for 32-bit tasks running on a 64-bit kernel.
>
> If a 32-bit value really is not sufficient, use __aligned_u64.

Thanks for catching that. I converted them to __aligned_u64. The
internal counters remain atomic_long_t.

I'll push v3 of the patchset with only this change.
