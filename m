From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than
	d80211-specific qdisc
Date: Thu, 02 Nov 2006 16:02:15 +0100
Message-ID: <1162479735.10786.25.camel@ux156>
References: <20061026050416.GB14199@havoc.gtf.org>
	 <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
	 <20061101112805.246e1b3b@griffin.suse.cz>
	 <20061101142022.GC21668@tuxdriver.com> <4548E7F7.7030100@linux.intel.com>
	 <20061102121657.GA13468@infradead.org> <20061102150550.5c30f704@midnight>
	 <20061102141815.GA1795@infradead.org> <1162477954.10786.11.camel@ux156>
	 <20061102144536.GA5352@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:8104 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750972AbWKBPBx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 10:01:53 -0500
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20061102144536.GA5352@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-11-02 at 14:45 +0000, Christoph Hellwig wrote:

> I never said the name was related to WE - in fact there are tons of out of
> tree drivers with different names.  The important bit is that upgrading a
> kernel adn changing the wireless stack must not change the device name.

Ah, but if that is your point then you should be arguing that the stack
may not dictate the device name at all, in order to keep existing
drivers able to keep whatever devicenames they were creating now...

> All my scripts expect my bcm43xx card to be eth1 and not wifi0 or
> wlansomething.  

But, but.. Kernel-assigned device names aren't really stable in
practise, and in most distros udev will actually assign a stable name
based on the mac address (which will, incidentally, apparently be ethX).

Really though, I don't care about having it ethX, I rename it to
whatever I want in userspace anyway.

> There's in fact another much worse migration prblem
> when we want to do wlan support correctly: the advertised frametype still
> is 802.3 for all wlan devices (which make the current ethX names correct
> in some obscure very technical way) and we need to make them raw 802.11
> long-term.  It will probably make sense to do both migrations at the
> same time and have a CONFIG_ option to force the old behaviour [1].

Making it 802.11 will probably upset dhcp, I'd think. I have no idea how
to handle that, at this time.

johannes
