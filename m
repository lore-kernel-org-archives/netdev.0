From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather thand80211-specific
 qdisc
Date: Thu, 2 Nov 2006 14:34:21 -0800
Message-ID: <20061102143421.1f6c8ba3@freekitty>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5DE3@dhost002-46.dex002.intermedia.net>
	<1162485837.16971.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Simon Barber <simon@devicescape.com>,
	Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:36815 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751429AbWKBWjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 17:39:42 -0500
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1162485837.16971.5.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 02 Nov 2006 17:43:57 +0100
Johannes Berg <johannes@sipsolutions.net> wrote:

> On Thu, 2006-11-02 at 08:33 -0800, Simon Barber wrote:
> > There are many reasons to have the master device - and many reasons not
> > to get rid of it. The only excpetion is when using a limited fullmac
> > card.  Some fullmac cards only support a single ethernet interface, so
> > for these cards a single device may be OK, if we want to allow multiple
> > different appearences for different types of card (a bad thing in my
> > book). (Note - older prism 54g fullmac cards support WDS, hence need
> > multiple interfaces).
> > 
> > The master interface represents the physical networking device that
> > works using native 802.11 frames. The qdisc works on 802.11 frames - not
> > ethernet, and it can change how 802.11 management frames are queued. It
> > can only be got rid of in the case of a fullmac card with only a single
> > interface, where all management frames are processed in the card.
> > 
> > In addition as we move to make 802.11 devices native (i.e. create an
> > 802.11 protocol) the 802.11 master interface will be essential.
> 
> While these are good points, I don't believe having the master interface
> as a *netdev* is essential. In fact, it now has no functionality as a
> netdev, if you try routing packets over it they're simply dropped.

It makes 802.11 packet capture easier as well.  Please don't invent yet
another network access object for the master device.

> Of course we need some notion of the wireless PHY and cfg80211
> explicitly represents that by assigning a wiphy index, but there's no
> need for it to be a netdev.
> 
> johannes


-- 
Stephen Hemminger <shemminger@osdl.org>
