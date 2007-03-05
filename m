From: Matt Mackall <mpm@selenic.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Sun, 4 Mar 2007 18:25:50 -0600
Message-ID: <20070305002550.GI23311@waste.org>
References: <20070304220857.GH23311@waste.org> <1173051564.6131.13.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-wireless <linux-wireless@vger.kernel.org>, akpm@osdl.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:55994 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797AbXCEAia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Mar 2007 19:38:30 -0500
Content-Disposition: inline
In-Reply-To: <1173051564.6131.13.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 12:39:24AM +0100, Johannes Berg wrote:
> [adding linux-wireless to CC]
> 
> On Sun, 2007-03-04 at 16:08 -0600, Matt Mackall wrote:
> > Recent kernels are having troubles with wireless for me. Two seemingly
> > related problems:
> 
> I don't think they are related actually.
> 
> > a) NetworkManager seems oblivious to the existence of my IPW2200
> 
> This is due to the recent sysfs restructuring I think. IIRC the fix is
> to upgrade hal to a current git version.

If that's the cause, the fix is to back out whatever was done to break
userspace. Breaking userspace is not ok. Upgrading from 2.6.x to
2.6.x+1 should not entail replacing substantial parts of userspace,
especially with NOT-EVEN-FRAKKING-RELEASED-YET CODE. 

I will try a new HAL when it shows up in Debian/unstable and not a
moment sooner.

> > b) Manual iwconfig waits for 60s and then reports:
> 
> That one's strange.
> 
> > A second attempt to enable WEP via iwconfig succeeds and network
> > connectivity is normal. However, NetworkManager still ignores the
> > device at this point.
> 
> I'd think it's a ipw bug but I have no idea if that was even touched
> during this time.
> 
> > Bisect with Mercurial points to this patch:
> > 
> > $ hg bisect bad
> > The first bad revision is:
> > changeset:   46985:f701b96bb2f7
> > user:        Greg Kroah-Hartman <gregkh@suse.de>
> > date:        Wed Feb 07 10:37:11 2007 -0800
> > summary:     Network: convert network devices to use struct device
> > instead of class_device
> > 
> > which corresponds to 43cb76d91ee85f579a69d42bc8efc08bac560278 in git.
> 
> Yup, sysfs breakage/hal stuff. Can you try with a recent hal? And maybe
> try to bisect the iwconfig stop thing if you've got enough time...

Will double-check the iwconfig tests. It's been masked by
NetworkManager for a while.

-- 
Mathematics is the supreme nostalgia of our time.
