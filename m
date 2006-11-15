From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 11:03:10 +0100
Message-ID: <1163584990.2705.32.camel@ux156>
References: <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Jouni Malinen <jkm@devicescape.com>,
	Daniel Drake <dsd@gentoo.org>, Hong Liu <hong.liu@intel.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	David Kimdon <dwhedon@devicescape.com>,
	Udayan Singh <udayan.singh@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49095 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966732AbWKOKCF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 05:02:05 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I would go further - and perhaps move some of the meta-data that is in
> the skb->cb into a d80211 specific hardware header. This would allow
> sniffers to directly attach to the master device and both send and
> receive frames complete with the meta data. It would also reduce the
> amount of cb space we need. Virtual devices could be created in order to
> use sniffers that use a different hardware header format (with a small
> performance penalty when using those).

I'm not sure this is a good idea, it locks us in to some format because
user-space uses it and we'd need to serialise to that format to be
extensible.

On the other hand, we could fix some part of the structure to be
user-space visible, make it a real struct that just lives before the
802.11 header and don't serialise like it would be necessary with
something that is extensible. On RX, we could do the same.

For TX, this would allow applications to control whatever we put into
that struct (I would not, for example, allow tx status notifications to
ever go over a netdev as we do now), while for RX it would allow apps to
see almost everything.

It might complicate code a bit because different things would come from
different places (some things from a special header and some from
skb->cb), but I don't think it would be bad.

Other than this, I agree with you.

johannes
