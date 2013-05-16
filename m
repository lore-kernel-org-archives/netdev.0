From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards compatibility
Date: Thu, 16 May 2013 21:08:23 +0200
Message-ID: <87mwrueo9k.fsf@nemi.mork.no>
References: <20130516182510.GA4728@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48491 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab3EPTIi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 15:08:38 -0400
In-Reply-To: <20130516182510.GA4728@redhat.com> (Dave Jones's message of "Thu,
	16 May 2013 14:25:10 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> writes:

> Hi Bj=C3=B8rn,
>
>  > Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3D1e8bbe6cd0=
2fc300c88bd48244ce61ad9c7d1776
>  > Commit:     1e8bbe6cd02fc300c88bd48244ce61ad9c7d1776
>  > Parent:     a5b8db91442fce9c9713fcd656c3698f1adde1d6
>  > Author:     Bj=C3=B8rn Mork <bjorn@mork.no>
>  > AuthorDate: Thu Mar 14 01:05:13 2013 +0000
>  > Committer:  David S. Miller <davem@davemloft.net>
>  > CommitDate: Sun Mar 17 11:59:03 2013 -0400
>  >=20
>  >     net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards=
 compatibility
>  >    =20
>  >     commit bd329e1 ("net: cdc_ncm: do not bind to NCM compatible M=
BIM devices")
>  >     introduced a new policy, preferring MBIM for dual NCM/MBIM fun=
ctions if
>  >     the cdc_mbim driver was enabled.  This caused a regression for=
 users
>  >     wanting to use NCM.
>  >    =20
>  >     Devices implementing NCM backwards compatibility according to =
section
>  >     3.2 of the MBIM v1.0 specification allow either NCM or MBIM on=
 a single
>  >     USB function, using different altsettings.  The cdc_ncm and cd=
c_mbim
>  >     drivers will both probe such functions, and must agree on a co=
mmon
>  >     policy for selecting either MBIM or NCM.  Until now, this poli=
cy has
>  >     been set at build time based on CONFIG_USB_NET_CDC_MBIM.
>  >    =20
>  >     Use a module parameter to set the system policy at runtime, al=
lowing the
>  >     user to prefer NCM on systems with the cdc_mbim driver.
>
> Is there any way we can set this automatically based on the type of d=
evice connected
> and have it just work without users needing to edit modprobe.conf ?
>
> Since this change, we've now getting reports like https://bugzilla.re=
dhat.com/show_bug.cgi?id=3D963663

Yes, this is a very unfortunate side effect of the userspace/kernel
split of the MBIM driver combined with the NCM/MBIM "backwards
compatibility" setting.  Which in itself is a bad idea, IMHO.

I recommend all distros do the same as Debian: Set NCM as default until
a userspace application with MBIM support is ready and packaged in the
distro:
http://anonscm.debian.org/viewvc/kernel/dists/trunk/linux/debian/patche=
s/debian/cdc_ncm-cdc_mbim-use-ncm-by-default.patch

=46WIW, I wish we would have thought about this issue before v3.8 was
released.  Then we could have made that patch the mainline default,
without that being a userspace API change.  But we didn't.

The good news is that Aleksander has done some nice work on the MBIM
support in ModemManager, so there is a good chance that the next releas=
e
will make this problem go away.



Bj=C3=B8rn
