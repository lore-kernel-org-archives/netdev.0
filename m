From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Tue, 30 Aug 2011 21:30:11 +0200
Message-ID: <4E5D3A43.1060202@redhat.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com> <1314714646-3642-8-git-send-email-mschmidt@redhat.com> <CAHXqBFLgTHvxL34eR1qX7nEmntyOBXYrg-7LQvW=d8dnDpbhWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, vladz@broadcom.com, dmitry@broadcom.com,
	eilong@broadcom.com
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6152 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754183Ab1H3TaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 15:30:15 -0400
In-Reply-To: <CAHXqBFLgTHvxL34eR1qX7nEmntyOBXYrg-7LQvW=d8dnDpbhWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/30/2011 08:27 PM, Micha=C5=82 Miros=C5=82aw wrote:
> It seems rather convoluted and unnecessary that you mirror
> NETIF_F_HW_VLAN_RX in bp->flags

This mirroring is for the benefit of functions called indirectly from=20
bnx2x_set_features(). They cannot look at dev->features for=20
NETIF_F_HW_VLAN_RX because it's not set before ->ndo_set_features() ret=
urns.

> and then also in fp->flags.  Are the
> fp->flags strictly mirroring hardware state (as in: there is no way
> the states can differ in any point in time where the flags are
> tested)?

Yes. This is the purpose of the second mirroring of the flag.

> For this to be true, the two functions above need to be
> called only without releasing a lock between them that is also taken
> by receive handler.

The flag propagates from bp->flags to fp->flags between unloading and=20
reloading the NIC. The receive handler cannot run at the time.

> Isn't there a flag in the rx descriptor of a
> packet that says if VLAN was stripped? (All that flag keeping would b=
e
> unnecessary then.)

There is no such flag, AFAIK.

Michal
