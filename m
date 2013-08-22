From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Thu, 22 Aug 2013 19:51:46 +0200
Message-ID: <1377193906.14110.27.camel@jlt4.sipsolutions.net>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
	 <1377156980.14110.16.camel@jlt4.sipsolutions.net>
	 <CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:35781 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab3HVRvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 13:51:50 -0400
In-Reply-To: <CALnjE+qgZ_UZ4GdiZ4UCzfTLn-OveoHtE28uQZokz2kPD4srXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-22 at 10:42 -0700, Pravin Shelar wrote:
> On Thu, Aug 22, 2013 at 12:36 AM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
> > On Wed, 2013-08-21 at 20:58 -0700, Pravin B Shelar wrote:
> >> In case of genl-family with parallel ops off, dumpif() callback
> >> is expected to run under genl_lock, But commit def3117493eafd9df
> >> (genl: Allow concurrent genl callbacks.) changed this behaviour
> >> where only first dumpit() op was called under genl-lock.
> >> For subsequent dump, only nlk->cb_lock was taken.
> >> Following patch fixes it by defining locked dumpit() and done()
> >> callback which takes care of genl-locking.
> >
> > As I've commented over in the other thread, I really think this is the
> > wrong thing to do. It was never the case that dumpit() was actually
> > locked under genl_lock(), and adding it doesn't really help anyone.
> >
> If you look at commit def3117493eafd9df , it removes assignment of
> cb_mutex to genl_mutex. Thats how genl-dump operation was called under
> genl_mutex.

By the way - why? This just means that netlink will allocate another
lock to lock it all, so it's not a very useful change?

johannes
