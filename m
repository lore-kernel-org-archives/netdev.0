From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 1/2] genl: Fix genl dumpit() locking.
Date: Thu, 22 Aug 2013 09:36:20 +0200
Message-ID: <1377156980.14110.16.camel@jlt4.sipsolutions.net>
References: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:34016 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645Ab3HVHgZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 03:36:25 -0400
In-Reply-To: <1377143882-20717-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 20:58 -0700, Pravin B Shelar wrote:
> In case of genl-family with parallel ops off, dumpif() callback
> is expected to run under genl_lock, But commit def3117493eafd9df
> (genl: Allow concurrent genl callbacks.) changed this behaviour
> where only first dumpit() op was called under genl-lock.
> For subsequent dump, only nlk->cb_lock was taken.
> Following patch fixes it by defining locked dumpit() and done()
> callback which takes care of genl-locking.

As I've commented over in the other thread, I really think this is the
wrong thing to do. It was never the case that dumpit() was actually
locked under genl_lock(), and adding it doesn't really help anyone.

johannes
