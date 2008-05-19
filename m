From: Patrick McHardy <kaber@trash.net>
Subject: Re: Question about VLAN + checksum offloading
Date: Mon, 19 May 2008 19:45:24 +0200
Message-ID: <4831BCB4.9070704@trash.net>
References: <1210924374.5136.94.camel@localhost.localdomain> <D5C1322C3E673F459512FB59E0DDC329051AC07F@orsmsx414.amr.corp.intel.com> <4831BC4D.7000601@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ichiro Suzuki <isuzuki@miraclelinux.com>, netdev@vger.kernel.org,
	Naohiro Ooiwa <nooiwa@miraclelinux.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43168 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbYESRp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2008 13:45:27 -0400
In-Reply-To: <4831BC4D.7000601@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> Waskiewicz Jr, Peter P wrote:
>>> o If so, is there any mechanism to propagate  real_dev->features 
>>> flags in vlan.c?
>>
>> There isn't an explicit way.  I had written patches into e1000, igb,
>> e1000e, and ixgbe to propogate the VLAN flags within the driver when the
>> VLAN device was created.  The trick though is if you remove a feature
>> flag with ethtool, say checksum offload, on your main device, you
>> probably should turn it off on your VLAN devices.  Patrick McHardy
>> pointed me at netdev_feature_change() to use within the driver.  I'll
>> admit I haven't had the time to fix my drivers to use this call, but it
>> certainly looks like the way to go.  Please see the (middle) of the
>> thread here: http://marc.info/?l=linux-netdev&m=120878809806631&w=2
>>
>>> o If such mechanism doesn't exist, is my patch reasonable?
>>
>> I would say yes, halfway.  The issue is you probably want to remove the
>> feature flag from the VLAN device if you removed the flag from the
>> parent device as well.
> 
> 
> Yes, it should use the same mechanism as suggested for the
> VLAN accel feature. And it should be limited to features

I meant TSO, sorry.

> that are known to work, not just blindly copy everything.
> 
> I will be catching up with the VLAN patches posted recently
> sometime next week. I guess I can then also add a patch for
> feature propagation myself if you don't beat me to it :)
