From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 1/6] mac802154: Immediately retry
 sending failed packets
Date: Tue, 02 Apr 2013 21:24:59 -0400
Message-ID: <515B84EB.8020006@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
	<1364928481-1813-2-git-send-email-alan@signal11.us>
	<CAJmB2rCr5ds11+iN=W5GCKsUgdfb57uKg+mH4NY4CWw6EFCTbg@mail.gmail.com>
	<515B3F78.2020301@signal11.us> <515B4D79.40805@signal11.us>
	<20130402231319.GD28141@ws>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-zigbee-devel <linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Werner Almesberger <werner-SEdMjqphH88wryQfseakQg@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20130402231319.GD28141@ws>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/02/2013 07:13 PM, Werner Almesberger wrote:
> Alan Ott wrote:
>> it's now my opinion that we should _not_ try to retransmit at
>> all in mac802154/tx.c.
> I think the currently blocking workqueue design is ugly and
> quite contrary to how most the rest of the stack works. So
> anything that kills it has my blessing :-)

I like it for a couple of reasons.
1. Most supported devices have only single packet output buffer, so
blocking in the driver is the most straight-forward way to handle it.
The alternative is to make each driver have a workqueue for xmit() (to
lift the blocking out from atomic context). This makes each driver simpler.

2. All of the flow control can be handled one time in the mac802154 layer.

> I do wonder though why it was done like this in the first place.
> Just for convenience ?
>
> If we want to move towards an asynchronous interface, it could
> exist in parallel with the current one. That way, drivers could
> be migrated one by one.

Maybe at some point this will be done. Right now we have a ton of
pressing issues (in my opinion).

> Having said that, the errors you get there may not be failed
> single transmissions on the air but some form of congestion in
> the driver or a problem with the device. But I don't think
> that's a valid reason for retrying the transmission at that
> level.

Agreed. Like I said, I'm now of the opinion that the mac802154 layer
should _not_ retry at all.

Alan.


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
