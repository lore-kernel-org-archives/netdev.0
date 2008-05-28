From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Question on ipmr.c locking in 2.6.25
Date: Wed, 28 May 2008 22:58:34 +0100
Message-ID: <20080528215833.GA14038@solarflare.com>
References: <483DD0EE.1020700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:56873 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756865AbYE1V6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 17:58:44 -0400
Content-Disposition: inline
In-Reply-To: <483DD0EE.1020700@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear wrote:
> It looks like this method can return without unlocking the
> mrt_lock or mfc_unres_lock.  Is this a bug, or am I just
> confused about how it is supposed to work?
<snip>

Since it returns without unlocking in the normal (not error) case, I would
guess that's how it's supposed to work.  The caller can uses the it->cache
pointer to work out which lock (if any) it needs to unlock.

Still, this is an unusual way of doing things, and rates about a 2 on
Rusty's scale <http://ozlabs.org/~rusty/index.cgi/2008/03/30/> (though
to be fair this is not critical for static functions).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
