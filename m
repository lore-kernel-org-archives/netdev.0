From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: calling request_firmware() from module init will not work with
 recent/future udev versions
Date: Thu, 16 Feb 2012 13:38:01 +0100
Message-ID: <1329395881.3915.7.camel@jlt3.sipsolutions.net>
References: <CAPXgP11iT9K2KcDCJvw_druf5qdNjs0jLfrbpS7CcYh5vXrz_w@mail.gmail.com>
	 <1326621743.3448.1.camel@jlt3.sipsolutions.net>
	 <CAPXgP13b0uu3DgOGRL-_WKx-aSQN-f0xL6OmjNPBGf9fg0satA@mail.gmail.com>
	 ( sfid-20120115_163411_716244_29DE7A13) <1326704259.3510.3.camel@jlt3.sipsolutions.net>
	 <4F3CF0C1.3090304@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Tom Gundersen <teg@jklm.no>, Andy Whitcroft <apw@canonical.com>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:34288 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab2BPMiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 07:38:06 -0500
In-Reply-To: <4F3CF0C1.3090304@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-16 at 13:04 +0100, Arend van Spriel wrote:
> On 01/16/2012 09:57 AM, Johannes Berg wrote:
> >> Now the problem, the pcidev event is blocking in modprobe and waits
> >> >  for the child event it has generated to finish, but udev does not
> >> >  start the event because the parent still blocks in modprobe ->
> >> >  deadlock until default firmware timeout of 60 sec. What we want here,
> >> >  for several reasons not only udev's dependency logic, is that modprobe
> >> >  never waits for userspace transactions to finish.
> > Ok, thanks for the description. I guess to me that means nothing really
> > changes much in the situation I'm thinking of.
> 
> I am working on changes in brcm80211 driver and the behaviour changes 
> slightly. The async firmware request basically kicks of a kernel thread 
> to do the actual request. So the probe finishes successfully regardless 
> what the results will be of the actual firmware request. Hence the 
> driver is associated with the hardware.

This is true.

> >> >  If userspace is not responding, the firmware request times out after
> >> >  60 seconds and the driver is not associated with any hardware. To
> >> >  retry the firmware loading, the module needs to be unloaded and
> >> >  reloaded, or the driver needs to be asked to bind to a device again by
> >> >  writing to the 'bind' in file in the sysfs driver directory.
> > Right.
> >
> 
> If my previous statement is true, what does it mean regarding retrying 
> the firmware loading?

When the firmware loading fails, the driver should unbind from the
device that it failed for, and the retrying behaviour doesn't change
(and requires a rebind)

johannes
