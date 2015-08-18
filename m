From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Tue, 18 Aug 2015 23:40:17 +0200
Message-ID: <20150818214017.GA14914@electric-eye.fr.zoreil.com>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	Ivan Vecera <ivecera@redhat.com>
To: Corinna Vinschen <vinschen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:46855 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321AbbHRVk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 17:40:59 -0400
Content-Disposition: inline
In-Reply-To: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Corinna Vinschen <vinschen@redhat.com> :
> The r8169 driver collects statistical information returned by
> @get_stats64 by counting them in the driver itself, even though many
> (but not all) of the values are already collected by tally counters
> (TCs) in the NIC.  Some of these TC values are not returned by
> @get_stats64.  Especially the received multicast packages are missing
> from /proc/net/dev.
> Rectify this by fetching the TCs and returning them from
> rtl8169_get_stats64.

It is not exactly a some / many / not all / confused [*] picture
- get_stats64 provides software managed values
- ethtool provides hardware only values

[*] ok, rx_missed is kinda special.

> The counters collected in the driver obviously disappear as soon as t=
he
> driver is unloaded so after a driver is loaded the counters always st=
art
> at 0.  The TCs are only reset by a power cycle and there's no known w=
ay
> to reset them programatically. Without further considerations the val=
ues
> collected by the driver would not match up against the TC values.

I'd rather:
1. keep software and hardware stats separated
2. push to userspace the responsibility to offset device specific hardw=
are
   values jumps

My 0.02 =E2=82=AC.

--=20
Ueimor
