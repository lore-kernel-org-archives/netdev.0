From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 1/5] send-crc: Add framework to allow sending packets with
 customized CRC.
Date: Wed, 8 Feb 2012 00:59:17 +0100
Message-ID: <CAHXqBFKbv13jL_RqbOTZp6P-TOO7iQ1211SXmMso_3LK27LkPw@mail.gmail.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com>
 <CAHXqBFKe+nAGk8gjjOxRSbgtPSPHXcz3_fNjaBaxh48vPvDysQ@mail.gmail.com> <4F318CF5.1060200@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:47511 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755998Ab2BGX7i convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 18:59:38 -0500
Received: by yhoo21 with SMTP id o21so3366072yho.19
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2012 15:59:37 -0800 (PST)
In-Reply-To: <4F318CF5.1060200@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 7 lutego 2012 21:43 u=BFytkownik Ben Greear
<greearb@candelatech.com> napisa=B3:
> On 02/07/2012 12:33 PM, Micha=B3 Miros=B3aw wrote:
>>
>> 2012/2/7<greearb@candelatech.com>:
>>>
>>> From: Ben Greear<greearb@candelatech.com>
>>>
>>> This is useful for testing RX handling of frames with bad
>>> CRCs.
>>>
>>> Requires driver support to actually put the packet on the
>>> wire properly.
>>
>> [...]
>>
>> I like this idea. I think that this is not a feature to have in
>> dev->features to toggle, though. Driver either supports this or not,
>> so it's better to put it in dev->priv_flags instead. Disabling of FC=
S
>> inserting is a per-packet option in the drivers, isn't it?
>>
>> For one problem with toggling: if you create a socket using it and
>> later turn off the feature, the socket will still send skbs with FCS
>> appended.
> For the priv-flags, is there a way to query that from user-space to
> see if the NIC supports it?
>
> The pkt-socket xmit logic will throw away pkts if the NIC doesn't
> have the feature enabled, but a few already queued might get
> through with extra CRC appended.
>
> So, I'm fine with your suggestion, as long as there is some way to
> query whether the NIC supports this feature or not...

There's a way, as you implemented -EINVAL when trying to send via
unsupporting device. :-) Would be even better if setting SO_NO_FCS
would fail at setsockopt() time.

priv_flags are not exposed to userspace. It should be easy to export
them using ETHTOOL_GFEATURES as non-changeable features, if that's
useful.

Best Regards,
Micha=B3 Miros=B3aw
