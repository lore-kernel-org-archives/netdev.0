From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Fri, 8 Jan 2016 10:03:18 -0800
Message-ID: <CAKgT0Uc7K1tmwSmdi2uftJSHr4E5DKKYHxO1Gn50eCCWPaTurw@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C9B.3090408@solarflare.com>
	<CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
	<568FD844.3020101@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:33268 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbcAHSDS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 13:03:18 -0500
Received: by mail-ob0-f194.google.com with SMTP id oj9so934169obc.0
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 10:03:18 -0800 (PST)
In-Reply-To: <568FD844.3020101@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 8, 2016 at 7:39 AM, Edward Cree <ecree@solarflare.com> wrote:
> On 08/01/16 03:46, Alexander Duyck wrote:
>> So I just tried testing your patches and as it turns out you are still
>> missing some bits.  In this patch for instance the calls to
>> udp_tunnel_xmit_skb and udp_tunnel6_xmit skb need to be updated so
>> that you pass false for the last parameter and allow the use of your
>> udp_set_csum modifications.
>>
>> - Alex
> Are you remembering to enable outer checksums on your vxlan tunnel?  It's
>  the vxflags & VXLAN_F_UDP_CSUM check, and to enable it you need a recent
>  iproute2 so you can use the 'udpcsum' option when creating the vxlan device.

No I hadn't done that.  I kind of assumed that the checksums were just
being enabled by default.  That might explain the some of the issues I
had..  ;-)

> It would be nice if that could just default to enabled now that we have LCO,
>  but I don't think we can change that now (ABIs set in stone and all that),
>  so I think it would have to be iproute2 that turned it on by default.

If anything we might want to expose the capabilities of the kernel so
that iproute2 could make an informed decision on if it want to enable
the outer checksum by default or not.

- Alex
