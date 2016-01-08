From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 11:40:26 -0800
Message-ID: <CAEh+42iX4AxEektcKSSeJ+OKX5Paa+ZY5T9vXC5KYtiLvjqixg@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com> <568E9C9B.3090408@solarflare.com>
 <CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
 <568FD844.3020101@solarflare.com> <CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:40391 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755582AbcAHTkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 14:40:43 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 042B420204
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 19:40:43 +0000 (UTC)
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 627F0201F4
	for <netdev@vger.kernel.org>; Fri,  8 Jan 2016 19:40:41 +0000 (UTC)
Received: by mail-qg0-f42.google.com with SMTP id o11so360295718qge.2
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 11:40:41 -0800 (PST)
In-Reply-To: <CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 10:03 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Fri, Jan 8, 2016 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
>> On 08/01/16 03:46, Alexander Duyck wrote:
>>> So I just tried testing your patches and as it turns out you are still
>>> missing some bits.  In this patch for instance the calls to
>>> udp_tunnel_xmit_skb and udp_tunnel6_xmit skb need to be updated so
>>> that you pass false for the last parameter and allow the use of your
>>> udp_set_csum modifications.
>>>
>>> - Alex
>> Are you remembering to enable outer checksums on your vxlan tunnel?  It's
>>  the vxflags & VXLAN_F_UDP_CSUM check, and to enable it you need a recent
>>  iproute2 so you can use the 'udpcsum' option when creating the vxlan device.
>
> No I hadn't done that.  I kind of assumed that the checksums were just
> being enabled by default.  That might explain the some of the issues I
> had..  ;-)
>
>> It would be nice if that could just default to enabled now that we have LCO,
>>  but I don't think we can change that now (ABIs set in stone and all that),
>>  so I think it would have to be iproute2 that turned it on by default.
>
> If anything we might want to expose the capabilities of the kernel so
> that iproute2 could make an informed decision on if it want to enable
> the outer checksum by default or not.

Keep in mind that protocols like VXLAN specify that the UDP checksum
should be set to zero. As a result, enabling the checksum is not a
purely local decision and it probably shouldn't be on by default.
