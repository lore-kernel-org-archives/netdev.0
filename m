From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/2] genetlink: convert family dump code to use RCU
Date: Thu, 22 Aug 2013 09:17:30 +0200
Message-ID: <1377155850.14110.15.camel@jlt4.sipsolutions.net>
References: <1377094083-8122-1-git-send-email-johannes@sipsolutions.net>
	 <1377094083-8122-3-git-send-email-johannes@sipsolutions.net>
	 <CALnjE+oqN0NC1xmzTRFXOuMb+4L83JJyo5SGqBTvW-KfefE39g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:33980 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289Ab3HVHRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 03:17:36 -0400
In-Reply-To: <CALnjE+oqN0NC1xmzTRFXOuMb+4L83JJyo5SGqBTvW-KfefE39g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 21:32 -0700, Pravin Shelar wrote:

> I send out a fix which fixes genl locking for dump operation and it
> might fix this issue, Can you try this?

I don't think that fix is correct. I don't have a copy, so let me reply
here.

> http://marc.info/?l=linux-netdev&m=137714389705485&w=2

> In case of genl-family with parallel ops off, dumpif() callback
> is expected to run under genl_lock, 
> But commit def3117493eafd9df
> (genl: Allow concurrent genl callbacks.) changed this behaviour
> where only first dumpit() op was called under genl-lock.

I don't think either of those statements are true - dump() has alway
taken a shortcut in netlink_recvmsg() and doesn't go into genl_rcv(), so
how could your patch have changed locking? Therefore, it can't have been
expected either.

> For subsequent dump, only nlk->cb_lock was taken.
> Following patch fixes it by defining locked dumpit() and done()
> callback which takes care of genl-locking.

This might help for generic netlink itself, but I'm not convinced that
it's really useful for other families. I've fixed bugs like in commit
3a5a423bb958ad22eeccca66c533e85bf69ba10e, which actually made it in
after your commit, but per above I don't think it was actually a problem
introduced by your commit.

johannes
