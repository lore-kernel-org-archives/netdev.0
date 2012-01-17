From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HSR: Standard breaks alignment. Solution?
Date: Tue, 17 Jan 2012 09:32:05 +0100
Message-ID: <1326789125.2564.54.camel@edumazet-laptop>
References: <4F14AE66.7060301@enea.com>
	 <1326787481.3342.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arvid Brodin <arvid.brodin@enea.com>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47503 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189Ab2AQIcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 03:32:10 -0500
Received: by wgbdq11 with SMTP id dq11so1600569wgb.1
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2012 00:32:09 -0800 (PST)
In-Reply-To: <1326787481.3342.2.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 17 janvier 2012 =C3=A0 09:04 +0100, Johannes Berg a =C3=A9crit=
 :
> On Tue, 2012-01-17 at 00:10 +0100, Arvid Brodin wrote:
> > As I've written before here, I'm trying to add support for the HSR =
protocol
> > ("High-availability Seamless Redundancy") to the linux kernel. The =
protocol is
> > specified in IEC-62439-3, and involves adding a protocol tag after =
the ethhdr
> > on outgoing frames, and stripping it again on reception, much like =
VLAN.
> >=20
> > This HSR tag is 6 bytes long, which breaks 32-bit header alignment =
and causes
> > an Oops and a kernel panic in icmp_echo on the receiving side of pi=
ngs (here,
> > exactly: http://lxr.linux.no/#linux+v2.6.37/net/ipv4/icmp.c#L838 )
> >=20
> > If I add two bytes of padding to the HSR tag everything works beaut=
ifully. But
> > of course that breaks any pretense of standard compliance.
> >=20
> > Is there some way to fix this without having to memmove the whole f=
rame payload
> > 2 bytes on reception?
>=20
> I don't think there's any other choice, but you can use
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS to see whether you actually ne=
ed
> to do it.

Or test if NET_IP_ALIGN is 0, it might be more explicit.
