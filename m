From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: perm_addr get
Date: Fri, 21 Dec 2012 14:40:32 +0000
Message-ID: <1356100832.7055.45.camel@deadeye.wl.decadent.org.uk>
References: <20121221130127.GB2040@minipsycho.orion>
	 <1356095395.7055.34.camel@deadeye.wl.decadent.org.uk>
	 <20121221132500.GC2040@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10664 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031Ab2LUOkg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 09:40:36 -0500
In-Reply-To: <20121221132500.GC2040@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 14:25 +0100, Jiri Pirko wrote:
> Fri, Dec 21, 2012 at 02:09:55PM CET, bhutchings@solarflare.com wrote:
> >On Fri, 2012-12-21 at 14:01 +0100, Jiri Pirko wrote:
> >> Hi all.
> >> 
> >> From what I understand dev->perm_addr is set only in case the hw has
> >> permanent hw address somewhere written (for example EPROM).
> >> 
> >> So when I query device which does not have perm_addr set I get:
> >> 
> >> testt1:~$ ethtool -P team0
> >> Permanent address: 00:00:00:00:00:00
> >> 
> >> Is this the correct behaviour? Wouldn't it be more correct if
> >> ethtool_get_perm_addr() fails with -ENOENT for something like that?
> >
> >I don't think we should change the implementation now, as someone might
> >depend on it.  It's trivial to distinguish this not-a-permanent-address
> >case.  However the ethtool command output could be improved.
> 
> Well, not change it even if it is not correct? And by "trivial to distinguish"
> you mean 00:00:00:00:00:00 ~ device has no permanent address?
> But in some cases (like vxge, mac80211) it's possible to see 00:00:00:00:00:00
> by ethtool -P even though the device has permanent address (set later on, after
> register_netdev call).

Oh well, those are just driver bugs that should be fixed.

> I think that ethtool_get_perm_addr should return:
> -ENOENT if dev has no perm addr
> -EAGAIN if dev perm addr hasn't been obtained yet
> 0 (and addr) in other cases
> 	
> And how exactly should be the ethtool output improved?

Print something like 'No permanent address assigned' when the address is
all-zeroes.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
