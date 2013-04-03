From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/6] mac802154: Immediately retry
 sending failed packets
Date: Tue, 02 Apr 2013 22:30:36 -0400 (EDT)
Message-ID: <20130402.223036.1483788180825619960.davem@davemloft.net>
References: <515B8D09.9050304@signal11.us>
	<20130402.220315.1782012687105065631.davem@davemloft.net>
	<515B9318.8090101@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <515B9318.8090101-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Date: Tue, 02 Apr 2013 22:25:28 -0400

> The workqueue in mac802154 is only needed because the current mac802154
> xmit() function is designed to be blocking and synchronous.
> 
> Prior to my patch (#3/6), that very same workqueue would actually queue
> up packets (without bound). That's what my patch fixes.
> 
> The workqueue in mac802154 also serializes the access to the device for
> other functions like setting the channel, ensuring that in the driver
> code, one doesn't have to mutex everything. I'm not sure if that's the
> "right" way to do it, but that's the way it was when I got here.

This is entirely duplicating existing facilities.

Your desire to allow blockability during xmit() on the basis of mutual
exclusion is not well founded.

------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
