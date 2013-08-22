From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Thu, 22 Aug 2013 20:18:54 +0200
Message-ID: <1377195534.14110.29.camel@jlt4.sipsolutions.net>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	 <1377156980.14110.16.camel@jlt4.sipsolutions.net>
	 <CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
	 <1377193906.14110.27.camel@jlt4.sipsolutions.net>
	 <CALnjE+rEOMmyFQ0Nx3-O-Cvu8yePVBg7x8vgpGUOAAnYv3KG4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:35856 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419Ab3HVSTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 14:19:03 -0400
In-Reply-To: <CALnjE+rEOMmyFQ0Nx3-O-Cvu8yePVBg7x8vgpGUOAAnYv3KG4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 11:10 -0700, Pravin Shelar wrote:

> > By the way - why? This just means that netlink will allocate another
> > lock to lock it all, so it's not a very useful change?
> >
> This replaces global genl-lock with per-socket lock which allows
> parallel operation in parallel-genl-families and they are not blocked
> due to other unrelated genl-family operations.

I don't think so? It replaces the genl lock as cb_mutex with a per
*kernel* socket lock, so really just one per network namespace. That's
not much of an improvement really.

johannes
