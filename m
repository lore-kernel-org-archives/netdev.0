From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: bad interaction between privacy extensions, prefix lifetimes and protocols that maintain long-term connections.
Date: Wed, 11 Jan 2017 09:54:57 +0100
Message-ID: <87ziiy0ye6.fsf@miraculix.mork.no>
References: <9769f6b7-946c-1279-110f-15de8ec40022@p10link.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: debian-ipv6@lists.debian.org, netdev@vger.kernel.org
To: peter green <plugwash@p10link.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53737 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933306AbdAKI4B (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 03:56:01 -0500
In-Reply-To: <9769f6b7-946c-1279-110f-15de8ec40022@p10link.net> (peter green's
        message of "Sat, 7 Jan 2017 15:16:06 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

peter green <plugwash@p10link.net> writes:

> Disabling privacy extensions solved the issue but obviously reveals
> the MAC address of my new machine to the world which is undesirable.

I have no solution to the problem with privacy extensions, but just
wanted to let you know there is a third alternative for IPv6
autoconfigured addresses: stable-privacy

This will give you addresses which are just as stable as the eui64
addresses, but derived from a configurable secret instead of the
mac. The kernel part is documented in under 'stable_secret' in
https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt

If you use NetworkManager, then this is very easy to set up: Just set
'addr-gen-mode' to 'stable-privacy'.  See the docs in nm-settings(5).

Or if you use ifupdown and prefer to control it yourself, you can
e.g. save the secret (in IPv6 address format) in some file and write it
to /proc/sys/net/ipv6/conf/default/stable_secret on boot.  This will set
a common secret for all interfaces.  Note that the generated interface
ids still will be different, since the prefix is used as part of the
input to the generator.



Bj=C3=B8rn
