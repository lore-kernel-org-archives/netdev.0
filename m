From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Fri, 14 Feb 2014 15:54:04 -0800
Message-ID: <CA+mtBx-oAByUKKMhQkgH2VATHQEKqwdC4BDTVKtNwXqxDyEfxA@mail.gmail.com>
References: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com>
	<52FC7D0C.1020601@mellanox.com>
	<CA+mtBx_+fc5YdQE+M49QD5ymuD7bfDdedfi2AuCDhU2=CawN6Q@mail.gmail.com>
	<CAJZOPZKRiR-XZo1b9-TQG9ULpVhL31bTBD+4Z7T+ODZcPX_L2g@mail.gmail.com>
	<alpine.LFD.2.03.1402131600120.8285@intel.com>
	<CA+mtBx8qbLU3vgDjPQPtU47+FS9R7f24gYw5wE+yNC7DGg-E4A@mail.gmail.com>
	<alpine.LFD.2.03.1402141034180.25492@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:47631 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751838AbaBNXyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 18:54:06 -0500
Received: by mail-ig0-f170.google.com with SMTP id m12so1910540iga.1
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 15:54:04 -0800 (PST)
In-Reply-To: <alpine.LFD.2.03.1402141034180.25492@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> In any case, we need to consider the orignal ip_summed value from the
>> driver, not the one that udp4_csum_init (udp_gro or anywhere else in
>> the path) would set.
>>
>> Also, udp_gro_receive should be able to handle the case where
>> ip_summed == CHECKSUM_UNNECESSARY and !skb->encapsulation, that will
>> be very common scenario. Probably CHECKSUM_NONE also.
>>
>
> Yes, I now see your point and totaly agree. Thanks.

Okay, I'll look at fixing this. I suspect we want to maintain
CHECKSUM_COMPLETE as long as possible in UDP receive path (or any
other encap path) and not be converting to CHECKSUM_UNNECESSARY.  When
crossing  the encapsulation layer we'll need to deal with
skb->encapsulation and CHECKSUM_UNNECESSARY.

Note to HW vendors: can you please start providing the full packet
checksum (CHECKSUM_COMPLETE) and stop perpetuating the extremely
protocol specific, restrictive checksum validation!
