From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] pktgen: speedup fragmented skbs
Date: Tue, 25 Jan 2011 18:47:33 +0100
Message-ID: <1295977653.3588.339.camel@edumazet-laptop>
References: <1295975635.3588.337.camel@edumazet-laptop>
	 <4D3F06BF.7010903@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34931 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab1AYRrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 12:47:39 -0500
Received: by wwa36 with SMTP id 36so48636wwa.1
        for <netdev@vger.kernel.org>; Tue, 25 Jan 2011 09:47:38 -0800 (PST)
In-Reply-To: <4D3F06BF.7010903@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 janvier 2011 =C3=A0 09:22 -0800, Ben Greear a =C3=A9crit :
> On 01/25/2011 09:13 AM, Eric Dumazet wrote:
> > We spend lot of time clearing pages in pktgen.
> > (Or not clearing them on ipv6 and leaking kernel memory)
> >
> > Since we dont modify them, we can use one zeroed page, and get
> > references on it. This page can use NUMA affinity as well.
> >
> > Define pktgen_finalize_skb() helper, used both in ipv4 and ipv6
>=20
> Some devices, like vlans, can change the skb, but perhaps they
> will not actually mess with the paged data?

Yes, its absolutely forbidden to write on paged data.

If necessary, a COW must be done.



