From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 1/5] send-crc: Add framework to allow sending packets
 with customized CRC.
Date: Tue, 07 Feb 2012 12:43:33 -0800
Message-ID: <4F318CF5.1060200@candelatech.com>
References: <1328644182-7872-1-git-send-email-greearb@candelatech.com> <CAHXqBFKe+nAGk8gjjOxRSbgtPSPHXcz3_fNjaBaxh48vPvDysQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52449 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab2BGUnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:43:35 -0500
In-Reply-To: <CAHXqBFKe+nAGk8gjjOxRSbgtPSPHXcz3_fNjaBaxh48vPvDysQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2012 12:33 PM, Micha=C5=82 Miros=C5=82aw wrote:
> 2012/2/7<greearb@candelatech.com>:
>> From: Ben Greear<greearb@candelatech.com>
>>
>> This is useful for testing RX handling of frames with bad
>> CRCs.
>>
>> Requires driver support to actually put the packet on the
>> wire properly.
> [...]
>
> I like this idea. I think that this is not a feature to have in
> dev->features to toggle, though. Driver either supports this or not,
> so it's better to put it in dev->priv_flags instead. Disabling of FCS
> inserting is a per-packet option in the drivers, isn't it?
>
> For one problem with toggling: if you create a socket using it and
> later turn off the feature, the socket will still send skbs with FCS
> appended.

=46or the priv-flags, is there a way to query that from user-space to
see if the NIC supports it?

The pkt-socket xmit logic will throw away pkts if the NIC doesn't
have the feature enabled, but a few already queued might get
through with extra CRC appended.

So, I'm fine with your suggestion, as long as there is some way to
query whether the NIC supports this feature or not...

Thanks,
Ben

>
> Best Regards,
> Micha=C5=82 Miros=C5=82aw


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
