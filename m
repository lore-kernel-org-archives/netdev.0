From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH for 2.6.32 (untested)] netns: Add quota for number of NET_NS instances.
Date: Mon, 21 Nov 2011 10:57:37 +0900
Message-ID: <201111210157.pAL1vbRo089486@www262.sakura.ne.jp>
References: <201111201622.FDJ51567.VLFHQFMFOOSOtJ@I-love.SAKURA.ne.jp> <m1bos6wfnt.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:59524 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773Ab1KUB5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 20:57:40 -0500
In-Reply-To: <m1bos6wfnt.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:
> 
> > In order to solve below problems, can we add sysctl variable for
> > restricting number of NET_NS instances?
> 
> I don't have any particular problems with patch but I don't think it
> will result in a working system that is easy to keep working.  Tuning
> static limits can be fickle.

What I worry is that, although clone() is an operation that is allowed to
sleep, waiting for too long might be annoying for users, especially when the
user cannot easily send Ctrl-C or SIGKILL. (I think ftp client is an example.)

> My inclination in this case the practical fix is that during network
> namespace allocation someone take a look at the cleanup_list.  See
> that there is ongoing cleanup activity, and wait until at least one
> network namespace has cleaned up.  Perhaps by creating a work struct
> and waiting for it to cycle through the netns workqueue.

Are you suggesting that we should wait only when "the number of NET_NS
instances exceeded quota" and "there is a dead NET_NS instance"?
In other words, let clone() fail immediately if "the number of NET_NS
instances exceeded quota" but "cleanup_list is empty"?

If you are suggesting that we should always wait until "the number of NET_NS
instances becomes smaller than quota", clone() might sleep too long when the
user cannot easily send signals.
