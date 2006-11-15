From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless notes / pre d80211 merge
Date: Wed, 15 Nov 2006 13:46:25 -0500
Message-ID: <455B6081.2030003@pobox.com>
References: <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	Johannes Berg <johannes@sipsolutions.net>,
	netdev <netdev@vger.kernel.org>,
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
Received: from srv5.dvmed.net ([207.36.208.214]:17552 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030856AbWKOSqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 13:46:49 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F0192722C@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Barber wrote:
> I disagree that the master device is a hack - I also disagree that we
> should use 802.11 format frames anywhere but internally inside the
> 802.11 stack. The 802.11 specification does not use 802.11 format frames
> to communicate with the upper layers - it uses almost exactly the same
> interface as 802.3 ethernet does. This is a 2 address interface. I

The 802.11 specification doesn't communicate with any layer :)  The 
Linux kernel code in question does that.

In Linux it is generally bad form to emulate something (802.3 ethernet, 
in this case).  Overhead increases, performance decreases, and there are 
inevitably emulation bugs.

802.11 /is not ethernet/, and you are already breaking assumptions by 
pretending that it is.


> It is normal to have a single interface to represent the physical
> hardware network interface. This is exactly the pattern that many other
> physical network devices use. Things like sniffing should go on on this
> physical interface - and the changes that johannes proposes are exactly
> the right things to enable this.

Sure... when it behaves like a normal interface.  Stuff like "TX goes 
through the interface, but not RX" is definitely /not/ normal.

	Jeff


