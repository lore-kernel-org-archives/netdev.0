From: Ichiro Suzuki <isuzuki@miraclelinux.com>
Subject: Re: Question about VLAN + checksum offloading
Date: Tue, 20 May 2008 12:19:48 +0900
Message-ID: <1211253588.9823.2.camel@localhost.localdomain>
References: <1210924374.5136.94.camel@localhost.localdomain>
	 <D5C1322C3E673F459512FB59E0DDC329051AC07F@orsmsx414.amr.corp.intel.com>
	 <4831BC4D.7000601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	netdev@vger.kernel.org, Naohiro Ooiwa <nooiwa@miraclelinux.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:49819 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754986AbYETDTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 23:19:50 -0400
In-Reply-To: <4831BC4D.7000601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you, PJ and Patrick.
I'll revisit the code after VLAN patches are posted.

----------------------------------------------
Ichiro Suzuki       <isuzuki@miraclelinux.com>
Miracle Linux Corp., Advanced Technology Group
----------------------------------------------

On Mon, 2008-05-19 at 19:43 +0200, Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:
> >> o If so, is there any mechanism to propagate  
> >> real_dev->features flags in vlan.c?
> > 
> > There isn't an explicit way.  I had written patches into e1000, igb,
> > e1000e, and ixgbe to propogate the VLAN flags within the driver when the
> > VLAN device was created.  The trick though is if you remove a feature
> > flag with ethtool, say checksum offload, on your main device, you
> > probably should turn it off on your VLAN devices.  Patrick McHardy
> > pointed me at netdev_feature_change() to use within the driver.  I'll
> > admit I haven't had the time to fix my drivers to use this call, but it
> > certainly looks like the way to go.  Please see the (middle) of the
> > thread here: http://marc.info/?l=linux-netdev&m=120878809806631&w=2
> > 
> >> o If such mechanism doesn't exist, is my patch reasonable?
> > 
> > I would say yes, halfway.  The issue is you probably want to remove the
> > feature flag from the VLAN device if you removed the flag from the
> > parent device as well.
> 
> 
> Yes, it should use the same mechanism as suggested for the
> VLAN accel feature. And it should be limited to features
> that are known to work, not just blindly copy everything.
> 
> I will be catching up with the VLAN patches posted recently
> sometime next week. I guess I can then also add a patch for
> feature propagation myself if you don't beat me to it :)
> 
> 

