From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next  1/2] vxlan: Notify drivers for listening UDP port
 changes
Date: Wed, 28 Aug 2013 12:43:32 +0100
Message-ID: <1377690212.2552.12.camel@deadeye.wl.decadent.org.uk>
References: <1377665218-6760-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <kvk9um$j48$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11804 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab3H1Lni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 07:43:38 -0400
In-Reply-To: <kvk9um$j48$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 07:47 +0000, Cong Wang wrote:
> On Wed, 28 Aug 2013 at 04:46 GMT, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > From: Joseph Gasparakis <joseph.gasparakis@intel.com>
> >
> > This patch adds two more ndo ops: ndo_add_rx_vxlan_port() and
> > ndo_del_rx_vxlan_port().
> >
> > Drivers can get notifications through the above functions about changes
> > of the UDP listening port of VXLAN. Also, when physical ports come up,
> > now they can call vxlan_get_rx_port() in order to obtain the port number(s)
> > of the existing VXLAN interface in case they already up before them.
> >
> > This information about the listening UDP port would be used for VXLAN
> > related offloads.
> >
> 
> Since this is a notification, how about adding a new NETDEV_* event
> rather than adding two new ndo_* ops?

Since this is a change at the netns (rather than net device) level, it
makes more logical sense to send a single notification for each change.
But any driver that needs to know about this would then need to iterate
over its own devices (limited to the given netns) - which means writing
the same iteration in each driver that supports this (with added
filtering by driver), or adding a list of devices to each driver.  So
practically it seems better to do this iteration in the core as
proposed.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
