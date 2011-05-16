From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net-2.6] ethtool: Remove fallback to old ethtool
 operations for ETHTOOL_SFEATURES
Date: Mon, 16 May 2011 14:13:39 +0200
Message-ID: <20110516121339.GA1094@rere.qmqm.pl>
References: <1305335142.2851.70.camel@bwh-desktop>
 <20110514103539.GA5214@rere.qmqm.pl>
 <1305513923.19966.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:50247 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab1EPMNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 08:13:41 -0400
Content-Disposition: inline
In-Reply-To: <1305513923.19966.20.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 03:45:23AM +0100, Ben Hutchings wrote:
> On Sat, 2011-05-14 at 12:35 +0200, Micha=B3 Miros=B3aw wrote:
> > On Sat, May 14, 2011 at 02:05:42AM +0100, Ben Hutchings wrote:
> > > ethtool_set_feature_compat() squashes the feature mask into a boo=
lean,
> > > which is not correct for ethtool_ops::set_flags.
> > >=20
> > > We could fix this, but the fallback code for ETHTOOL_SFEATURES ac=
tually
> > > makes things more complicated for the ethtool utility and any oth=
er
> > > application using the ethtool API.  They will still need to fall =
back to
> > > the old offload control commands in order to support older kernel
> > > versions.  The fallback code in the kernel adds a third possibili=
ty for
> > > them to handle.  So make ETHTOOL_SFEATURES fail when the driver
> > > implements the old offload control operations, and let userland d=
o the
> > > fallback.
> > BTW, the idea behind the compat code is that if ETHTOOL_[GS]FEATURE=
S is
> > available, then there should be no need to fallback to old ops. For
> > a userspace tool that targets only kernels >=3D 2.6.39 there's no n=
eed
> > to care about old ops at all.
> Well that's not true, because those tools still have to deal with
> ETHTOOL_F_COMPAT.  And we're supposed to have all drivers converted f=
or
> 2.6.40, so the hypothetical new tool only has to wait one more releas=
e.

I think that handling ETHTOOL_F_COMPAT is like ETHTOOL_F_WISH - the too=
l
needs to reread features and check what was changed. So we can get rid
of the former by replacing it with the latter.

Changing some feature state may change others that were not requested
to be changed (not present in .valid). This probably should be signalle=
d
as well. Extend ETHTOOL_F_WISH meaning (I prefer this one) or introduce
new bit?

Best Regards,
Micha=B3 Miros=B3aw
