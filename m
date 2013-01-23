From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH net] r8169: remove the obsolete and incorrect AMD
 workaround
Date: Wed, 23 Jan 2013 08:14:08 +0200
Message-ID: <20130123081408.2646fc4e@vostro>
References: <20130121234205.GA12449@electric-eye.fr.zoreil.com>
	<1358843435-24719-1-git-send-email-timo.teras@iki.fi>
	<20130123000541.GA9515@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:50401 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab3AWGN5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 01:13:57 -0500
Received: by mail-ee0-f50.google.com with SMTP id e51so3908651eek.23
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 22:13:56 -0800 (PST)
In-Reply-To: <20130123000541.GA9515@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jan 2013 01:05:41 +0100 Francois Romieu
<romieu@fr.zoreil.com> wrote:

> Timo Ter=C3=A4s <timo.teras@iki.fi> :
> [...]
>=20
> Acked-by: Francois Romieu <romieu@fr.zoreil.com>
>=20
> desc->opts2 is now a bit different in the RxRes path - the only path
> where the patch can be noticed. I hope it won't uncloak something
> else.

I was wondering what you mean by this. But as it seems
rtl8169_rx_vlan_tag() is doing opts2 =3D 0 in receive path. So the
only effect the workaround would have had was for the error path
packets.

So if this worries you, would it make sense to just unconditionally set
opts2 to zero also in the error path?

Actually, this sounds wrong. Why is rtl8169_rx_vlan_tag() which is
fiddling opts2 invoked *after* rtl8169_mark_to_asic() ? This means it
can overwrite the tag info if the queue is full.

- Timo
