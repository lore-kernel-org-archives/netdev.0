From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 14:47:09 +0200
Message-ID: <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
References: <1236772642-12705-1-git-send-email-pktoss@gmail.com>
	 <200903121759.31024.rusty@rustcorp.com.au>
	 <1295ed070903120044s63b4da71i68add51703952d0f@mail.gmail.com>
	 <200903121946.24847.rusty@rustcorp.com.au>
	 <1236858219.14863.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>, netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f177.google.com ([209.85.219.177]:37071 "EHLO
	mail-ew0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754749AbZCLMrM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 08:47:12 -0400
Received: by ewy25 with SMTP id 25so343161ewy.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 05:47:09 -0700 (PDT)
In-Reply-To: <1236858219.14863.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The problem is that there's no "my carrier detection is accurate" fla=
g
> for drivers. =A0Drivers that don't support carrier detection (say, my
> Belkin PCMCIA NE2k card) always report "carrier on", but of course do=
n't
> support carrier detection. =A0So when NetworkManager looks at the dev=
ice
> and sees "hey, there's a carrier!" it will activate it, because a
> carrier means the cable is plugged in or the PHY *thinks* a cable is
> plugged in.
>
> So NetworkManager checks whether the device supports ethtool get_link=
 or
> MII register carrier status in lieu of a general kernel driver flag f=
or
> "I support carrier detection".
>
> Carrier is not on/off, it needs to be tristate, like on/off/unknown. =
=A0If
> it was unknown, NM could make an intelligent decision about this with=
out
> resorting to ethtool/MII checks. =A0But we don't have that.

This looks like an independent problem imho, one of kernel<->userspace
API. The current 'defacto' way of finding out if detection is supported=
 or
not (ethtool) seems to give the needed information even if somewhat ugl=
y.

The issue discussed here as I understand it is whether virtio should or
should not support carrier status reporting. IMHO it should, since
it is useful functionality and doesn't cost much.

Dan, What is your opinion on that?

Pantelis
