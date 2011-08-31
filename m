From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 20:11:32 +0200
Message-ID: <CAHXqBFKA0uHn7-KPSKmktXxKDbm9249+49NK42Pnmmg+N60eAw@mail.gmail.com>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
 <201108311501.39936.vladz@broadcom.com> <20110831155324.7554d035@alice>
 <201108311807.53767.vladz@broadcom.com> <20110831173749.60649b50@alice> <20110831175120.739bd5c2@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Zolotarov <vladz@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Dmitry Kravkov <dmitry@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:48928 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756967Ab1HaSLw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 14:11:52 -0400
Received: by iabu26 with SMTP id u26so991307iab.19
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2011 11:11:52 -0700 (PDT)
In-Reply-To: <20110831175120.739bd5c2@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/8/31 Michal Schmidt <mschmidt@redhat.com>:
> On Wed, 31 Aug 2011 17:37:49 +0200 Michal Schmidt wrote:
>> I could restore dev->features before
>> returning if bnx2x_reload_if_running() fails.
>
> Or even safer - restore them always:
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0u32 orig_features =3D dev->features;
> =A0 =A0 =A0 =A0dev->features =3D features;
> =A0 =A0 =A0 =A0ret =3D bnx2x_reload_if_running(dev);
> =A0 =A0 =A0 =A0dev->features =3D orig_features;
> =A0 =A0 =A0 =A0return ret;
> =A0 =A0 =A0 =A0...
> This way we don't have to assume anything about
> __netdev_update_features().

The assignment in __netdev_update_features() is just to save copying
that assignment all over the drivers' code. This won't change unless
someone wants to break^Wchange the design.

Best Regards,
Micha=B3 Miros=B3aw
