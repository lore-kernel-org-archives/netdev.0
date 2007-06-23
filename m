From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 22:27:20 +0200
Message-ID: <20070623202719.GA26290@via.ecp.fr>
References: <27277.3431.qm@web25707.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	cananian@gmail.com, "C. Scott Ananian" <cscott@laptop.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from durga.via.ecp.fr ([138.195.130.75]:55564 "EHLO durga.via.ecp.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110AbXFWU1V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 16:27:21 -0400
Content-Disposition: inline
In-Reply-To: <OFBCA57EE5.DABFEB20-ON88257303.00601DB3-88257303.00618B1D@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 23, 2007, David Stevens wrote:
>         There certainly may be complications I haven't thought of, si=
nce
> I haven't implemented it. But I still don't see a good case for using=
 the
> kernel as a DNS database.

Excuse me for being a bit confused by the approach that you suggest, as
so far it doesn't look very good to me either: I would be glad if you
could clarify some points for the sake of the discussion.

>         The kernel should do the authentication, as it will for other
> RA's, and should not deliver (IMAO) unauthenticated packets. If it is=
,
> I would consider that a bug (for all cases, not just this), and that
> would be a good thing to fix. :-)

You were talking about a raw ICMPv6 socket, right? Though, isn't the
point of a "raw" socket to be raw? Would it be a "not-so-raw" raw
socket, dropping a few unwanted packets?

>         An interface going down doesn't directly invalidate a DNS
> server address, though it may not be the best through another
> interface. Since it is a list, I think "doing nothing" for this case
> wouldn't be terrible. This is no worse than the existing resolver
> code. But if you really need it, you can monitor netlink, or poll the
> interface flags on whatever interval you require for detection.
>         As for autoconf, that's available from sysctl, I assume from
> /proc somewhere, too. That usually doesn't change, but if you want
> to account for runtime configuration changes, you can always monitor
> netlink and reread when new addresses appear, too.

If I understand well you suggest that in order to do things properly,
the application should keep track of a lot of kernel-related stuff? I
mean, the daemon, as the simple piece of code that you seem to have in
mind, should only care about processing RA options that it receives:
network/RA/configuration/availability concerns are precisely the role
of the kernel, which it is already fulfilling, isn't it? It just looks
naturally workable in the case where the kernel processes these options
first, and then handles them to the daemon.

Also, I think that RAs can be considered as a part of IPv6, right? As
opposed to DHCP that is indeed an applicative protocol, I can't see why
parts of a network protocol should be managed by a (non-networking)
userland application. Saying that "it can only be used at application
layer" doesn't look like a very good case for having networking packets
handled by userland instead of the kernel, and seems rather selfish fro=
m
the OS. Am I expecting too much as a user?

I had the understanding that it was a better design to clearly handle
autoconfiguration in one place, and not to scatter it between kernel
and userland. For some reason, it is done in the kernel: do you mean
that now the kernel should only support partial, half-way handling of
RAs? It may seem a bit awkward as a solution.

To me, it looks much more consistent that since the kernel already
parses RA options that it needs, it be in charge of wholly processing
the RA and extract and export all its options. That would be indeed
practical, less error-prone and maybe more efficient than duplicating
all the work to userland. Couldn't it be?

After all, the fact that RDNSS be accepted as an RA option is an
argument to say that it belongs in the kernel, not as DNS, but as an RA
option. As you are saying to R=E9mi, your intent is to fix or enhance t=
he
existing, generic means of the kernel to provide an accurate access to
these RA options, right? Isn't it just what we all want?

--=20
Pierre Ynard
WTS #51 - No phone
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
