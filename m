From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] net: make CONFIG_BQL actually end user configurable
Date: Mon, 5 Mar 2012 23:09:21 -0500
Message-ID: <20120306040921.GA24032@windriver.com>
References: <1331005096-12332-1-git-send-email-paul.gortmaker@windriver.com>
 <CAA93jw5HadpvBvtZvf6ArK3tdm=7Cs9sLYeHO9WN6rJOfPLPbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <therbert@google.com>, <davem@davemloft.net>,
	<eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:48401 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757895Ab2CFEJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:09:26 -0500
Content-Disposition: inline
In-Reply-To: <CAA93jw5HadpvBvtZvf6ArK3tdm=7Cs9sLYeHO9WN6rJOfPLPbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH] net: make CONFIG_BQL actually end user configurable] On 05=
/03/2012 (Mon 19:45) Dave Taht wrote:

>=20
>=20
> On Mon, Mar 5, 2012 at 7:38 PM, Paul Gortmaker <paul.gortmaker@windri=
ver.com>
> wrote:
>=20
>     Without the defining string or help text, LKC won't ever bother
>     to ask the end user for a setting for CONFIG_BQL -- you could
>     delete it from your .config and run make oldconfig and not a
>     thing would change -- it would still be silently re-enabled.
>=20
>=20
>=20
> My specific problems with BQL as currently implemented are:
>=20
> 1) There is no way to tell if a driver has it actually enabled or not
> at run time.

In a similar vein, I was interested in a (quick) way to tell if a
driver has it actually enabled *correctly*.  I'd coded up the basic
changes for a common PPC NIC, but I was then left wondering what I
could use as a quick high-water-mark to see if I'd really managed
to implement it correctly via some level of real run-time testing.

If we want to get driver authors involved in adding support to their
favourite hardware, some description of a basic sanity test would
probably be a worthwhile description to have.

Paul.
--

>=20
> 2) Down below 100Mbit (the range that I care about) the controller
> can automatically allocate more ram than I would like for the outstan=
ding
> data. I can (and do) easily control this by overriding the BQL defaul=
t
> to something that makes things behave closer to what a ns2 model
> would predict (about 3k seems optimal) without affecting throughput.
>=20
> whether or not this is a problem in the real world is yet to be seen.
> =20
>=20
>     While most people will have no reason to turn this off, the
>     ability to do so can be useful for testing BQL support additions
>     on previously BQL-unaware drivers and similar.
>=20
>     The kconfig help text is largely taken from the original RFC
>     patchset 0/N header sent to netdev@vger.kernel.org in fall 2011.
>=20
>     Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>     ---
>=20
>     [Apologies if this was explicitly blocked for a reason; I couldn'=
t
>      find a reason after searching netdev or threads at bufferbloat.n=
et ]
>=20
>     diff --git a/net/Kconfig b/net/Kconfig
>     index e07272d..fd1d815 100644
>     --- a/net/Kconfig
>     +++ b/net/Kconfig
>     @@ -241,10 +241,15 @@ config NETPRIO_CGROUP
>              a per-interface basis
>=20
>      config BQL
>     -       boolean
>     +       boolean "Byte Queue Limits"
>            depends on SYSFS
>            select DQL
>            default y
>     +       ---help---
>     +         Byte queue limits are a mechanism to limit the size of =
the
>     transmit
>     +         hardware queue on a NIC by a number of bytes. The goal =
of these
>     byte
>     +         queue limits is to reduce latency caused by excessive q=
ueuing in
>     +         hardware without sacrificing throughput.
>=20
>      config HAVE_BPF_JIT
>            bool
>     --
>     1.7.9.1
>=20
>     --
>     To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>     the body of a message to majordomo@vger.kernel.org
>     More majordomo info at  http://vger.kernel.org/majordomo-info.htm=
l
>=20
>=20
>=20
>=20
> --
> Dave T=E4ht
> SKYPE: davetaht
> US Tel: 1-239-829-5608
> http://www.bufferbloat.net
