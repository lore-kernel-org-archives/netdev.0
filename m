From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 3/3] bonding,ipv4,ipv6,vlan: Handle
 NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS
Date: Tue, 19 Apr 2011 15:56:59 +0100
Message-ID: <1303225019.2988.3.camel@bwh-desktop>
References: <1302911271.2845.41.camel@bwh-desktop>  <22334.1302913805@death>
	 <1303153792.2857.32.camel@bwh-desktop>  <4DACE638.9060909@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:10039 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912Ab1DSO5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2011 10:57:04 -0400
In-Reply-To: <4DACE638.9060909@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-04-18 at 21:32 -0400, Brian Haley wrote:
> On 04/18/2011 03:09 PM, Ben Hutchings wrote:
> > How about restoring the parameters like this:
> > 
> > ---
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Mon, 18 Apr 2011 19:36:48 +0100
> > Subject: [PATCH net-next-2.6] ipv4,ipv6,bonding: Restore control over number of peer notifications
> > 
> > For backward compatibility, we should retain the module parameters and
> > sysfs attributes to control the number of peer notifications
> > (gratuitous ARPs and unsolicited NAs) sent after bonding failover.
> > Also, it is possible for failover to take place even though the new
> > active slave does not have link up, and in that case the peer
> > notification should be deferred until it does.
> > 
> > Change ipv4 and ipv6 so they do not automatically send peer
> > notifications on bonding failover.  Change the bonding driver to send
> > separate NETDEV_NOTIFY_PEERS notifications when the link is up, as
> > many times as requested.  Since it does not directly control which
> > protocols send notifications, make num_grat_arp and num_unsol_na
> > aliases for a single parameter.
> 
> Hi Ben,
> 
> I think this looks good, I'll try and get this tested here when I have
> a chance, but for now I can:
> 
> Acked-by: Brian Haley <brian.haley@hp.com>
> 
> Should we just go ahead and make a new parameter for peer notification?
> Compiled but untested patch below.
[...]

If everyone is in agreement to deprecate the old parameters in favour of
a single parameter (or none) I think there should be a target date for
removal, documented in Documentation/feature-removal-schedule.txt.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

