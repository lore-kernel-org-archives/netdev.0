From: kuznet@ms2.inr.ac.ru
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast
Date: Thu, 17 Jul 2003 13:06:37 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307170906.NAA13688@dub.inr.ac.ru>
References: <1058431132.5781.32.camel@hades>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, jmorris@redhat.com, pekkas@netcore.fi,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mika.liljeberg@welho.com (Mika Liljeberg)
In-Reply-To: <1058431132.5781.32.camel@hades> from "Mika Liljeberg" at Jul 17, 2003 11:38:53 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I'm not sure you can just remove these. It seems possible (?) to have
> the anycast address configured on one of the interfaces as a unicast at
> the same time. I.e., one of the anycast members could own the address.

They cannot intersect, otherwise RTF_LOCAL thing will not work.

I deliberately blocked attempt to add a local address as anycast
in anycast.c, see another chunk. But even that check is not necessary:
non-superuser may listen only for reserved unicasts, which are
excluded from allowed local addresses by policy. Kernel does not need even
to worry about this.

Actually, the test in ndisc.c was bogus by another reason:
inet_addr_type() checks only for reserved anycasts and non-reserved unicasts,
which would conflict with local addresses, were not detected in any case.

Alexey
