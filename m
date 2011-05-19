From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] ethtool: ETHTOOL_SFEATURES: remove NETIF_F_COMPAT
 return
Date: Thu, 19 May 2011 11:18:33 +0200
Message-ID: <20110519091833.GA24484@rere.qmqm.pl>
References: <1305513923.19966.20.camel@localhost>
 <20110516132807.1A89F13A6A@rere.qmqm.pl>
 <1305553066.19966.32.camel@localhost>
 <20110516142340.GA2980@rere.qmqm.pl>
 <1305557597.2885.5.camel@bwh-desktop>
 <20110516205137.GA7667@rere.qmqm.pl>
 <1305580139.2885.47.camel@bwh-desktop>
 <20110516215034.GA8463@rere.qmqm.pl>
 <1305583775.2885.65.camel@bwh-desktop>
 <1305745379.2929.9.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35721 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932832Ab1ESJSf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 05:18:35 -0400
Content-Disposition: inline
In-Reply-To: <1305745379.2929.9.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2011 at 08:02:59PM +0100, Ben Hutchings wrote:
> On Mon, 2011-05-16 at 23:09 +0100, Ben Hutchings wrote:
> > On Mon, 2011-05-16 at 23:50 +0200, Micha=B3 Miros=B3aw wrote:
> > > On Mon, May 16, 2011 at 10:08:59PM +0100, Ben Hutchings wrote:
> > > > I've explained before that I do not want to add new options to =
do
> > > > (mostly) the same thing.  Users should have not have to use a d=
ifferent
> > > > command depending on the kernel version.
> > > We can avoid new option by checking feature-strings for unrecogni=
sed
> > > arguments to -K. This way, we will have the old options which wor=
k
> > > regardless of kernel version ('tx', 'rx', 'sg', etc.) and new opt=
ions
> > > which need recent kernel anyway (separated 'tx-checksum-*', 'loop=
back',
> > > others coming in for 2.6.40).
> > This is just too subtle a distinction.  It will mostly confuse user=
s.
> Sorry, I think I misunderstood you here.  I agree that new feature na=
mes
> that do not correspond exactly to existing keywords should be support=
ed
> as keywords after the -K option.  I think those that do (e.g.
> "tx-udp-fragmentation" vs "ufo") should not be, as adding a
> kernel-version-dependent *alias* would be confusing.

The alias can be marked as such in the documentation. Shouldn't it be
that hard for a user to read the manpage to know what the new options
are for when he sees them. I don't like the idea of translating strings=
,
either, because if e.g. ufo becomes split in the feature to ufo4+ufo6
or new checksum offloads are implemented, it will break.

> I also want users to benefit from your improvements (as I explained
> above) even when they use the old names, if they are using a new kern=
el
> version.  That is why I want ethtool to try using ETHTOOL_SFEATURES
> first, and why the fallback in the kernel is problematic.

Which benefits do you want to have? If checking what other features
changed with selected one, it's easily done by rereading the state -
possibly with GFEATURES.

I'll cook another PoC patch over those I sent to show the idea.

Best Regards,
Micha=B3 Miros=B3aw
