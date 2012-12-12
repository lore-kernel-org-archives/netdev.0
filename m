From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [patch net-next 0/4] net: allow to change carrier from
 userspace
Date: Wed, 12 Dec 2012 11:34:33 -0800
Message-ID: <20121212113433.21c05614@nehalam.linuxnetplumber.net>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
	<20121212081500.24085752@nehalam.linuxnetplumber.net>
	<20121212170520.GA3060@minipsycho.orion>
	<20121212092700.7ef2607a@nehalam.linuxnetplumber.net>
	<20121212181017.GB3060@minipsycho.orion>
	<20121212101208.361ccda0@nehalam.linuxnetplumber.net>
	<20121212182556.GC3060@minipsycho.orion>
	<20121212103632.2020efce@nehalam.linuxnetplumber.net>
	<20121212184925.GD3060@minipsycho.orion>
	<20121212105448.490aca5c@nehalam.linuxnetplumber.net>
	<20121212190613.GE3060@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com,
	greearb@candelatech.com, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40148 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503Ab2LLTfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 14:35:50 -0500
In-Reply-To: <20121212190613.GE3060@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Dec 2012 20:06:13 +0100
Jiri Pirko <jiri@resnulli.us> wrote:

> Wed, Dec 12, 2012 at 07:54:48PM CET, shemminger@vyatta.com wrote:
> >On Wed, 12 Dec 2012 19:49:26 +0100
> >Jiri Pirko <jiri@resnulli.us> wrote:
> >
> >> Wed, Dec 12, 2012 at 07:36:32PM CET, shemminger@vyatta.com wrote:
> >> >On Wed, 12 Dec 2012 19:25:56 +0100
> >> >Jiri Pirko <jiri@resnulli.us> wrote:
> >> >
> >> >> Wed, Dec 12, 2012 at 07:12:08PM CET, shemminger@vyatta.com wrote:
> >> >> >On Wed, 12 Dec 2012 19:10:17 +0100
> >> >> >Jiri Pirko <jiri@resnulli.us> wrote:
> >> >> >
> >> >> >> ># ip li show dev dummy0
> >> >> >> >12: dummy0: <NO-CARRIER,BROADCAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc noqueue state DORMANT mode DORMANT   
> >> >> >> 
> >> >> >> if you mean this "NO-CARRIER"
> >> >> >> it has no direct relation with netif_carrier_ok().
> >> >> >
> >> >> >It is the same value (IFF_RUNNING) that is visible from user space.
> >> >> 
> >> >> static inline bool netif_carrier_ok(const struct net_device *dev)
> >> >> {
> >> >> 	        return !test_bit(__LINK_STATE_NOCARRIER, &dev->state);
> >> >> }
> >> >> 
> >> >> So netif_carrier[ok/on/off] are working with on __LINK_STATE_NOCARRIER
> >> >> bit. Not with IFF_RUNNING flag.
> >> >
> >> >What is the code path that you are worried about netif_carrier_ok being set or clear?
> >> >The interaction here is complex, and right now LINK_STATE_NOCARRIER is purely
> >> >controlled by the driver, your patch changes that, but before acking I want
> >> >to make sure why it is required.
> >> 
> >> This patchset would provide a possibility to set or clear the carrier
> >> from userspace. For dummy device it would serve for direct emulation
> >> of link fail.
> >> 
> >> Also for team deriver, that would serve for teamd (userspace part) to
> >> set the carrier actually on or off (in case of LACP runner for example
> >> this is required).
> >> 
> >
> >You want to able to control the dummy device, so that you can test carrier
> >management in the team device. Another alternative is to use carrier control
> >on a virtual device. Vmware can do it, there were patches to do this with KVM/QEMU
> >not sure if they ever got incorporated.
> >
> >Since this is a specific feature of the dummy device which is specialized for
> >testing, maybe it should just be done by adding device specific ioctl rather
> >than letting it creep in as a general facility.
> 
> Ugh, specific ioctl stinks...
> But this is not only for dummy. As I said, we need this for team driver.
> Maybe I did not explain that correctly. Given the fact that the whole
> Team logic is in userspace, teamd (userspace daemon) needs to set the
> carrier state as if it was done in kernel. Yes, we would be able to do
> this by specific Team option in team driver, but I thought this would be
> nicer to do that more generally.

That is what the operstate mechanism was for. Why did we build that mechanism
if it doesn't work from userspace.

Maybe the fix is to make setting linkstate also set carrier bits.
