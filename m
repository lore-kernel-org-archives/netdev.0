From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net-next-2.6 PATCH 01/10] ethtool: prevent null pointer
 dereference with NTUPLE set but no set_rx_ntuple
Date: Sat, 26 Feb 2011 18:16:31 -0800
Message-ID: <AANLkTi=UBQaJ9oJOvdn=Y_=SEEtFQ2p1wm0BG5-UP021@mail.gmail.com>
References: <20110225233244.7920.26742.stgit@gitlad.jf.intel.com>
	<1298679675.3555.4.camel@localhost>
	<4D684BED.20805@intel.com>
	<20110226.160747.226765885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alexander.h.duyck@intel.com, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:64801 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab1B0CQc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Feb 2011 21:16:32 -0500
Received: by wyg36 with SMTP id 36so2715897wyg.19
        for <netdev@vger.kernel.org>; Sat, 26 Feb 2011 18:16:31 -0800 (PST)
In-Reply-To: <20110226.160747.226765885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 26, 2011 at 4:07 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Fri, 25 Feb 2011 16:40:13 -0800
>
>> It cannot occur with any of the in-kernel drivers since they all set
>> the NETIF_F_NTUPLE flag and have the function defined. =A0However go=
ing
>> forward I would like to have the option of using the network flow
>> classifier interface instead of the set_rx_ntuple interface due to t=
he
>> fact that it supports many of the features I needed.
>
> This still doesn't explain to me why a driver would set the feature
> flag, but not actually implement the feature.

Actually the reason I ran into this is because of the patches in the
RFC set.  Basically I was looking at moving the ntuple support in
ixgbe over to network flow classifier rules.  As such I was leaving
the ntuple flag set, but using set_rxnfc via the filter rules instead.
 If you recommend adding a new flag to do that I am fine with that.

> I'm not applying this patch.
>
> When you create the situation that causes the potentially NULL
> dereference, then you can use that patch to show why this seemingly
> illogical situation can indeed occur.
>
> Until then no driver causes this issue, therefore the problem does
> not exist.

I'll do some digging late next week to see if there are any other
means of encountering the issue and will get back to you if I find
anything.

Thanks,

Alex
