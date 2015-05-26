From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 0/3] net: Add incoming CPU mask to sockets
Date: Tue, 26 May 2015 15:42:33 -0700
Message-ID: <1432680153.4060.304.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432658049-3400132-1-git-send-email-tom@herbertland.com>
	 <1432660689.4060.275.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34DxrhBvnMyovQFF+Kzpvx3h6=Nviu7XOegPsZa71KrvA@mail.gmail.com>
	 <1432664388.4060.292.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CALx6S34AGs79MvbS52Hkc44=0vN=Ga=H_b8QCTbN0MG6fP2-uQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:35167 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbEZWmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 18:42:35 -0400
Received: by iesa3 with SMTP id a3so639331ies.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 15:42:34 -0700 (PDT)
In-Reply-To: <CALx6S34AGs79MvbS52Hkc44=0vN=Ga=H_b8QCTbN0MG6fP2-uQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 13:01 -0700, Tom Herbert wrote:

> In that case there's no guarantee that any two packets in a flow will
> hit the same CPU so there's no way to establish affinity to the
> interrupt anyway. RFS would work okay to get affinity of the soft
> processing, but there would be no point in trying to do any affinity
> with incoming cpu so this feature wouldn't help.

This is why I think this patch can hurt users.

RPS/RFS/smp_affinity/SO_REUSEPORT/cpuhotplug are only hints, that would
never break TCP session establishment, even with hash collisions and
sockets being added/deleted to SO_REUSEPORT pools.

It works in _all_ situations. Even the crazy/stupid setups.

Your patch is breaking this rule, without any clear documentation on how
to make sure everything is properly setup.

I am not sure my tcp listener stuff will be finished for 4.2, because I
had to spend lot of time to more urgent stuff lately, like reviewing
patches ;)

I would prefer your patch is added for 4.3, not before.
