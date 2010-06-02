From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs class/net/ problem
Date: Wed, 02 Jun 2010 20:55:53 +0200
Message-ID: <1275504953.3915.31.camel@jlt3.sipsolutions.net>
References: <1275484611.3915.11.camel@jlt3.sipsolutions.net>
	 <20100602154608.GB12361@kroah.com>
	 <1275493693.3915.12.camel@jlt3.sipsolutions.net>
	 <m1ljaxxvcj.fsf@fess.ebiederm.org>
	 <1275495677.3915.16.camel@jlt3.sipsolutions.net>
	 <m14ohlxu51.fsf@fess.ebiederm.org>
	 <1275498007.3915.20.camel@jlt3.sipsolutions.net>
	 <m1ocftwdp7.fsf@fess.ebiederm.org>
	 <1275501157.3915.22.camel@jlt3.sipsolutions.net>
	 <m1y6exux6x.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:41417 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756795Ab0FBSzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 14:55:55 -0400
In-Reply-To: <m1y6exux6x.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-02 at 11:05 -0700, Eric W. Biederman wrote:

> If you want to dig into this look at sysfs_delete_link.  instrument
> it so that you can see if it is called for wlan{0,1,2} and see what
> ns it is called for.
> 
> My current hypothesis is something is causing us to try and delete
> the symlink from the wrong namespace, so we just skip that part of it.

[   78.253128] create link wlan0 ns=ffff88001ce1e600
...
[   93.462268] delete link wlan0 ns=ffff88001ce1e600

looks the same ...

Also note

[  109.872488] netconsole: network logging stopped, interface wlan0 unregistered
[  109.872910] PM: Removing info for No Bus:wlan0
[  109.872941] delete link wlan0 ns=ffff88001e9bd600
[  110.130563] PM: Removing info for No Bus:rfkill0
[  110.130599] delete link rfkill0 ns=ffff88001b61ea80
[  110.131135] PM: Removing info for No Bus:phy0
[  110.131161] delete link phy0 ns=ffff88001b61e240
[  110.131424] PM: Removing info for No Bus:hwsimdev0
[  110.131445] delete link hwsimdev0 ns=ffff88001b67ed80

(I changed the struct device thing in hwsim to be hwsimdev%d rather than
hwsim%d to tell the difference to hwsim0, the monitor netdev) so it's
getting removed from PM way after the wlan0 that links into it...

johannes

