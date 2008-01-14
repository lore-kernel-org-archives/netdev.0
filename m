From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: occasionally corrupted network stats in /proc/net/dev
Date: Mon, 14 Jan 2008 12:41:09 -0800
Message-ID: <1200343269.15122.23.camel@dell>
References: <478B99E6.2050800@hp.com> <478BA53B.9060504@candelatech.com>
 <478BA8D7.8050803@hp.com> <478BAF47.10607@hp.com>
 <478BB43B.8060905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Mark Seger" <Mark.Seger@hp.com>,
	"Ben Greear" <greearb@candelatech.com>,
	"netdev" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2323 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755428AbYANTzY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 14:55:24 -0500
In-Reply-To: <478BB43B.8060905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-01-14 at 20:12 +0100, Eric Dumazet wrote:
> Mark Seger a =C3=A9crit :
> > Ignore that last one as it was pointed out to me that we have both =
nic=20
> > installed on many of our systems and ethtool told me the one=20
> > associated with the nic is actually the broadcom one.
> >
> > version:        1.4.38 E1B1EC867DEEB8027B2DA0F
> > license:        GPL
> > description:    Broadcom NetXtreme II BCM5706/5708 Driver
> >
>=20
> I remember some tg3 chips actually have bugs when reporting stats....=
=20
> once in a while
>=20
> CCed to Michael Chan to get some details.

Yes, that's right.  Some BNX2 chips have this problem and we have a
workaround:

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcommi=
t;h=3D02537b0676930b1bd9aff2139e0e645c79986931

The chip sometimes DMA wrong counter values if the chip is also
internally gathering the counters at the time of the DMA.

Driver 1.5.11 and later versions have this workaround.


