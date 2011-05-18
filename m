From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Wed, 18 May 2011 20:02:59 +0100
Message-ID: <1305745379.2929.9.camel@bwh-desktop>
References: <20110516121339.GA1094@rere.qmqm.pl>
	 <1305335142.2851.70.camel@bwh-desktop> <20110514103539.GA5214@rere.qmqm.pl>
	 <1305513923.19966.20.camel@localhost>
	 <20110516132807.1A89F13A6A@rere.qmqm.pl>
	 <1305553066.19966.32.camel@localhost> <20110516142340.GA2980@rere.qmqm.pl>
	 <1305557597.2885.5.camel@bwh-desktop> <20110516205137.GA7667@rere.qmqm.pl>
	 <1305580139.2885.47.camel@bwh-desktop> <20110516215034.GA8463@rere.qmqm.pl>
	 <1305583775.2885.65.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59064 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933484Ab1ERTDD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 15:03:03 -0400
In-Reply-To: <1305583775.2885.65.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-16 at 23:09 +0100, Ben Hutchings wrote:
> On Mon, 2011-05-16 at 23:50 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> > On Mon, May 16, 2011 at 10:08:59PM +0100, Ben Hutchings wrote:
[...]
> > > I've explained before that I do not want to add new options to do
> > > (mostly) the same thing.  Users should have not have to use a dif=
ferent
> > > command depending on the kernel version.
> >=20
> > We can avoid new option by checking feature-strings for unrecognise=
d
> > arguments to -K. This way, we will have the old options which work
> > regardless of kernel version ('tx', 'rx', 'sg', etc.) and new optio=
ns
> > which need recent kernel anyway (separated 'tx-checksum-*', 'loopba=
ck',
> > others coming in for 2.6.40).
>=20
> This is just too subtle a distinction.  It will mostly confuse users.
[...]

Sorry, I think I misunderstood you here.  I agree that new feature name=
s
that do not correspond exactly to existing keywords should be supported
as keywords after the -K option.  I think those that do (e.g.
"tx-udp-fragmentation" vs "ufo") should not be, as adding a
kernel-version-dependent *alias* would be confusing.

I also want users to benefit from your improvements (as I explained
above) even when they use the old names, if they are using a new kernel
version.  That is why I want ethtool to try using ETHTOOL_SFEATURES
first, and why the fallback in the kernel is problematic.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

