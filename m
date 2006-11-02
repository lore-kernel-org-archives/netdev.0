From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific qdisc
Date: Thu, 2 Nov 2006 14:45:36 +0000
Message-ID: <20061102144536.GA5352@infradead.org>
References: <20061026050416.GB14199@havoc.gtf.org> <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net> <20061101112805.246e1b3b@griffin.suse.cz> <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com> <20061102121657.GA13468@infradead.org> <20061102150550.5c30f704@midnight> <20061102141815.GA1795@infradead.org> <1162477954.10786.11.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, Jiri Benc <jbenc@suse.cz>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:5047 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751079AbWKBOsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 09:48:20 -0500
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1162477954.10786.11.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 02, 2006 at 03:32:34PM +0100, Johannes Berg wrote:
> On Thu, 2006-11-02 at 14:18 +0000, Christoph Hellwig wrote:
> 
> > This is not about the name that makes sense.  I think using ethX names
> > for wireless devices is utterly stupid, but it's what all current upstream
> > drivers do, and at least for WE compat we'll have to stick to it.
> 
> No, that's not true, zd1201 doesn't [1] :) Has anyoen ever complained
> about that? In any case, tools iterate all netdevs and call some
> wireless ioctl to check if they are wireless, or
> check /proc/net/wireless (which is actually bad, but ...).
> 
> Besides, WE never said that names have to have certain names. What makes
> you think so?

I never said the name was related to WE - in fact there are tons of out of
tree drivers with different names.  The important bit is that upgrading a
kernel adn changing the wireless stack must not change the device name.
All my scripts expect my bcm43xx card to be eth1 and not wifi0 or
wlansomething.  There's in fact another much worse migration prblem
when we want to do wlan support correctly: the advertised frametype still
is 802.3 for all wlan devices (which make the current ethX names correct
in some obscure very technical way) and we need to make them raw 802.11
long-term.  It will probably make sense to do both migrations at the
same time and have a CONFIG_ option to force the old behaviour [1].

[1] I really hate config options affecting the abi, but this is a tough
    problem as we can't have a etdevice with different frametypes for
    the same piece of hardware.  maybewe could at least make it a module
    option..
