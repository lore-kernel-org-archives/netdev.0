From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 08:38:14 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B5DE5@dhost002-46.dex002.intermedia.net>
References: <20061102144536.GA5352@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jiri Benc" <jbenc@suse.cz>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:62763 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751995AbWKBQiF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 11:38:05 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20061102144536.GA5352@infradead.org>
To: "Christoph Hellwig" <hch@infradead.org>,
	"Johannes Berg" <johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I don't believe it makes sense to change the frame type except for the
master interface. The interface to an 802.11 MAC (the MAC-SAP) is very
similar to the interface to an 802.3 MAC. It is a 2 address format - not
3 or 4. The master interface is an internal part of the MAC, and here
802.11 frames are essential.

Simon 

-----Original Message-----
From: Christoph Hellwig [mailto:hch@infradead.org] 
Sent: Thursday, November 02, 2006 6:46 AM
To: Johannes Berg
Cc: Christoph Hellwig; Jiri Benc; James Ketrenos; John W. Linville;
Simon Barber; Jeff Garzik; Patrick McHardy; David Kimdon;
netdev@vger.kernel.org
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
d80211-specific qdisc

On Thu, Nov 02, 2006 at 03:32:34PM +0100, Johannes Berg wrote:
> On Thu, 2006-11-02 at 14:18 +0000, Christoph Hellwig wrote:
> 
> > This is not about the name that makes sense.  I think using ethX 
> > names for wireless devices is utterly stupid, but it's what all 
> > current upstream drivers do, and at least for WE compat we'll have
to stick to it.
> 
> No, that's not true, zd1201 doesn't [1] :) Has anyoen ever complained 
> about that? In any case, tools iterate all netdevs and call some 
> wireless ioctl to check if they are wireless, or check 
> /proc/net/wireless (which is actually bad, but ...).
> 
> Besides, WE never said that names have to have certain names. What 
> makes you think so?

I never said the name was related to WE - in fact there are tons of out
of tree drivers with different names.  The important bit is that
upgrading a kernel adn changing the wireless stack must not change the
device name.
All my scripts expect my bcm43xx card to be eth1 and not wifi0 or
wlansomething.  There's in fact another much worse migration prblem when
we want to do wlan support correctly: the advertised frametype still is
802.3 for all wlan devices (which make the current ethX names correct in
some obscure very technical way) and we need to make them raw 802.11
long-term.  It will probably make sense to do both migrations at the
same time and have a CONFIG_ option to force the old behaviour [1].

[1] I really hate config options affecting the abi, but this is a tough
    problem as we can't have a etdevice with different frametypes for
    the same piece of hardware.  maybewe could at least make it a module
    option..
