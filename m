From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: perm_addr get
Date: Fri, 21 Dec 2012 14:25:00 +0100
Message-ID: <20121221132500.GC2040@minipsycho.orion>
References: <20121221130127.GB2040@minipsycho.orion>
 <1356095395.7055.34.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:49340 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752010Ab2LUNZE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 08:25:04 -0500
Received: by mail-ee0-f48.google.com with SMTP id b57so2347312eek.7
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 05:25:02 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1356095395.7055.34.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Dec 21, 2012 at 02:09:55PM CET, bhutchings@solarflare.com wrote:
>On Fri, 2012-12-21 at 14:01 +0100, Jiri Pirko wrote:
>> Hi all.
>> 
>> From what I understand dev->perm_addr is set only in case the hw has
>> permanent hw address somewhere written (for example EPROM).
>> 
>> So when I query device which does not have perm_addr set I get:
>> 
>> testt1:~$ ethtool -P team0
>> Permanent address: 00:00:00:00:00:00
>> 
>> Is this the correct behaviour? Wouldn't it be more correct if
>> ethtool_get_perm_addr() fails with -ENOENT for something like that?
>
>I don't think we should change the implementation now, as someone might
>depend on it.  It's trivial to distinguish this not-a-permanent-address
>case.  However the ethtool command output could be improved.

Well, not change it even if it is not correct? And by "trivial to distinguish"
you mean 00:00:00:00:00:00 ~ device has no permanent address?
But in some cases (like vxge, mac80211) it's possible to see 00:00:00:00:00:00
by ethtool -P even though the device has permanent address (set later on, after
register_netdev call).

I think that ethtool_get_perm_addr should return:
-ENOENT if dev has no perm addr
-EAGAIN if dev perm addr hasn't been obtained yet
0 (and addr) in other cases
	
And how exactly should be the ethtool output improved?

Thanks

Jiri

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
