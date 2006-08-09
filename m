From: Dan Williams <dcbw@redhat.com>
Subject: Re: d80211 merge plans
Date: Wed, 09 Aug 2006 10:37:55 -0400
Message-ID: <1155134276.3615.16.camel@localhost.localdomain>
References: <200608090703.45651.mb@bu3sch.de>  <44D9754B.3060909@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:30658 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750897AbWHIOhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 10:37:04 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44D9754B.3060909@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-09 at 01:40 -0400, Jeff Garzik wrote:
> Michael Buesch wrote:
> > To heavily reduce maintainance burden I would like to see d80211
> > going mainline as soon as possible, so that we can feature-freeze
> > the softmac port of bcm43xx and reduce maintainance to next to zero
> > there. So if people want freaky features, we simply point them
> > to the d80211 port, which would coexist in mainline.
> > 
> > d80211 in mainline would clearly marked as experimental, for sure.
> > Notes must be added for possibly breaking usermode interfaces.
> 
> 
> Does it have active maintainers?
> 
> The DeviceScape people seem to have disappeared for months, except for a 
> rare appearance recently by Jouni.
> 
> Did anyone ever come up with a list of why d80211 is superior?

For one, it's got a _much_ more flexible device model than the current
hostap/ipw-based stack, more like the net80211 stack for
Atheros/madwifi.  I think that's one of the main benefits.  i.e., you
can have the d80211 cards be any combination of [AP | client | wds? ] at
any given time.  Think of a repeater node, which is both an AP and
client at the same time, all with one card.  That's one of the things a
lot of people like about net80211.

Secondly, DS is also working hard on moving a lot of the higher-level
processing to user space.  Management frames and other more complex
operations will eventually be pushed up to a fused wpa_supplicant
+hostapd running in user space, which should (a) reduce the amount of
kernel driver code, (b) increase flexibility of configuration, and (c)
make any kernel API/ABI/etc much smaller since you don't have to push so
much configuration down into the kernel itself.

That's a start (please correct me if I'm wrong on any of this).

Dan

> What are the remaining d80211 issues?
> 
> 	Jeff
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

