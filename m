From: Philip Craig <philipc@snapgear.com>
Subject: Re: bridging with gre tunnel
Date: Mon, 14 Jul 2008 18:44:09 +1000
Message-ID: <487B11D9.7090800@snapgear.com>
References: <4876FDF0.1030807@iki.fi> <487AA0CD.9090600@snapgear.com> <487AFF82.4090707@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:53608 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753431AbYGNIoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 04:44:12 -0400
In-Reply-To: <487AFF82.4090707@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s wrote:
> There is an essential difference in this patch compared to the one
> I referred to. This patch adds a new way to create GRE devices which
> results in ethernet style device whereas the older patch modifies
> transmit and receive paths to detect packets coming from bridging
> code and does not need userland changes at all.
>
> I kind of like the fact that userland tools work as-is and that
> I don't need any special flags for the GRE tunnel creation. However
> your patch does look way cleaner.
>
> Any comments on what the solution to merged in should look like?

I posted a cleaner version that's similar to what the old patch
did, see http://marc.info/?l=3Dlinux-netdev&m=3D115449948503549&w=3D2

But I don't think that is the right approach:
- it forces you to use bridging if you only want ethernet over GRE
- the change fundamentally has nothing to do with bridging

BTW, the STP bits in my patch can be removed too if needed, most users
won't want them and they aren't quite right (stp packets are counted
as errors).  I don't even know what device needed it, I just have a
pcap file with the packets.  After removing that, there's nothing
in the patch related to bridging.

Actually, this change doesn't really belong in GRE either, because
that forces you to choose between ethernet encapsulation and not.
It could be a new device that sits on top of GRE and simply does
ethernet encapsulation then passes it to the raw GRE device.
That's a lot of infrastructure for something so simple though,
and I don't think people will want to use both devices at once.
