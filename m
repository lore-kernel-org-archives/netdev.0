From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on ipmr.c locking in 2.6.25
Date: Wed, 28 May 2008 15:06:45 -0700
Message-ID: <483DD775.2070901@candelatech.com>
References: <483DD0EE.1020700@candelatech.com> <20080528215833.GA14038@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([66.165.47.212]:45948 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753389AbYE1WGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 18:06:48 -0400
In-Reply-To: <20080528215833.GA14038@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Ben Greear wrote:
>> It looks like this method can return without unlocking the
>> mrt_lock or mfc_unres_lock.  Is this a bug, or am I just
>> confused about how it is supposed to work?
> <snip>
> 
> Since it returns without unlocking in the normal (not error) case, I would
> guess that's how it's supposed to work.  The caller can uses the it->cache
> pointer to work out which lock (if any) it needs to unlock.
> 
> Still, this is an unusual way of doing things, and rates about a 2 on
> Rusty's scale <http://ozlabs.org/~rusty/index.cgi/2008/03/30/> (though
> to be fair this is not critical for static functions).

Ok, I think I see how it works.

Now I wonder:  If a reader read only a small bit of the proc file,
and then just went to sleep w/out closing or reading the rest of
the file, would that effectively DOS a system by pinning the locks?

Thanks,
Ben

> 
> Ben.
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

