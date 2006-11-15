From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 11:13:42 +0100
Message-ID: <1163585622.2705.40.camel@ux156>
References: <20061115011123.0eb1eff6@logostar.upir.cz>
	 <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
	 <20061115104359.3ce80e3b@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>,
	netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>,
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:8332 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S966736AbWKOKMd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Nov 2006 05:12:33 -0500
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061115104359.3ce80e3b@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-11-15 at 10:43 +0100, Jiri Benc wrote:

> In particular:
> - The operations that make sense for user to perform on wiphy/master
>   interface are different than the ones on virtual interfaces. It isn't
>   this way now.

Which particular operations do you have in mind? Granted, you won't ever
be able to specify the master device as the default route for IP, but
hey. I'd almost bet there are other devices that you can't do this with.

> - Why should master interface appear in ifconfig and similar tools the
>   same way as "virtual" interfaces? If you want to know how users are
>   confused by this, just search some forums.

Because it manages the qdiscs and frames actually show up there. Even
now, you can there see what you're transmitting :)

> - Does attaching of qdiscs to virtual interfaces make sense?

Yes, I do think so. Why not?

> This is a different thing. See the difference between SOCK_RAW and
> SOCK_DGRAM. The interface you are talking about is SOCK_DGRAM. Except
> it supports only one address. The correct solution would be extending
> sockaddr_ll (that's not possible, I know) or introduce a new
> SOCK_SOMETHING type (not possible either, at least in a short term).

I still haven't quite understood this argument. Could you elaborate?

> Except that all other hardware doesn't need things that we need. They
> need just one virtual interface - so their master and virtual interface
> is merged. This is net_device. We need to split it into two things.

That's not really true, if you have a 802.1q network then the raw netdev
is useless without vlan virtuals above unless you unpack the vlan on the
switch giving you a non-802.1q network again.

johannes
