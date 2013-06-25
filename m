From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 25 Jun 2013 15:46:38 -0700
Message-ID: <20130625154638.357e4764@nehalam.linuxnetplumber.net>
References: <1902752B0C92F943AB7EA9EE13E2DEEC126CC8C873@HQ1-EXCH02.corp.brocade.com>
	<20130624170727.4d7893a1@nehalam.linuxnetplumber.net>
	<51CA1A1B.5080700@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:53409 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab3FYWqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 18:46:42 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa11so13293871pad.33
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 15:46:41 -0700 (PDT)
In-Reply-To: <51CA1A1B.5080700@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 26 Jun 2013 00:30:51 +0200
Arvid Brodin <arvid.brodin@xdin.com> wrote:

> On 2013-06-25 02:07, Stephen Hemminger wrote:
> > On Mon, 24 Jun 2013 09:44:01 -0700
> > Arvid Brodin <arvid.brodin@xdin.com> wrote:
> > 
> >> +
> >> +
> >> +static bool is_admin_up(struct net_device *dev)
> >> +{
> >> +       return dev && (dev->flags & IFF_UP);
> >> +}
> >> +
> >> +static bool is_operstate_up(struct net_device *dev)
> >> +{
> >> +       return (dev && (dev->operstate == IF_OPER_UP));
> >> +}
> >> +
> > 
> > Isn't is_admin_up the same as netif_running()?
> 
> I don't think so (but I'm unsure). This is netif_running() (from include/linux/netdevice.h):
> 
> static inline bool netif_running(const struct net_device *dev)
> {
> 	return test_bit(__LINK_STATE_START, &dev->state);
> }
> 
> I'm not sure what this does. I don't think it's the same as checking whether the admin has
> issued an UP command?
> 
> 
> > And is_operstate_up the same as netif_oper_up()?
> 
> netif_oper_up() also returns true if the device state is IF_OPER_UNKNOWN. A device can
> have that state without even having carrier, so that's not OK for the HSR driver.
>

Then use netif_oper_up(dev) && netif_carrier_on(dev)
