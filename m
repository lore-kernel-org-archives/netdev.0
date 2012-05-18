From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCPBacklogDrops during aggressive bursts of traffic
Date: Fri, 18 May 2012 20:40:43 +0200
Message-ID: <1337366443.5101.3.camel@edumazet-laptop>
References: <1337092718.1689.45.camel@kjm-desktop.uk.level5networks.com>
	 <1337093776.8512.1089.camel@edumazet-glaptop>
	 <1337099368.1689.47.camel@kjm-desktop.uk.level5networks.com>
	 <1337099641.8512.1102.camel@edumazet-glaptop>
	 <1337100454.2544.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <1337101280.8512.1108.camel@edumazet-glaptop>
	 <1337272292.1681.16.camel@kjm-desktop.uk.level5networks.com>
	 <1337272654.3403.20.camel@edumazet-glaptop>
	 <1337355955.15044.24.camel@kjm-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org
To: Kieran Mansley <kmansley@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:64443 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966491Ab2ERSkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 14:40:47 -0400
Received: by wibhj8 with SMTP id hj8so437729wib.1
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 11:40:46 -0700 (PDT)
In-Reply-To: <1337355955.15044.24.camel@kjm-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 18 mai 2012 =C3=A0 16:45 +0100, Kieran Mansley a =C3=A9crit=
 :

> > With net-next and tcp coalescing, I no longer have TCPBacklogDrops =
/
> > collapses, but I dont have sfc card/driver.=20
>=20
> I'll try that.

By the way, we should get rid of napi_get_frags() & napi_gro_frags() AP=
I
and use plain build_skb() instead.

This would save 1024 bytes per skb, and remove lot of GRO code (frag0,
frag0_len, skb_gro_header_fast(), skb_gro_header_hard()...), since by
definition skb->head would point to the frame.
